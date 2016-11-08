function SetVideo(pxa,video)
% Set video
    fprintf(pxa.instrhandle, [':SENSE:BAND:video  ' num2str(video) 'HZ']);
end