function SetDutyCycle(triggen, dutycycle)
% Set duty cycle (in percent)
    freq = triggen.GetFreq();
    
    if (freq <= 25e6 && (dutycycle < 20 || dutycycle > 80))
        display('Error: Duty cycle needs to be between 20% and 80%');
        return;
    end
    if ((freq > 25e6 && freq <= 50e6) && (dutycycle < 40 || dutycycle > 60))
        display('Error: Duty cycle needs to be between 40% and 60%');
        return;
    end    
    if (freq > 50e6 && dutycycle ~= 50)
        display('Error: Duty cycle can only be 50%');
        return;
    end
    
    fprintf(triggen.instrhandle, 'FUNCtion:SQUare:DCYCle %g', dutycycle);
end