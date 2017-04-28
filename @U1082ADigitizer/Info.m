function s = Info(self)
    [~, name, serialnbr, ~, ~]= Aq_getInstrumentData(self.instrID);
    [~, version] = Aq_getInstrumentInfo(self.instrID, 'VersionUserDriver', ...
                                        'string');
    version = strrep(version, ', ', '.');
    s = sprintf('%s,%d,%s', name, serialnbr, version);
end