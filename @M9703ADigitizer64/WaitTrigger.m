function WaitTrigger( self )

device = self.instrID;

invoke(device.Waveformacquisitionlowlevelacquisition, 'abort');
invoke(device.Waveformacquisitionlowlevelacquisition, 'initiateacquisition');
end

