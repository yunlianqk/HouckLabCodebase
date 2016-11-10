function SetBW(pxa,bw)
% Get bw
    fprintf(pxa.instrhandle, [':SENSE:BAND ' num2str(bw) 'HZ']);
end