# E8267D (E8257D) Signal Generator
## Usage
### Open instrument
```matlab
address = 'GPIB0::23::0::INSTR'; % GPIB address
rfgen = E8267DGenerator(address);
```
### Usage
To set frequency,
```matlab
rfgen.SetFreq(8e9);
```
or
```matlab
rfgen.freq = 8e9;
```
To get power,
```matlab
power = rfgen.GetPower();
```
or
```matlab
power = rfgen.power;
```
For continuous-wave generation, use
```matlab
rfgen.ModOff();
```
For I/Q modulation,
```matlab
rfgen.ModOn();
```
turns on modulation, wide-band I/Q modulation, pulse modulation and turns off ALC. These four configurations can also be set individually (E8257D model does not have wide-band I/Q modulation):
```matlab
rfgen.modulation = 1;
rfgen.iq = 1;
rfgen.pulsed = 1;
rfgen.alc = 0;
```

## Class definition
#### *class* E8267DGenerator < GPIBINSTR
* **Properties**: 
  * **address** (*string*): GPIB address of the instrument
  * **instrhandle** (*GPIB object*):  Handle to communicate with instrument
  * **freq** (*float*): Frequency (in Hz) of the signal
  * **power** (*float*): Power (in dBm) of the signal
  * **phase** (*float*): Phase (in radians) of the signal
  * **output** (*1/0*): Output on/off
  * **modulation** (*1/0*): Modulation on/off
  * **iq** (*1/0*): Wideband digital modulation on/off (only available in E8267D models)
  * **iqadjust** (*1/0*): I/Q adjustment on/off (only available in E8267D models)
  * **ioffset** (*float*): I offset (in volts) for I/Q adjustment (only available in E8267D models)
  * **qoffset** (*float*): Q offset (in volts) for I/Q adjustment (only available in E8267D models)
  * **pulse** (*1/0*): Pulse modulation on/off
  * **alc** (*1/0*): ALC (automatic leveling control) on/off
* **Methods**:
  * **gen = E8267DGenerator(address)**: Opens the instrument with `address` and creates an object `gen`
  * **gen.SetFreq(freq)**: Sets the frequency
  * **gen.SetPower(power)**: Sets the power
  * **gen.SetPhase(phase)**: Sets the phase
  * **freq = gen.GetFreq()**: Gets the frequency
  * **power = gen.GetPower()**: Gets the power
  * **phase = gen.GetPhase()**: Gets the phase
  * **gen.PowerOn()**: Turns on power
  * **gen.PowerOff()**: Turns off power
  * **gen.ModOn()**: Turns on modulation, pulse and I/Q, turns off ALC
  * **gen.ModOff()**: Turns off modulation, pulse and I/Q, turns on ALC
  * **gen.ShowError()**: Display and clear all error messages
