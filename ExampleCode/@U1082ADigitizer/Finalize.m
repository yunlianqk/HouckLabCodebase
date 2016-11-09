function Finalize(self)
% Close card
    AqD1_stopAcquisition(self.instrID);
    Aq_close(self.instrID);
    Aq_closeAll();
end