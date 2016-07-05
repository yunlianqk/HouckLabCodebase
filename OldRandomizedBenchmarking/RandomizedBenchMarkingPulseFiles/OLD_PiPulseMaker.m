function [] = PiPulseMaker()
%UNTITLED2 Summary of this function goes here
%   MARKED FOR DELETION 12/7/12

PulseSequence = [0 0];
AmplitudeSequence = [0 1];
[dig_ch1 dig_ch2 dig_ch3] = ArbGaussianPulseGenerator(PulseSequence, AmplitudeSequence, .5); 

length_ch1 = length(dig_ch1);


% write spec pulse file
fid = fopen('Sigma10ns\pipulse_qubit_ch1.pat', 'w');
fwrite(fid, 'MAGIC 2000');
fprintf(fid, '\n');
fprintf(fid, ['#' num2str(length(num2str(length_ch1*2))) num2str(length_ch1*2)]);
fwrite(fid, dig_ch1, 'int16');
fclose(fid);
% 
% write rf pulse file
fid2 = fopen('Sigma10ns\pipulse_qubit_ch2.pat', 'w');
fwrite(fid2, 'MAGIC 2000');
fprintf(fid2, '\n');
fprintf(fid2, ['#' num2str(length(num2str(length_ch1*2))) num2str(length_ch1*2)]);
fwrite(fid2, dig_ch2, 'int16');
fclose(fid2);
% 
% write deriv spec pulse
fid4 = fopen('Sigma10ns\pipulse_cavity_ch3.pat', 'w');
fwrite(fid4, 'MAGIC 2000');
fprintf(fid4, '\n');
fprintf(fid4, ['#' num2str(length(num2str(length_ch1*2))) num2str(length_ch1*2)]);
fwrite(fid4, dig_ch3, 'int16');
fclose(fid4);
% 
fclose('all');
end

