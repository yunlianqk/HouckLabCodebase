function buffer = GetMkrBuffer(self)
    warning('M9330A:getmkraddwidth', ...
            '''mkraddwidth'' is deprecated. Use ''mkrbuffer'' instead.');
    buffer = self.mkrbuffer;
end