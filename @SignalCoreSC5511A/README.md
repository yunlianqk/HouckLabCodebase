# SignalCore SC5511A RF Signal Source
## Usage
The USB driver is [`drivers/SignalCore_driver/sc5511a.inf`](../drivers/SignalCore_driver/sc5511a.inf). See [README](./SC5511A_ReadMe.txt) for information.

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
  * **freq** (*float*): Frequency (in Hz) of the signal
  * **power** (*float*): Power (in dBm) of the signal
  * **output** (*1/0*): Output on/off
  * **refin** (*string*): Reference clock source. Can be 'INT' or 'EXT'.
  * **refout** (*string*): Reference output. Can be '10MHz' or '100MHz'.
  * **temperature** (*string, read-only*): Temperature (in celsius) of the instruement
* **Methods**:
  * **gen = SignalCoreSC5511A(address)**: Opens the instrument with `address` and creates an object `gen`
  * **gen.Finalize()**: Closes the instrument
  * **gen.SetFreq(freq)**: Sets the frequency
  * **gen.SetPower(power)**: Sets the power
  * **gen.SetRefIn(refin)**: Sets the reference source
  * **gen.SetRefOut(refout)**: Sets the reference output
  * **freq = gen.GetFreq()**: Gets the frequency
  * **power = gen.GetPower()**: Gets the power
  * **refin = gen.GetRefIn()**: Gets the reference source
  * **refout = gen.GetRefOut()**: Gets the reference output
  * **gen.PowerOn()**: Turns on power
  * **gen.PowerOff()**: Turns off power
  * **status = gen.GetStatus()**: Gets the status of the devices
  * **info = gen.Info()**: Gets device information
  * **devices = SignalCoreSC5511A.FindDevices()**: Returns a cell string that contains the addresses of the connected instruments.