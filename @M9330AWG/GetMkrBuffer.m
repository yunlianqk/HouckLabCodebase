function buffer = GetMkrBuffer(self)
    warning('''mkraddwidth'' is deprecated. Use ''mkrbuffer'' instead.');
    buffer = self.mkrbuffer;
end