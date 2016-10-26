"""
This code is based on the Python API provided by linux-gpib
and has only be tested on Python 2.7.
"""
import gpib
import time


class KEITHLEY2400(object):
    """
    Class for communicating with Keithley 2400.

    Parameters
    ----------
    address : int, optional
        (Primary) GPIB address of the instrument.
    buffsize : int, optional
        Buffer size (in bytes) for reading data.

    Attributes
    ----------
    instrID : int
        GPIB handle to communicate with hardware module.
    buffsize : int
        Buffer size (in bytes) for reading data.
    current : float
        Set or measured current value (in amps).
    voltage : float
        Set or measured voltage value (in volts).

    Examples
    --------
    >>> instr = KEITHLEY2400()
    >>> instr = KEITHLEY2400(30, buffsize=1024)
    
    Set voltage/current source:
    
    >>> instr.voltage = 1e-3
    >>> instr.current = 1e-6
    
    Get measured voltage/current:
    
    >>> measuredV = instr.voltage
    >>> measuredI = instr.current
    """
    def __init__(self, address=None, buffsize=8096):
        self.buffsize = buffsize
        try:
            if address:
                # If address is provided, find device by address
                instrID = gpib.dev(0, address)
            else:
                # Otherwise find device by name
                # The name 'keithley2400' is defined in /etc/gpib.conf
                instrID = gpib.find('keithley2400')
            # Acquire instrument identity
            gpib.write(instrID, '*IDN?')
            info = gpib.read(instrID, self.buffsize)
            # Make sure it is Keithley 2400
            if ('KEITHLEY' and '2400') in info:
                # Pass instrID
                self.instrID = instrID
                # Reset instrument
                gpib.write(self.instrID, '*RST')
                print(self.__class__.__name__ + ' object created.')
            else:
                raise ValueError('Failed to find instrument.')
        except:
                print('Could not find instrument.')

    def finalize(self):
        """Close instrument."""
        try:
            gpib.close(self.instrID)
        except:
            pass
        print(self.__class__.__name__ + ' object finalized.')

    def reset(self):
        """Reset instrument."""
        gpib.write(self.instrID, '*RST')

    def clrBuffer(self):
        """Clear buffer."""
        gpib.write(self.instrID, ':TRAC:FEED:CONT NEVER')
        gpib.write(self.instrID, ':TRAC:CLE')

    def powerOn(self):
        """Turn on output."""
        gpib.write(self.instrID, ':OUTP ON')

    def powerOff(self):
        """Turn off output."""
        gpib.write(self.instrID, ':OUTP OFF')

    def setI(self, current=0.0, compliance=5.0):
        """
        Set current source.
        
        Parameters
        ----------
        current : float
            Sets value (in amps) for the current source.
        compliance : float, optional
            Sets the compliance voltage (in volts) for the current source.
            Default value is 5 V.
            
        Examples
        --------
        >>> setI(1e-6, compliance=1.0)
        """
        gpib.write(self.instrID, ':SOUR:FUNC CURR')
        gpib.write(self.instrID, ':SOUR:CURR:MODE FIX')
        # Default compliance voltage is 5 V
        gpib.write(self.instrID, ':SENS:VOLT:PROT %f' % compliance)
        gpib.write(self.instrID, ':SOUR:CURR:LEV %f' % current)

    def getI(self):
        """
        Measure current.
        
        Returns
        -------
        Measured value (in amps) from the current meter.
        """
        gpib.write(self.instrID, ':SENS:FUNC "CURR"')
        gpib.write(self.instrID, ':SENS:FUNC:OFF "VOLT"')
        gpib.write(self.instrID, ':SENS:CURR:RANG:AUTO ON')
        gpib.write(self.instrID, ':FORM:ELEM CURR')
        gpib.write(self.instrID, ':OUTP ON')
        gpib.write(self.instrID, ':READ?')
        try:
            current = float(gpib.read(self.instrID, self.buffsize))
            return current
        except:
            raise ValueError('Failed to read current.')

    current = property(getI, setI)

    def setV(self, voltage=0.0, compliance=5e-3):
        """
        Set voltage source.
        
                
        Parameters
        ----------
        voltage : float
            Sets value (in volts) for the voltage source.
        compliance : float, optional
            Sets the compliance current (in amps) for the voltage source.
            Default value is 5 mA.
            
        Examples
        --------
        >>> setV(1e-3, compliance=2e-3)
        """
        gpib.write(self.instrID, ':SOUR:FUNC VOLT')
        gpib.write(self.instrID, ':SOUR:VOLT:MODE FIX')
        # Default compliance current is 5 mA
        gpib.write(self.instrID, ':SENS:CURR:PROT %f' % compliance)
        gpib.write(self.instrID, ':SOUR:VOLT:LEV %f' % voltage)

    def getV(self):
        """
        Measure voltage.
        
        Returns
        -------
        Measured value (in volts) from the voltage meter.
        """
        gpib.write(self.instrID, ':SENS:FUNC "VOLT"')
        gpib.write(self.instrID, ':SENS:FUNC:OFF "CURR"')
        gpib.write(self.instrID, ':SENS:VOLT:RANG:AUTO ON')
        gpib.write(self.instrID, ':FORM:ELEM VOLT')
        gpib.write(self.instrID, ':OUTP ON')
        gpib.write(self.instrID, ':READ?')
        try:
            voltage = float(gpib.read(self.instrID, self.buffsize))
            return voltage
        except:
            raise ValueError('Failed to read voltage.')

    voltage = property(getV, setV)

    def getVandI(self):
        """
        Measure voltage and current.
        
        Returns
        -------
        A tuple (voltage, current) of measured value (in volts, amps)
        from the meter.
        """
        gpib.write(self.instrID, ':SENS:FUNC "VOLT"')
        gpib.write(self.instrID, ':SENS:FUNC "CURR"')
        gpib.write(self.instrID, ':SENS:VOLT:RANG:AUTO ON')
        gpib.write(self.instrID, ':SENS:CURR:RANG:AUTO ON')
        gpib.write(self.instrID, ':FORM:ELEM VOLT,CURR')
        gpib.write(self.instrID, ':OUTP ON')
        gpib.write(self.instrID, ':READ?')
        try:
            datalist = (gpib.read(self.instrID, self.buffsize)).split(',')
            voltage = float(datalist[0])
            current = float(datalist[1])
            return voltage, current
        except:
            raise ValueError('Failed to read voltage or current')

    def sweepI(self, start=0.0, stop=5e-6, step=0.05e-6, compliance=5.0,
               timeout=None):
        """
        Sweep current and measure voltage.
        
        Parameters
        ----------
        start : float
            Start value (in amps) for current sweep.
        stop : float
            Stop value (in amps) for current sweep.
        step : float
            Step (in amps) for current sweep.
        compliance : float, optional
            Compliance voltage (in volts) for current source.
            Default value is 5 V.
        timeout : float, optional
            Wait time (in seconds) for current sweep.
            
        Returns
        -------
        A tuple (voltage, current).
        
        voltage : list of float
            Measured value (in volts) from the voltage meter.
        current : list of float
            Output current (in amps) from the current source.
        
        Examples
        --------
        sweepI(0.0, 5.0e-6, 0.05e-6, compliance=1.0)
        """
        # SOURCE config
        gpib.write(self.instrID, '*RST')  # reset
        gpib.write(self.instrID, ':SOUR:FUNC:MODE CURR')  # current source
        gpib.write(self.instrID, ':SOUR:CURR:STAR %s' % start)  # start current
        gpib.write(self.instrID, ':SOUR:CURR:STOP %s' % stop)  # stop current
        gpib.write(self.instrID, ':SOUR:CURR:STEP %s' % step)  # step current
        gpib.write(self.instrID, ':SOUR:CLE:AUTO ON')  # source auto output-off
        gpib.write(self.instrID, ':SOUR:CURR:MODE SWE')  # current sweep mode
        gpib.write(self.instrID, ':SOUR:SWE:SPAC LIN')  # linear staircase sweep
        gpib.write(self.instrID, ':SOUR:DEL:AUTO OFF')
        gpib.write(self.instrID, ':SOUR:DEL 0.1')  # 100 ms source delay
        gpib.write(self.instrID, ':SOUR:SWE:POIN?')
        numPoints = int(gpib.read(self.instrID, self.buffsize))
        # SENSE configuration
        gpib.write(self.instrID, ':SENS:FUNC "VOLT:DC"')  # measure voltage
        gpib.write(self.instrID, ':SENS:VOLT:PROT:LEV %f' % compliance)  #  compliance voltage
        gpib.write(self.instrID, ':SENS:FUNC:CONC OFF')  # turn off concurrent functions
        gpib.write(self.instrID, ':SENS:VOLT:RANG:AUTO ON')  # auto voltage range
        # FILTER configuration
        gpib.write(self.instrID, ':SENS:AVER:STAT ON')  # turn on filter
        gpib.write(self.instrID, ':SENS:AVER:TCON REP')  # repetitive type
        gpib.write(self.instrID, ':SENS:AVER:COUN 100')  # filter count

        gpib.write(self.instrID, ':SENS:VOLT:NPLC 0.01')  # power line cycles per integration
        gpib.write(self.instrID, ':FORM:ELEM:SENS VOLT,CURR')  # read current and voltage
        gpib.write(self.instrID, ':TRIG:DEL 0')
        gpib.write(self.instrID, ':SYST:AZER:STAT OFF')  # disable autozero
        gpib.write(self.instrID, ':SYST:TIME:RES:AUTO ON')
        # Buffer configuration
        gpib.write(self.instrID, ':TRAC:TST:FORM ABS')  # timestamp format ABSolute: ref to first buffer reading
        gpib.write(self.instrID, ':TRAC:POIN %d' % numPoints)  # store # readings in buffer
        gpib.write(self.instrID, ':TRAC:FEED:CONT NEXT')  # fill buffer and stop
        gpib.write(self.instrID, ':TRIG:COUN %d' % numPoints)  # numb of pulses = number of sweep point
        # Start measurement
        gpib.write(self.instrID, ':OUTP ON')  # turn on output
        gpib.write(self.instrID, ':INIT')  # trigger sweep
        # Wait for sweep to finish before fetching data
        # This avoids timeout errors
        if timeout is None:
            timeout = 0.4*numPoints
        time.sleep(timeout)
        # Read data
        try:
            gpib.write(self.instrID, ':TRAC:DATA?')  # read buffer
            data = gpib.read(self.instrID, self.buffsize)
            datalist = [float(x) for x in data.split(',')]
            Vlist = datalist[0::2]
            Ilist = datalist[1::2]
            return Vlist, Ilist
        except:
            gpib.write(self.instrID, ':TRAC:FEED:CONT NEVER')
            gpib.write(self.instrID, ':TRAC:CLE')
            raise ValueError('Failed to read data')
