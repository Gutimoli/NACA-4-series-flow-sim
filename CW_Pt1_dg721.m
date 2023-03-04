%Coursework programming project for Computing and Numerical methods 2022
%Written by Daniel Gutierrez CID:02020436

%Code aims and outline:

%Aims:
%The code is designed to calculate Lift Coefficient, for a NACA-4 series
%airfoil using panel methods. The user will provide up to 4 inputs; the
%airfoil 4 digit code, the freestream velocity, the angle of attack and the
%number of panels desired. The code will return the lift Coefficient to the
%user, together with a plot of the desired airfoil and conditions and
%simulated streamlines around the airfoil
%However, if the input code is 2412, the code will execute all the previous
%actions, but without asking for angle of attack or panel number, as it
%will plot by default 10 degrees and 200 panels. On top of that, it will
%also output a plot in which the change of Lift Coefficient with angle of
%Attack is displayed for panel numbers 50, 100 and 200. The plot will also
%display the same trend for 2412, extracted from an XFOIL file

%Outline:

%1) User inputs are taken, with some error detection code in place

%2) A check is done to see if airfoil is the special 2412

%3) If airfoil is 2412, the values and according Cl vs AoA plot is generated

%4) If airfoil was not 2412, step 3 is skipped, and instead we get the 
%final user inputs of angle of attack and panel number. 

%5) Generate and discretise the airfoil

%6) Generate and discretise ideal version of airfoil

%7) Solve for the panel strength

%8) Obtain lift coefficient and stream velocities

%9) Plot airfoil, and ideal if necessary

%10) Plot streamlines

%11) Add appropiate titles and labels

%Notes: All plots will be saved programmatically to the user's computer,
%also, the code requires the custom built functions: panelgen, strsol,
%velocl, and the given cdoublet, and the text file with the xfoil data to run.

%house keeping
clear
clc

%defining user inputs for NACA-4 digit code:
Code = input('What airfoil do you want to use? ', 's');

%Attempt to catch errors with previous input, so that code runs properly:

%If Code input is not a 4 digit code, is 0000, is a decimal, is negative,
%or is not a number
%we don't use double or operators, as we are not dealing with numbers
while (length(Code) ~= 4) | (Code=='0000') | (contains(Code,'.')) | (contains(Code,'-')) | (isnan(str2double(Code)))
    %display error message
    disp("The Code enterred was not acceptable, needs to be 4 digit number code, can't be 0000, can't be negative, and can't be decimal.");
    %ask for new input
    Code = input('What airfoil do you want to use? ', 's');
end

%Ni is the number of panels to be used in idealised solution
Ni=300;

%later in the code if the user asks for a number of panels higher than our
%initial idealised solution, that number will become the new idealised
%solution

%add condition for special airfoil NACA 2412
if strcmp(Code,'2412')
    AoA=[0:1:10];
    No=[50,100,200];
    Uinf=15;
    %initialise cl
    cl=zeros(10,3);
        for i=1:11
            %generate airfoil coordinate points with idealised solution of Ni panels
            %idea is that a solution with less than Ni panels, the likely user input, will be included within the idealised solution. 
            [xpoints, zpoints] = panelgen(Code,Ni,AoA(i));
            for j=1:3
                %generate and discretise the airfoil
                [xpointsc, zpointsc]=panelgen(Code,No(j),AoA(i));
            
                %obtain unknown panel strengths
                str=strsol(xpointsc,zpointsc,No(j),AoA(i),Uinf);

                %output lift coefficient
                [xstream, zstream, ui, vi, cl(i,j)] = velocl(Code,No(j),AoA(i),Uinf,xpoints,zpoints,xpointsc,zpointsc,str,Ni);
            end
        end
    %do Cl vs angle of attack plot
    fig1=figure;
    plot(AoA,cl,'LineWidth',1.5)
    xlabel(['Angle of Attack (' char(176) ')'],'FontSize',14)
    ylabel('Lift Coefficient','FontSize',14)
    title('Cl vs Angle of attack for NACA 2412','FontSize',20)
    hold on
    %read xfoil data
    data=table2array(readtable('xf-naca2412-il-1000000.txt'));
    %add to plot values for cl in angle of attack range used from data
    plot(data(70:108,1),data(70:108,2),'LineWidth',1.5,'Color','k')
    %legen
    lgd1=legend('50 panels','100 panels','200 panels','Xfoil data','Location','southeast');
    lgd1.FontSize=14;
    hold off
    %saving current figure
    string1=['NACA_2412_at_',num2str(Uinf),'_ms_Lift_Coefficient_vs_Angle_of_Attack.png'];
    saveas(fig1,string1);
    
    %change angle of attack and number of panels to final number, so plot
    %titles generated appropiately
    AoA=10;
    No=200;

    %for plotting later
    checknum=1;
