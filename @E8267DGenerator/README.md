# E8267D Signal Generator
## Usage
### Open instrument
```matlab
address = 23; % GPIB address
rfgen = E8267DGenerator(address);
```
### Set/get frequency/power
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
## Class definition
#### *class* E8267DGenerator < GPIBINSTR
* **Properties**: 
  * **address** (*integer*, Read-only): GPIB address of the instrument
  * **instrhandle** (*GPIB object*, Read-only):  Handle to communicate with instrument
  * **frequency** (*float*): Frequency of the signal
  * **power** (*float*): Power of the signal
* **Methods**:
  * **gen = E8267DGenerator(address)**: Opens the instrument with `address` and creates an object `gen`
  * **gen.SetFreq(freq)**: Sets the frequency
  * **gen.SetPower(power)**: Sets the power
  * **freq = gen.GetFreq()**: Gets the frequency
  * **power = gen.GetPower()**: Gets the power
  * **gen.PowerOn()**: Turns on power
  * **gen.PowerOff()**: Turns off power
  * **gen.ModOn()**: Turns on modulation
  * **gen.ModOff()**: Turns off modulation
  * **gen.ShowError()**: Display and clear all error messages
