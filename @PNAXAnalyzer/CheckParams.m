function iscorrect = CheckParams(~, params)
% Check the correctness of some parameters
    
    iscorrect = 1;
    % Check params class
    classlist = {'paramlib.pnax.trans', ...
                 'paramlib.pnax.spec', ...
                 'paramlib.pnax.psweep'};
    if ~ismember(class(params), classlist)
        display('Error: params needs to be an object in paramlib.pnax');
        iscorrect = 0;
    end
    % Check 'meastype'
    measpattern = '[Ss][1-4][1-4]';
    if isempty(regexp(params.meastype, measpattern, 'once'))
        display('Error: meastype needs to be ''Sij'', 1 <= i, j <= 4');
        iscorrect = 0;
    end
    
    % Check 'format'
    formatlist = {'MLOG', 'MLIN', 'PHAS', 'UPH', 'REAL', 'IMAG', 'SMIT', ...
                  'SADM', 'SWR', 'GDEL', 'KELV', 'FAHR', 'CELS'};
    if (~ismember(upper(params.format), formatlist))
        display(['Error: format needs to be one of ', strjoin(formatlist, ', ')]);
        iscorrect = 0;
    end
end