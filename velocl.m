function [xstream, zstream, ui, vi, cl] = velocl(code,No,AoA,uinf,xpoints, zpoints, xpointsc,zpointsc,str,Ni)
%velocl determines the lift coefficient of a NACA-4 airfoil
%The function inputs are as follows:
%code -- The NACA-4 digit code of the desired airfoil as a string i.e.'1410'
%No -- The number of pannels to be used to discretize the airfoil
%AoA -- Angle of Attack of the desired airfoil in degrees
%uinf -- Velocity of the freestream airflow
%xpoints -- 1 dimensional array corresponding to panel x-coordinates of
%idealised solution
%zpoints -- 1 dimensional array corresponding to panel z-coordinates of
%idealised solution
%xpointsc -- 1 dimensional array corresponding to panel endpoints x-coordinates
%zpointsc -- 1 dimensional array corresponding to panel endpoints z-coordinates
%str -- a 1 x (n+1) matrix that contains the panel strengths
%Ni -- number of panels in idealised solution
%Airfoil code notation:
%The 1st digit of the code represents the maximum camber, in percent of chord
%The 2nd digit of the code indicates the location of maximum camber, in
%tenths of chord
%The final 2 digits correspond to the maximum airfoil thickness, which for
%this family of airfoils occurs at 30% of the chord from the leading edge
%The function outputs are as follows:
%xstream -- x-coordinates of points at which the stream velocity is
%calculated
%zstream -- z-coordinates of points at which the stream velocity is
%calculated
%ui -- horizontal total velocity of flow
%vi -- vertical total velocity of flow
%cl -- coefficient of lift of the airfoil

%Variable names and common notation through the function:
%%uij -- x-velocity component imparted by the jth panel on the freestream, found using cdoublet function
%vij -- z-velocity component imparted by the jth panel on the freestream, found using cdoublet function
%Nstream -- number of points into which range and domain are discretised
%uijsum -- x sum of strength induced velocity
%vijsum -- z sum of strength induced velocity

%convert angle of attack to radians
AoA=deg2rad(AoA);

%calculate cl using strength of wake panel
cl = -2*str(No+1)/uinf;

%add condition so that freestream conditions only worked out for final case
%of NACA 2412
if strcmp(code,'2412') && No~=200  
    ui=0;
    vi=0;
    xstream=0;
    zstream=0;
elseif strcmp(code,'2412') && AoA~=deg2rad(10)
    ui=0;
    vi=0;
    xstream=0;
    zstream=0;
else
    %creating points of domain
    %number of points is Nstream^2
    Nstream = 100;
    x = linspace(-0.2,1.2,Nstream);
    z = linspace(-0.7,0.7,Nstream);
    
    [xstream, zstream] = meshgrid(x,z);
    
    %defining terms from initial conditions of velocity
    uijsum = (zeros(Nstream,Nstream) + uinf*cos(AoA));
    vijsum = (zeros(Nstream,Nstream) + uinf*sin(AoA));
    
    %calculating velocity term influenced by the strength
    for c=1:(Nstream^2)
        for j=1:No+1
            %check if points are in airfoil, if they are in airfoil, their
            %velocities will be non existent
            if (inpolygon(xstream(c),zstream(c),xpoints(1:Ni),zpoints(1:Ni)))
                uijsum(c)=nan;
                vijsum(c)=nan;
            else
                [uij, vij] = cdoublet([xstream(c),zstream(c)], [xpointsc(j),zpointsc(j)], [xpointsc(j+1),zpointsc(j+1)]);
                uijsum(c)=uijsum(c)+str(j)*uij;
                vijsum(c)=vijsum(c)+str(j)*vij;
            end
        end
    end
    %function outputs
    ui=uijsum;
    vi=vijsum;
end


