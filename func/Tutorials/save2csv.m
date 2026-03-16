load("PrototypesData_Rectangle.mat", 'SubjectsData');

writetable(SubjectsData, 'PrototypesData_Rectangle.csv')



SubjectsData_aSubject = SubjectsData(SubjectsData.ParticipantID==1, :);

writetable(SubjectsData, 'data-prototypes_shape-rectangle_nsubj-1.csv')

    % plot the actual dots and the responses
    prototypes_plot_dots(SubjectsData, 1);
    
    % plot the error vectors
    hold on;prototypes_plot_errorVectors(SubjectsData_aSubject, 1);