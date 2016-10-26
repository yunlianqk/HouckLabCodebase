function Finalize(self)
% Close card
    self.instrID.Close()
    display([class(self), ' object deleted.'])
end