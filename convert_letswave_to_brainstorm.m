function values = convert_letswave_to_brainstorm(bst_seeg,PatientName,experimentName,letswave_table,comment)
%% This function makes possible to convert data exported from letswave
% into a brainstorm compatible format.
% Input: 
%        - bst_seeg: the electrodes file imported into the matlab workspace 
%                    from brainstorm (right clic on the electrode's file 
%                    and export to matlab)
%        - letswave_table the table imported from letswave
%        - PatientName   : the patient code
%        - experimentName: The name of the experiment
%        - comment       : The file name displayed in brainstorm
% Output: a brainstorm formated file to import then into brainstorm.
%
% Example of usage: values = convert_letswave_to_brainstorm(bst_seeg,'LOU_SA','Raw_data',letswave_table,'Z_score')
%% Author : Samuel Louviot 
% samuel.louviot@univ-lorraine.fr
% sam.louviot@gmail.com
% date : December 2021
% CRAN UMR7039 CNRS Université de Lorraine 
% département BioSiS 
% Projet Neurosciences des systemes et de la cognition
%
    contacts_from_data = letswave_table(:,3); %export the data
    contacts_from_brainstorm = {bst_seeg.Channel.Name}.'; %export the contacts name
    [a,b] = ismember(contacts_from_brainstorm,contacts_from_data); %check  contact is where
    tmpVal = [letswave_table{:,7}].';
    values = zeros([size(contacts_from_brainstorm,1),1]); %prepare matrix data
    values(a,:) = tmpVal(b(a),1);
    % Initialize an empty "matrix" structure
    sMat = db_template('datamat');
    % Fill the required fields of the structure
    sMat.F       = values;
    sMat.Comment = comment;
    sMat.ChannelFlag = ones(size({bst_seeg.Channel.Name}.',1));
    sMat.Time = 1;
    % Create a new folder "Script" in subject "Test"
    iStudy = db_add_condition(PatientName, experimentName);
    % Get the corresponding study structure
    sStudy = bst_get('Study', iStudy);
    OutputFile = db_add(iStudy, sMat);
end