else
    %defining user input for freestream velocity we get it as a string to do
    %check below
    Uinf = input('What freestream velocity do you want to test this airfoil at? ','s');

    %attempt to catch errors again, here only case where uinf==0 or is contains
    %letters
    %we don't use double or operators, as we are not dealing with numbers
    while (Uinf==0) | (isnan(str2double(Uinf)))
        %display error message
        disp('The velocity enterred was invalid, it was either 0, or contained characters.')
        %ask for new input
        Uinf = input('What freestream velocity do you want to test this airfoil at? ','s');
    end

    %Get back to double our velocity to continue our code:
    Uinf=str2double(Uinf);

    %user input for angle of attack
    AoA = input('At what angle of attack will the airfoil be? ');
    
    %no need for angle of attack error, since we can work with any number
    %and MATLAB automatically generates error if a letter is inputed

    No = input('How many panels do you want to discretise the airfoil into? ');

    %attempt to catch Number of panels error, if number is 0, negative
    %or decimal

    %no need for number of panels being odd, as this case is dealt with in
    %the panelgen function

    while (mod(No,1)~=0) || (No==0) || (No<0)
        %display error message
        disp('The number of panels chosen was not acceptable as input, make sure it is not 0, not negative and not decimal. ');
        %ask for user input again
        No = input('How many panels do you want to discretise the airfoil into? ');
    end
    
    %generate and discretise the airfoil
    [xpointsc, zpointsc] = panelgen(Code,No,AoA);
    
    %for logical purposes, check if Number of panels selected is more than
    %ideal solution, if so no need to work our ideal at lower/same panel number
    
    %variable checknum will be 1, this is an indicator that ideal
        %number of panels and actual number of panels is the same, so that
        %they are not both plotted
        checknum=1;    
    
    if No>Ni
        %make ideal number, user input number
        Ni=No;
        %ideal points will be the same as No points
        [xpoints,zpoints]=deal(xpointsc,zpointsc);
    else
        %generate airfoil coordinate points with idealised solution of Ni panels
        %idea is that a solution with less than Ni panels, the likely user input, will be included within the idealised solution. 
        [xpoints, zpoints] = panelgen(Code,Ni,AoA);
    end
    %obtain unknown panel strengths
    str=strsol(xpointsc,zpointsc,No,AoA,Uinf);
    %output lift coefficient and streamline points and velocities
    [xstream, zstream, ui, vi, cl] = velocl(Code,No,AoA,Uinf,xpoints,zpoints,xpointsc,zpointsc,str,Ni);
    disp("The airfoil's lift coefficient is: " + cl)
end
%STREAMLINE PLOT
%plot airfoil
fig2=figure;
plot(xpointsc(1:No+1), zpointsc(1:No+1),'k','LineWidth',2);
axis equal;
hold on

%if the No is low, and the difference between No and Ni is greater than
%100, also plot the idealised airfoil
if  (No<50) && (abs(No-Ni)>100)
    plot(xpoints(1:Ni+1),zpoints(1:Ni+1),'r','LineWidth',2);
    checknum=0;
