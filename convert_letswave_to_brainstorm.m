% This function makes possible to convert your data exported from letswave
% into a brainstorm valid format.
% Input: 
%        - bst_seeg which is the electrodes file imported from brainstorm
%        (right clic on the electrode's file and export to matlab)
%        - letswave_table the table imported from letswave
% Output: a brainstorm formated file to import then into brainstorm.

function values = convert_letswave_to_brainstorm(bst_seeg,PatientName,experimentName,letswave_table,comment)
    contacts_from_data = letswave_table(:,3); %export the data
    contacts_from_brainstorm = {bst_seeg.Channel.Name}.'; %export the contacts name
    [a,b] = ismember(contacts_from_brainstorm,contacts_from_data); %check hich contact is where
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

