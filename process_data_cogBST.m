function [values,coordinates] = process_data_cogBST
%% process_data_cogBST
% process the data generated from letswave into brainstorm
%% Author : Samuel Louviot 
% samuel.louviot@univ-lorraine.fr
% sam.louviot@gmail.com
% date : December 2021
% CRAN UMR7039 CNRS Université de Lorraine 
% département BioSiS 
% Projet Neurosciences des systemes et de la cognition
%

prompt = {'Enter Patient Code','Results type (Z_score, SBL, SNR or other)'};
DataParameters = inputdlg(prompt,'Patient Identification',1,{'AAA_BB','Z_score'}); %Open a dialogbox to put the information

[FILENAMEp1, PATHNAMEp1, ~] = uigetfile('*.mat', 'Choose your P1 file'); %Open a window to choose your files
[FILENAMEp2, PATHNAMEp2, ~] = uigetfile('*.mat', 'Choose your P2 file');
[FILENAMEp3, PATHNAMEp3, ~] = uigetfile('*.mat', 'Choose your P3 file');
[FILENAMEcoord, PATHNAMEcoord, ~] = uigetfile({'*.txt',...
    'ASCII_NAME_XYZ (*.txt)'}, 'Choose the coordinates file');

structureP1 = load([PATHNAMEp1 FILENAMEp1]); %load the choosen files
structureP2 = load([PATHNAMEp2 FILENAMEp2]);
structureP3 = load([PATHNAMEp3 FILENAMEp3]);

TableP1 = structureP1.Table;
TableP2 = structureP2.Table;
TableP3 = structureP3.Table;

clear structureP1 structureP2 structureP3
%% letswave contacts

if (size(TableP1,1) ~= size(TableP2,1)) ||...
   (size(TableP1,1) ~= size(TableP3,1)) ||...
   (size(TableP2,1) ~= size(TableP3,1))
    
    ContinueNbContact = questdlg(['WARNING: The number of intracerebral contact are not the same',...
                              'The algorithme will take only contacts which are comon to P1, P2 and P3'...
                               'Do you want to continue?'],'Yes','No');

end

if exist('ContinueNbContact')
    switch ContinueNbContact
        case 'Yes'
           ComonContacts = intersect(intersect(TableP1(:,3),TableP2(:,3)),TableP3(:,3));
           [idxKeepP1,~] = ismember(ComonContacts,TableP1(:,3));
           [idxKeepP2,~] = ismember(ComonContacts,TableP2(:,3));
           [idxKeepP3,~] = ismember(ComonContacts,TableP3(:,3));
           
           TableP1(TableP1(~idxKeepP1,:)) = [];
           TableP2(TableP2(~idxKeepP2,:)) = [];
           TableP3(TableP3(~idxKeepP3,:)) = [];

        case 'No'
            return
        case 'Cancel'
            return
    end
end

letswave_contacts = TableP1(:,3);

%% Letswave dataprocessing

Values(:,1) = [TableP1{:,7}].';
Values(:,2) = [TableP2{:,7}].';
Values(:,3) = [TableP3{:,7}].';

% percentage(:,1) = (Values(:,2)-Values(:,1)).*100./Values(:,1); %P2 VS P1
% percentage(:,2) = (Values(:,3)-Values(:,1)).*100./Values(:,1); %P3 VS P1
% percentage(:,3) = (Values(:,3)-Values(:,2)).*100./Values(:,2); %P2 VS P3


%% Intracerebral coordinates generation in brainstorm
iStudy = db_add_condition(DataParameters{1,1}, DataParameters{2,1});
studyStruct = bst_get('Study', iStudy);
protocolStruct = bst_get('ProtocolInfo');
import_channel(iStudy,...
    [PATHNAMEcoord FILENAMEcoord],...
    'ASCII_NXYZ',...
    1,...
    1,...
    1,...
    [],...
    1);
coordinates = readtable([PATHNAMEcoord FILENAMEcoord]);
%% 

values = zeros([size(coordinates,1),1]);
[a,b] = ismember(coordinates{:,1},letswave_contacts);
values(a,:) = Values(b(a),:);

%%

sMatP1 = db_template('datamat');
sMatP2 = db_template('datamat');
sMatP3 = db_template('datamat');
% Fill the required fields of the structure
sMatP1.F       = values(:,1);
sMatP2.F       = values(:,2);
sMatP3.F       = values(:,3);

sMatP1.Comment = [DataParameters{2,1} '_raw_P1'];
sMatP2.Comment = [DataParameters{2,1} '_raw_P2'];
sMatP3.Comment = [DataParameters{2,1} '_raw_P3'];

sMatP1.ChannelFlag = ones(size(coordinates,1));
sMatP2.ChannelFlag = ones(size(coordinates,1));
sMatP3.ChannelFlag = ones(size(coordinates,1));

sMatP1.Time = 1;
sMatP2.Time = 1;
sMatP3.Time = 1;

% Create a new folder "Script" in subject "Test"
iStudy = db_add_condition(DataParameters{1,1}, DataParameters{2,1});
% Get the corresponding study structure
bst_get('Study', iStudy);
db_add(iStudy, sMatP1);
db_add(iStudy, sMatP2);
db_add(iStudy, sMatP3);

%%
% clear sMatP1 sMatP2 sMatP3
% sMatP1 = db_template('datamat');
% sMatP2 = db_template('datamat');
% sMatP3 = db_template('datamat');
% % Fill the required fields of the structure
% sMatP1.F       = percentage(:,1);
% sMatP2.F       = percentage(:,2);
% sMatP3.F       = percentage(:,3);
% 
% sMatP1.Comment = [DataPArameters{2,1} '_percentage_P1'];
% sMatP2.Comment = [DataPArameters{2,1} '_percentage_P2'];
% sMatP3.Comment = [DataPArameters{2,1} '_percentage_P3'];
% 
% sMatP1.ChannelFlag = ones(size(coordinates,1));
% sMatP2.ChannelFlag = ones(size(coordinates,1));
% sMatP3.ChannelFlag = ones(size(coordinates,1));
% 
% sMatP1.Time = 1;
% sMatP2.Time = 1;
% sMatP3.Time = 1;
% 
% % Get the corresponding study structure
% db_add(iStudy, sMatP1);
% db_add(iStudy, sMatP2);
% db_add(iStudy, sMatP3);
end