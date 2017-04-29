function s = Info(self)
    device = self.instrhandle.DeviceSpecific;
    s = sprintf('%s,%s,%s,%s', device.Identity.InstrumentManufacturer, ...
                               device.Identity.InstrumentModel, ...
                               device.System.SerialNumber, ...
                               device.Identity.Revision);
end