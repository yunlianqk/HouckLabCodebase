function Initialize(self)
% Open instrhandle
    initoptions = 'QueryInstrStatus=true,DriverSetup=DDS=false';
    self.instrhandle.Initialize(self.address, true, true, initoptions);
end