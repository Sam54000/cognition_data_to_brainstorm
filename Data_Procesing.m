%% Data_Processing for cognition data to brainstorm
% Author : Samuel Louviot 
% samuel.louviot@univ-lorraine.fr
% sam.louviot@gmail.com
% date : December 2021
% CRAN UMR7039 CNRS Université de Lorraine 
% département BioSiS 
% Projet Neurosciences des systemes et de la cognition
% 
% This program need to be run section by section
%%

% You need 
% - SEEG file (ELECTRODSE COORDINATES) exported from brainstorm you will
%   name bst_seeg
% - table exported from letswave (rename each table with its appopriate
%   name P1, P2 and P3)
val(:,1) = cellfun(@(x) str2double(x), tableP1(:,7)); %raw values P1
val(:,2) = cellfun(@(x) str2double(x), tableP2(:,7)); %raw values P2
val(:,3) = cellfun(@(x) str2double(x), tableP3(:,7)); %raw values P3
tableP1(:,7) = num2cell(val(:,1));
tableP2(:,7) = num2cell(val(:,2));
tableP3(:,7) = num2cell(val(:,3));

%% Data preparation
% Import from brainstorm the SEEG file

PatientName = 'LIN_NA'; %Put the patient code
comment = 'Z_scoreP3'; %name of the file Put the results of the calculation (SBL or Z score or SNR)
experimentName = 'Percentage'; %Name of the folder Put raw values if you want to plot only for P1 or P2 or P3
                               %Put percentage if you want to plot the
                               %percentage of modulation between tDCS
                               %states (P1/P2/P3)


 %% If you need to calculate percentage

percentage(:,1) = (val(:,2)-val(:,1)).*100./val(:,1); %P2 VS P1
percentage(:,2) = (val(:,3)-val(:,1)).*100./val(:,1); %P3 VS P1
percentage(:,3) = (val(:,3)-val(:,2)).*100./val(:,1); %P2 VS P3

perc1 = tableP1;
perc2 = tableP1;
perc3 = tableP1;

perc1(:,7) = num2cell(percentage(:,1));
perc2(:,7) = num2cell(percentage(:,2));
perc3(:,7) = num2cell(percentage(:,3));


%% Export to matlab
% You will have to run this function for each tDCS state you have (P1,P2
% and P3) or for each percentage comparison you have (P1 vs P2, P1 vs P3
% and P2 vs P3)

letswave_table = perc3; % if you want to export to brainstorm the raw value of Pn put Pn (n = 1;2 or 3) here, or if
% you want to export to brainstorm the percentage, replace tableP1 by percN
% (with N = 1;2 or 3)
values = convert_letswave_to_brainstorm(bst_seeg,PatientName,experimentName,letswave_table,comment);