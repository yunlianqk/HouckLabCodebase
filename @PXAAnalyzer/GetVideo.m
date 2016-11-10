function video = GetVideo(pxa)
% Get video
    fprintf(pxa.instrhandle, ':SENSE:BAND:video?');
    video = fscanf(pxa.instrhandle, '%f');
end