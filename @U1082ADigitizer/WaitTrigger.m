function WaitTrigger(self)
    AqD1_stopAcquisition(self.instrID);
    AqD1_acquire(self.instrID);
    self.waittrig = 1;
end