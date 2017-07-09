# Holzworth HS9000 RF Synthesizers
## Usage
### Open instrument
To find the address of the instrument,
```matlab
devices = HolzworthHS9000.FindDevices();
```
`device` will be a string containing addresses of the currently connected devices.

To open the instrument,
```matlab
address = 'HS9004A-527-1'; % Address format: model-serial-channel
rfgen = HolzworthHS9000(address);
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
For pulse modulation, use
```matlab
rfgen.ModOn();
```

## Class definition
#### *class* E8267DGenerator < GPIBINSTR
* **Properties**: 
  * **address** (*string*): Address of the instrument
  * **frequency** (*float*): Frequency (in Hz) of the signal
  * **power** (*float*): Power (in dBm) of the signal
  * **phase** (*float*): Phase (in radians) of the signal
  * **output** (*1/0*): output on/off
  * **modulation** (*1/0*): modulation on/off

* **Methods**:
  * **gen = HolzworthHS9000(address)**: Opens the instrument with `address` and creates an object `gen`
  * **gen.Finalize()**: Closes the instrument
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