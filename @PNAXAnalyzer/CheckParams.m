function CheckParams(~, params)
% Check the correctness of some parameters

    % Check 'meastype'
    measpattern = '[Ss][1-4][1-4]';
    if isempty(regexp(params.meastype, measpattern, 'once'))
        error('Error: meastype needs to be ''Sij'', 1 <= i, j <= 4');
    end
    
    % Check 'format'
    formatlist = {'MLOG', 'MLIN', 'PHAS', 'UPH', 'REAL', 'IMAG', 'SMIT', ...
                  'SADM', 'SWR', 'GDE', 'KELV', 'FAHR', 'CELS'};
    if (~ismember(upper(params.format), formatlist))
        error(['Error: format needs to be one of ', strjoin(formatlist, ', ')]);
    end
end