# LabBrick Signal Generator
## Usage

### Open instrument
To find the address of the instrument,
```matlab
devices = LabBrick.FindDevices();
```
`device` will be an array containing addresses of the currently available devices. The address should be a 4-digit integer.

To open the instrument,
```matlab
address = 1875; % Address should be 4-digit integer
rfgen = LabBrick(address);
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

## Class definition
#### *class* LabBrick < handle
* **Properties**: 
  * **address** (*string*): Address of the instrument
  * **freq** (*float*): Frequency (in Hz) of the signal
  * **power** (*float*): Power (in dBm) of the signal
  * **output** (*1/0*): Output on/off
  * **ref** (*string*): Reference clock source. Can be 'INT' or 'EXT'.
* **Methods**:
  * **gen = LabBrick(address)**: Opens the instrument with `address` and creates an object `gen`
  * **gen.Finalize()**: Closes the instrument
  * **gen.SetFreq(freq)**: Sets the frequency
  * **gen.SetPower(power)**: Sets the power
  * **gen.SetRef(ref)**: Sets the reference source
  * **freq = gen.GetFreq()**: Gets the frequency
  * **power = gen.GetPower()**: Gets the power
  * **ref = gen.GetRef()**: Gets the reference source
  * **gen.PowerOn()**: Turns on power
  * **gen.PowerOff()**: Turns off power
  * **info = gen.Info()**: Gets device information
  * **devices = LabBrick.FindDevices()**: Returns an array that contains the addresses of the connected instruments.
