function str=strsol(xpointsc,zpointsc,No,AoA,uinf)
%strsol generates and solves the matrices needed to find the unknown panel
%strengths of a NACA-4 airfoil
%The function inputs are as follows:
%xpointsc -- 1 dimensional array corresponding to panel endpoints x-coordinates
%zpointsc -- 1 dimensional array corresponding to panel endpoints z-coordinates
%No -- The number of pannels to be used to discretize the airfoil
%AoA -- Angle of Attack of the desired airfoil in degrees
%uinf -- Velocity of the freestream airflow
%The function output is as follows:
%str -- a 1 x (n+1) matrix that contains the unknown panel strengths

%Variable names and common notation through the function:
%A -- square matrix of size (n+1) x (n+1) representing the linear equations
%used to solve for the panel strengths
%B -- matrix of size 1 x (n+1) that contains the solutions to the linear
%equations
%xmid -- array of panel midpoints x-coordinates
%zmid -- array of panel midpoints z-coordinates
%beta -- array of panel angles

%As visible by function inputs, the panel endpoints must be generated
%before calling this function

%initialise known variables:
A = zeros(No+1,No+1); %must be zeros for last row to work properly as per Eq.13
B = ones(No+1,1);
beta = ones(No,1);
uij = ones(No,No);
vij = ones(No,No);

%convert angle of attack to radians, after use of panelgen function
AoA = deg2rad(AoA);

%using cdoublet to obtain velocities imparted at the centre of ith panel by
%jth panel, uij and vij:

%midpoints of each panel
xmid = (xpointsc(2:No+1)+xpointsc(1:No))/2;
zmid = (zpointsc(2:No+1)+zpointsc(1:No))/2;

%velocity component imparted at the centre of the ith panel by the jth
%panel, found using cdoublet function
for i=1:No
    for j=1:No+1
        [uij(i,j), vij(i,j)] = cdoublet([xmid(i),zmid(i)], [xpointsc(j),zpointsc(j)], [xpointsc(j+1),zpointsc(j+1)]);
    end
end

%working out beta, ensuring it is within [0,2pi]
beta=(atan2((zpointsc(2:No+1)-(zpointsc(1:No))),(xpointsc(2:No+1)-(xpointsc(1:No)))));

%defining our B matrix
B = -uinf.*sin(AoA-beta);
B(No+1,1) = 0;

%defining our A matrix
A = vij.*cos(beta)-uij.*sin(beta);
A(No+1,No+1)=1;
A(No+1,1)=1;
A(No+1,No)=-1;

%solving A*str=B for str
%we are going to dissable warning to avoid matrix close to singular message
warning("off")
str=A\B;
warning("on")
