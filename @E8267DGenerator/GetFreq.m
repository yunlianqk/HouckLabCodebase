function freq = GetFreq(self)
% Get frequency
    fprintf(self.instrhandle, 'FREQuency?');
    freq = fscanf(self.instrhandle, '%f');
end