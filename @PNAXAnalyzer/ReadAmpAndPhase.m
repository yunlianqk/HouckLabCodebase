function [Adata Pdata] = ReadAmpAndPhase(pnax)
% Read the currently active trace's amplitude and phase. Resets format at
% end to whatever it was before reading.
    currentFormat = pnax.params.format;
    pnax.params.format = 'MLOG';
    Adata = pnax.ReadTrace();
    pnax.params.format = 'UPH';
    Pdata = pnax.ReadTrace();
    pnax.params.format = currentFormat;
end