end

%plots streamlines
S=streamslice(xstream,zstream,ui,vi,2);
set(S,'Linewidth',1);
set(S,'Color','b');

%Title
title(sprintf('NACA %s at %.0f m/s, %.0f degrees angle of attack, with %.0f panels',Code,Uinf,AoA,No),'FontSize',12);
xlabel('x - horizontal distance from leading edge in terms of x/c');
ylabel('z - vertical distance from leading edge in terms of z/c');
if (checknum==0)
    %legend if we added the extra plot
    lgd2=legend(sprintf('Airfoil with %.0f panels',No),'Idealised Airfoil','Streamlines','Location','southeast');
else
    %legend without extra plot
    lgd2=legend(sprintf('Airfoil with %.0f panels',No),'Streamlines','Location','southeast');
    
end
lgd2.FontSize=14;

%adding cl value to plot
if strcmp(Code,'2412')
    %special case
    annotation("textbox",[0.15 0.25 0 0],'FitBoxToText','on','String',['Lift coefficient is: ',num2str(cl(11,3))],'BackgroundColor','w')
else
    %other cases
    annotation("textbox",[0.15 0.25 0 0],'FitBoxToText','on','String',['Lift coefficient is: ',num2str(cl)],'BackgroundColor','w')
end


%saving current figure
string2=['NACA', num2str(Code), '_at_', num2str(Uinf), '_ms_', num2str(AoA), '_degrees_angle_of_attack_with_' ,num2str(No), '_panels_streamlines.png'];
saveas(fig2,string2);
hold off


%VECTOR FIELD PLOT
%plot airfoil
fig2=figure;
plot(xpointsc(1:No+1), zpointsc(1:No+1),'k','LineWidth',2);
axis equal;
hold on

%if the No is low, and the difference between No and Ni is greater than
%100, also plot the idealised airfoil
if  (No<50) && (abs(No-Ni)>100)
    plot(xpoints(1:Ni+1),zpoints(1:Ni+1),'r','LineWidth',2);
    checknum=0;
end

%plots vector field
quiv_res=25; %arbritary value, the lower this is the less arrows, but bigger arrows
%100 here is the mesh resolution used in the velocl function
inte=round(1:100/quiv_res:100);

Quiv=quiver(xstream(inte,inte),zstream(inte,inte),ui(inte,inte),vi(inte,inte),'LineWidth',1,'Color','b');

%Title
title(sprintf('NACA %s at %.0f m/s, %.0f degrees angle of attack, with %.0f panels',Code,Uinf,AoA,No),'FontSize',12);
xlabel('x - horizontal distance from leading edge in terms of x/c');
ylabel('z - vertical distance from leading edge in terms of z/c');
if (checknum==0)
    %legend if we added the extra plot
    lgd2=legend(sprintf('Airfoil with %.0f panels',No),'Idealised Airfoil','Vector Field','Location','southeast');
else
    %legend without extra plot
    lgd2=legend(sprintf('Airfoil with %.0f panels',No),'Vector Field','Location','southeast');
    
end
lgd2.FontSize=14;

%adding cl value to plot
if strcmp(Code,'2412')
    %special case
    annotation("textbox",[0.15 0.25 0 0],'FitBoxToText','on','String',['Lift coefficient is: ',num2str(cl(11,3))],'BackgroundColor','w')
else
    %other cases
    annotation("textbox",[0.15 0.25 0 0],'FitBoxToText','on','String',['Lift coefficient is: ',num2str(cl)],'BackgroundColor','w')
end

%saving current figure
string2=['NACA', num2str(Code), '_at_', num2str(Uinf), '_ms_', num2str(AoA), '_degrees_angle_of_attack_with_' ,num2str(No), '_panels_vector_field.png'];
saveas(fig2,string2);
hold off

