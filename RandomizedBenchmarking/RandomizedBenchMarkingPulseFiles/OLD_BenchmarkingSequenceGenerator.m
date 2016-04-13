function [] = BenchmarkingSequenceGenerator(DragAmp)
%UNTITLED Uses ArbGaussianPulseGenerator
%   MARKED FOR DELETION 12/7/12

FolderPath = 'Sigma10ns';

% 0/1 means rotation around X/Y axis
PulseSequence = [...
    0 0; 0 0; 0 1; 0 1; 1 0;...
    1 0; 1 1; 1 1; 0 0; 0 0;...
    0 1; 0 1; 1 0; 1 0; 1 1;...
    1 1; 0 0; 0 1; 1 0; 1 1;...
    0 0; 0 0; 0 1; 0 1; 1 0;...
    1 0; 1 1; 1 1];

% each element takes values \pm 0, \pm .5, \pm 1
AmplitudeSequence = [...
    1 1;    1 -1;   1 1;    1 -1;   1 1;    ...
    1 -1;   1 1;    1 -1;   1 .5;   1 -.5;  ...
    1 .5;   1 -.5;  1 .5;   1 -.5;  1 .5;   ...
    1 -.5;  .5 1;   .5 1;   .5 1;   .5 1;   ...
    .5 .5;  .5 -.5; .5 .5;  .5 -.5; .5 .5;  ...
    .5 -.5; .5 .5;  .5 -.5];

nbrExp = length(PulseSequence);

for counter = 1:nbrExp,
    [dig_ch1 dig_ch2 dig_ch3] = ArbGaussianPulseGenerator(PulseSequence(counter,:), AmplitudeSequence(counter,:), DragAmp);
    length_ch1 = length(dig_ch1);
    
    % write spec pulse file
    fid = fopen([FolderPath '\qubit_ch1' num2str(counter) '.pat'], 'w');
    fwrite(fid, 'MAGIC 2000');
    fprintf(fid, '\n');
    fprintf(fid, ['#' num2str(length(num2str(length_ch1*2))) num2str(length_ch1*2)]);
    fwrite(fid, dig_ch1, 'int16');
    fclose(fid);
    
    % write rf pulse file
    fid2 = fopen([FolderPath '\qubit_ch2' num2str(counter) '.pat'], 'w');
    fwrite(fid2, 'MAGIC 2000');
    fprintf(fid2, '\n');
    fprintf(fid2, ['#' num2str(length(num2str(length_ch1*2))) num2str(length_ch1*2)]);
    fwrite(fid2, dig_ch2, 'int16');
    fclose(fid2);
    
    % write deriv spec pulse
    fid4 = fopen([FolderPath '\cavity_ch3' num2str(counter) '.pat'], 'w');
    fwrite(fid4, 'MAGIC 2000');
    fprintf(fid4, '\n');
    fprintf(fid4, ['#' num2str(length(num2str(length_ch1*2))) num2str(length_ch1*2)]);
    fwrite(fid4, dig_ch3, 'int16');
    fclose(fid4);
end

fid3 = fopen([FolderPath '\pulse_sequencer.seq'], 'w');
fprintf(fid3, 'MAGIC 3004\n');
fprintf(fid3, 'LINES %d\n', nbrExp);
for counter = 1:nbrExp,
    fprintf(fid3, ['"qubit_ch1' num2str(counter) '.pat","qubit_ch2' num2str(counter) '.pat","cavity_ch3' num2str(counter) '.pat","",1,1,1,0\n']);
end

fclose('all');
end

