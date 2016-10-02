# 33250A 80 MHz Waveform Generator
## Usage
### Open instrument
```matlab
address = 10; % GPIB address
triggen = AWG33250A(address);
```
### Set/get parameters
To set the frequency,
```matlab
triggen.SetFreq(1e6);
```
or
```matlab
triggen.frequency = 1e6;
```
To get peak-to-peak voltage,
```matlab
vpp = triggen.GetVpp();
```
or
```matlab
vpp = triggen.vpp;
```
## Class definition
#### *class* AWG33250A < GPIBINSTR
* **Properties**: 
  * **address** (*integer*, Read-only): GPIB address of the instrument
  * **instrhandle** (*GPIB object*, Read-only):  Handle to communicate with instrument
  * **waveform** (*string*): Waveform
  
    Possible values are 'SIN', 'SQUARE', 'RAMP', 'PULSE', 'NOISE', 'DC', 'USER'. Only sine and square waveforms are fully implemented.
  * **frequency**(*float*): Frequency
  
    For sine and square waves, the mininum frequency is 1 μHz and maximum is 80 MHz.
  * **period**(*float*): Period
  * **vpp**(*float*): Peak-to-peak voltage
  * **offset**(*float*): Offset voltage
  
    vpp and offset should satisfy vpp ≤ 2 × (5 - |offset|).
  * **dutycycle**(*float*): Duty cycle
  
    Allowed values:
    - 20% to 80% (frequency ≤ 25 MHz)
    - 40% to 60% (25 MHz < frequency ≤ 50 MHz)
    - 50% (frequency > 50 MHz)
* **Methods**:
  * **triggen = AWG33250A(address)**: Opens the instrument with `address` and creates an object `triggen`
  * **triggen.SetWaveform(waveform)**: Sets the waveform
  * **triggen.SetFreq(frequency)**: Sets the frequency
  * **triggen.SetPeriod(period)**: Sets the period
  * **triggen.SetVpp(vpp)**: Sets peak-to-peak voltage
  * **triggen.SetOffset(offset)**: Sets offset voltage
  * **triggen.SetDutyCycle(dutycycle)**: Sets duty cycle
  * **waveform = triggen.GetWaveform()**: Gets the waveform
  * **frequency = triggen.GetFreq()**: Gets the frequency
  * **period = triggen.GetPeriod()**: Gets the period
  * **vpp = triggen.GetVpp()**: Gets peak-to-peak voltage
  * **offset = triggen.GetOffset()**: Gets offset voltage
  * **dutycycle = triggen.GetDutyCycle()**: Gets duty cycle
  * **triggen.PowerOn()**: Turns on output
  * **triggen.PowerOff()**: Turns off output
