# YOKOGAWA GS200 DC Voltage/Current Source
## Usage
### Open instrument
```matlab
address = 4; % GPIB address
yoko = YOKOGS200(address);
```
### Set ramping parameters
```matlab
yoko.rampstep = 0.002;      % Voltage increment for each step
yoko.rampinterval = 0.01;   % Time interval between 2 steps
```
### Set/get voltage
To set voltage,
```matlab
yoko.SetVoltage(0.5);
```
or
```matlab
yoko.voltage = 0.5;
```
To get voltage,
```matlab
voltage = yoko.GetVoltage();
```
or
```matlab
voltage = yoko.voltage;
```
## Class definition
#### *class* YOKOGS200 < GPIBINSTR
* **Properties**: 
  * **address** (*integer*, Read-only): GPIB address of the instrument
  * **instrhandle** (*GPIB object*, Read-only): Handle to communicate with instrument
  * **rampstep** (*float*): Voltage/current increment for each step, in volts/amperes
  * **rampinterval** (*float*): Time interval between 2 steps, in seconds
  * **voltage** (*float*): Output voltage, in volts
  * **current** (*float*): Output current, in amperes
* **Methods**:
  * **yoko = YOKOGS200(address)**: Opens the instrument with `address` and creates an object `yoko`
  * **yoko.SetVoltge(voltage)**: Sets the voltage
  * **voltage = yoko.GetVoltage()**: Gets the voltage
  * **yoko.SetCurrent(current)**: Sets the current
  * **current = yoko.GetCurrent()**: Gets the current
  * **yoko.PowerOn()**: Turns on output
  * **yoko.PowerOff()**: Turns off output
