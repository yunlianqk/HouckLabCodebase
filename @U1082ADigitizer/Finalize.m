function Finalize(card)
% Close card
    AqD1_stopAcquisition(card.instrID);
    Aq_close(card.instrID);
    Aq_closeAll();
end