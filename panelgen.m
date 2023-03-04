function [xpoints, zpoints] = panelgen(code,No,AoA)
%panelgen generates and discretizes a NACA-4 airfoil
%The function inputs are as follows:
%code -- The NACA-4 digit code of the desired airfoil as a string i.e.'1410'
%No -- The number of panels to be used to discretize the airfoil
%AoA -- Angle of Attack of the desired airfoil in degrees
%Airfoil code notation:
%The 1st digit of the code represents the maximum camber, in percent of chord
%The 2nd digit of the code indicates the location of maximum camber, in
%tenths of chord
%The final 2 digits correspond to the maximum airfoil thickness, which for
%this family of airfoils occurs at 30% of the chord from the leading edge
%The function outputs are as follows:
%xpoints -- 1 dimensional array corresponding to panel endpoints
%x-coordinates
%zpoints -- 1 dimensional array corresponding to panel endpoints
%z-coordinates

%Variable names and common notation through the function:
%m -- maximum camber percentage
%p -- location of maximum camber percentage
%t -- maximum airfoil thickness percentage
%_init -- indicative that the variable is the initial
%yc -- mean camber line
%dyc_dx -- derivative of mean camber line with respect to x
%theta -- gradient
%yt -- thickness function
%xu -- upper surface x-coordinate
%xl -- lower surface x-coordinate
%zu -- upper surface z-coordinate
%zl -- lower surface z-coordinate
%xtr -- x-coordinate of final panel starting at the trailing edge and
%extending to infinity
%ztr -- z-coordinate of final panel starting at the trailing edge and
%extending to infinity

%check for odd number of panels:
if rem(No,2) == 1
    No = No+1;
    disp('Number of panels selected was odd, the resolution was increased by one panel.');
end

%Extract values from airfoil code:
m_init = str2double(code(1));
p_init = str2double(code(2));
t_init = str2double(code(3:4));
AoA=deg2rad(AoA);

%constants for thickness function:
c0=0.2969;
c1=-0.126;
c2=-0.3516;
c3=0.2843;
c4=-0.1015;

%CALCULATIONS

%Actual percentage values of the airfoil properties
m=m_init/100;
p=p_init/10;
t=t_init/100;

%Pannel end points

x=(1-0.5.*(1-cos((2.*pi).*([1:No]-1)./No)))';

%Camber and Gradient

%initialise arrays
yc = ones(No,1);
dyc_dx = ones(No,1);
theta = ones(No,1);

for i = 1:1:No
    if (x(i) >= 0 && x(i) < p)
        yc(i) = (m/p^2)*((2*p*x(i))-x(i)^2);
        dyc_dx(i) = ((2*m)/(p^2))*(p-x(i));
    elseif (x(i) >= p && x(i) <= 1)
        yc(i) = (m/(1-p)^2)*(1-(2*p)+(2*p*x(i))-(x(i)^2));
        dyc_dx(i) = ((2*m)/((1-p)^2))*(p-x(i));
    end
    theta(i) = atan(dyc_dx(i));
end

%Thickness distribution
yt = 5*t.*((c0.*sqrt(x))+(c1.*x)+(c2.*x.^2)+(c3.*x.^3)+(c4.*x.^4));
%ensure trailing edge thickness is 0
yt(1)=0;

%Upper surface points
xu = x(1:No/2) - yt(1:No/2).*sin(theta(1:No/2));
zu = yc(1:No/2) + yt(1:No/2).*cos(theta(1:No/2));

%Lower surface points
xl = x(No/2+1:end) + yt(No/2+1:end).*sin(theta(No/2+1:end));
zl = yc(No/2+1:end) - yt(No/2+1:end).*cos(theta(No/2+1:end));

%ensure airfoil goes through [1,0]
xl(end+1)=1;
zl(end+1)=0;

%Additional panel at trailing edge in direction of flow, to represent the
%wake of the airfoil
xtr = 9e99; %arbitrarily large number to resemble infinity
ztr = xtr*tan(AoA); 

%Combining surface points to generate output
xpoints = cat(1,xu,xl,xtr);
zpoints = cat(1,zu,zl,ztr);

end



