function Finalize(self)
% Close instrhandle
    if self.instrhandle.Initialized == 1
        self.instrhandle.Close();
    end
end