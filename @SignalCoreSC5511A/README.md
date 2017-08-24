# SignalCore SC5511A RF Signal Source
## Usage
### Open instrument
To find the address of the instrument,
```matlab
devices = SignalCoreSC5511A.FindDevices();
```
`device` will be a cell string containing addresses of the currently available devices. The address should be 8-character string.

To open the instrument,
```matlab
address = '10001689'; % Address should be 8-character string
rfgen = SignalCoreSC5511A(address);
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
#### *class* SignalCoreSC5511A < handle
* **Properties**: 
  * **address** (*string*): Address of the instrument
  * **frequency** (*float*): Frequency (in Hz) of the signal
  * **power** (*float*): Power (in dBm) of the signal
  * **output** (*1/0*): Output on/off
  * **ref** (*string*): Reference clock source. Can be 'INT' or 'EXT'.
  * **temperature** (*string, read-only*): Temperature of the instruement
* **Methods**:
  * **gen = SignalCoreSC5511A(address)**: Opens the instrument with `address` and creates an object `gen`
  * **gen.Finalize()**: Closes the instrument
  * **gen.SetFreq(freq)**: Sets the frequency
  * **gen.SetPower(power)**: Sets the power
  * **gen.SetRef(ref)**: Sets the reference source
  * **freq = gen.GetFreq()**: Gets the frequency
  * **power = gen.GetPower()**: Gets the power
  * **ref = gen.GetRef()**: Gets the reference source
  * **status = gen.GetStatus()**: Gets the status of the devices
  * **gen.PowerOn()**: Turns on power
  * **gen.PowerOff()**: Turns off power
  * **devices = SignalCoreSC5511A.FindDevices()**: Returns a cell string that contains the addresses of the connected instruments.