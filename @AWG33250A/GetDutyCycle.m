function dutycycle = GetDutyCycle(triggen)
% Get duty cycle (in percent)
    fprintf(triggen.instrhandle, 'FUNCtion:SQUare:DCYCle?');
    dutycycle = fscanf(triggen.instrhandle, '%f');
end
