# M9703A AXIe High-Speed Digitizer/
## Usage
See also the [example code](../ExampleCode/ExampleCode_M9703A.m).
### Open instrument
```matlab
address = 'PXI0::CHASSIS1::SLOT2::FUNC0::INSTR'; % PXI address
card = M9703ADigitizer(address);  % create object
```
### Set/get parameters
To set the parameters, first create a [**paramlib.m9703a**](#params) *object* that contains the parameters:
```matlab
cardparams = paramlib.m9703a();
cardparams.samplerate=1.6e9;   % Hz units
cardparams.samples=1.6e9*1e-6;    % samples for a single trace
cardparams.averages=2000;  % software averages=number of traces acquired
cardparams.segments=1; % segments>1 => sequence mode in readIandQ
cardparams.fullscale=1; % in units of V, IT CAN ONLY TAKE VALUE:1,2, other values will give an error
cardparams.offset=0;    % in units of volts
cardparams.couplemode='DC'; % 'DC'/'AC'
cardparams.delaytime=5e-6; % Delay time from trigger to start of acquistion, units second
cardparams.ChI='Channel1';
cardparams.ChQ='Channel2';
cardparams.trigSource='External1'; % Trigger source
cardparams.trigLevel=0.5; % Trigger level in volts
cardparams.trigPeriod=10e-6; % Trigger period in seconds
```
Then either use the `SetParams` method
```matlab
card.SetParams(cardparams);
```
or use the assignment
```matlab
card.params = cardparams;
```
To get the parameters,
```matlab
cardparams = card.GetParams();
```
or
```matlab
cardparams = card.params;
```
To set/get individual parameter,
```matlab
card.params.fullscale = 2;
samplinginterval = card.params.sampleinterval;
```
### Acquire data
```matlab
[Idata, Qdata] = card.ReadIandQ();
```
`Idata` and `Qdata` are both M × N arrays, where M = `card.params.segments` and N = `card.params.samples`.

## Discussion
### Multi segment mode
Multi segment acquisition can be activated by setting `card.params.segments` to greater than 1. After receiving a trigger, the digitizer will store the data into the next segment. Maximum number of segments is 65536.

### Timeout
The acquistion will terminate if it is completed, or a timeout is reached, whichever happens first. Timeout is set to be **trigPeriod × averages × segments** in the code.

## Class definition
#### *class* M9703ADigitizer < handle
* **Properties**: 
  * **address** (*string*, Read-only): PXI address of the instrument
  * **instrID** (*integer*, Read-only): ID of the instrument
  * [**params**](#params) (*object*): Contains parameters

* **Methods**:
  * **card = M9703ADigitizer(address)**: Opens the instrument with `address` and returns a `card` object
  * **card.SetParams(cardparams)**: Sets parameters
  * **cardparams = card.GetParams()**: Gets parameters
  * **[IData, QData] = card.ReadIandQ()**: Reads I/Q data. `IData` and `QData` are M × N arrays where M = number of segments and N = number of samples.
  * **dataArray = card.ReadChannels(chList)**: Reads data from channels specified in `chList`. `dataArray` is a C × M × N array, where C = number of channels, M = number of segments and N = number of samples. `chList` is a 1 × C array that specifies the channels to read (e.g., chList = [3, 1, 5] will read out channels 3, 1, and 5). If `C = 1` or `M = 1`, the corresponding dimension will be squeezed.
  * **card.Finalize()**: Closes the instrument
  
#### <a name="params"></a>*class* paramlib.m9703a
A class to store parameters for M9703A digitizer
* **Properties**:
  * **fullscale** (*float*): Full scale in volts, can be 1 or 2
  * **offset** (*float*): Offset in volts, can be within ±2×fullscale
  * **samplerate** (*float*): Sampling rate in Hz, from 1.6 GHz to 50 MHz in factors of 2^n
  * **samples** (*integer*): Number of samples for each segment, up to 2^27
  * **averages** (*integer*): Number of averages, from 1 to 65536
  * **segments** (*integer*): Number of segments, from 1 to 65536
  * **delaytime** (*float*): Delay time in seconds before starting acquistion
  * **couplemode** (*string*): Coupling mode, possible values are 'AC' and 'DC'
  * **ChI** (*string*): Inphase channel, can be 'Channelx' where x = 1 to 8 (default = 'Channel1')
  * **ChQ** (*string*): Quadrature channel, can be 'Channelx' where x = 1 to 8 (default = 'Channel2')
  * **trigSource** (*string*): Trigger source, can be 'Externalx' or 'Channely', where x = 1 to 3 and y = 1 to 8 (default = 'External1')
  * **trigLevel** (*float*): Trigger level in volts, can be -5 V to 5 V (default = 0.5)
  * **trigPeriod** (*float*): Trigger period in seconds, used to calculate timeout
* **Methods**:
  * **s = self.toStruct()**: Converts the object to a struct
  
## Hardware specifications
The following specs are only for reference. Check the [datasheet](./M9703A_DataSheet.pdf) for details.

- **fullscale**  can be 1 or 2 V
- **offset** can be -2×fullscale to 2×fullscale
- **samplerate** is selectable from 1.6 GHz down to 50 MHz by factors of 2^n
- **segments × averages** can be up to 65536
- **samples × segments × averages** can be up to 2^27
- **trigLevel** can be -5 V to 5 V for external trigger