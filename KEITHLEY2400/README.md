# KEITHLEY Model 2400 Series SourceMeter
To run the Python code in Linux, make sure [linux-gpib](http://linux-gpib.sourceforge.net/) driver is installed.

The MATLAB code for Windows is in folder [MATLABCode](./MATLABCode).
## Usage
### Open instrument
```python
from keithley import KEITHLEY2400
address = 30; % GPIB address
k2400 = KEITHLEY2400(address);
```

### Set/get current/voltage
```python
k2400.setI(1e-6)  # Set current source to 1 μA
k2400.setV(1e-3)  # Set voltage source to 1 mV
current = k2400.getI()  # Read current meter
voltage = k2400.getV()  # Read voltage meter
voltage, current = k2400.getVandI()  # Read both current and voltage
```

### Current sweep
```python
start = 0e-6  # Start current
stop = 5e-6  # Stop current
step = 50e-9  # Step
Vlist, Ilist = k2400.sweepI(start, stop, step)  # Sweep current and measure voltage
```
### Close instrument
```python
k2400.finalize()
```
