function params = GetParams(pnax)
% Return a struct that contains the parameters of the active trace
    
    if isempty(pnax.GetActiveChannel())
        params = [];
    else
        params.channel = pnax.GetActiveChannel();
        params.trace = pnax.GetActiveTrace();
        meas = pnax.GetActiveMeas();
        
        fprintf(pnax.instrhandle, 'SENSe%d:FOM:STATe?', params.channel);
        isspec = num2str(fscanf(pnax.instrhandle, '%s'));
        if isspec
            fprintf(pnax.instrhandle, 'SENse%d:FOM:RANGe4:FREQuency:STARt?', ...
                    params.channel);
            params.start = fscanf(pnax.instrhandle, '%g');

            fprintf(pnax.instrhandle, 'SENse%d:FOM:RANGe4:FREQuency:STOP?', ...
                    params.channel);
            params.stop = fscanf(pnax.instrhandle, '%g');
            
            fprintf(pnax.instrhandle, 'SOURce%d:POWer3?', ...
                    params.channel);
            params.power = fscanf(pnax.instrhandle, '%g');
            
            fprintf(pnax.instrhandle, 'SENSe%d:FREQuency:CW?', ...
                    params.channel);
            params.cwfreq = fscanf(pnax.instrhandle, '%g');                

            fprintf(pnax.instrhandle, 'SOURce%d:POWer1?', ...
                    params.channel);
            params.cwpower = fscanf(pnax.instrhandle, '%g');                
        else
            fprintf(pnax.instrhandle, 'SENSe%d:FREQuency:STARt?', params.channel);
            params.start = fscanf(pnax.instrhandle, '%g');
            
            fprintf(pnax.instrhandle, 'SENSe%d:FREQuency:STOP?', params.channel);
            params.stop = fscanf(pnax.instrhandle, '%g');            
        end
        fprintf(pnax.instrhandle, 'SENSe%d:SWEep:POINts?', params.channel);
        params.points = fscanf(pnax.instrhandle, '%g');
        
        fprintf(pnax.instrhandle, 'SOURce%d:POWer1?', params.channel);
        params.power = fscanf(pnax.instrhandle, '%g');
        
        fprintf(pnax.instrhandle, 'SENSe%d:BANDwidth?', params.channel);
        params.ifbandwidth = fscanf(pnax.instrhandle, '%g');
        
        fprintf(pnax.instrhandle, 'SENSe%d:AVERage:COUNt?', params.channel);
        params.averages = fscanf(pnax.instrhandle, '%d');
        
        fprintf(pnax.instrhandle, 'CALCulate%d:FORMat?', params.channel);
        params.format = fscanf(pnax.instrhandle, '%s');
                
%         tempstr = strsplit(meas, '_');
%         params.meastype = tempstr{2};
        params.meastype = pnax.GetMeasType(meas);
    end
end

