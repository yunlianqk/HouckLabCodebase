# Acqiris U1082A 8-Bit Digitizer
## Usage
See also the [example code](../ExampleCode/U1082A.m).
### Open instrument
```matlab
address = 'PXI7::4::0::INSTR';  % PXI address
card = U1082ADigitizer(address);
```
### Set/get parameters
To set the parameters, first create a [**paramlib.acqiris**](#params) *object* that contains the parameters:
```matlab
cardparams = paramlib.acqiris();
cardparams.fullscale = 0.2;
cardparams.sampleinterval = 1e-9;
cardparams.samples = 10000;
cardparams.averages = 30000;
cardparams.segments = 1;
cardparams.delaytime = 10e-6;
cardparams.couplemode = 'DC';
cardparams.trigPeriod = 50e-6;
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
card.params.fullscale = 0.5;
samplinginterval = card.params.sampleinterval;
```
### Acquire data
```matlab
[Idata, Qdata] = card.ReadIandQ();
```
`Idata` and `Qdata` are both M × N arrays, where M = `card.params.segments` and N = `card.params.samples`.

## Discussion
### Averaging
The on-card averaging is set by the parameter `NbrRoundRobins` in the low-level code. `NbrRoundRobins` is used instead of `NbrWaveforms` so that the on-card averaging works for both single and multi segment acquisition. The maximum on-card averages is 65536.

**Software averaging** is automatic used for **single segment** mode if `card.params.averages` is greater than 65536. For example, if card.params.averages = 150000, it will be split into software averages = 3 and on-card averages = 50000. For multi segment mode, software averaging cannot be easily implemented, because the start of the first segment usually needs to be synchronized with pulse generation.

### Multi segment mode
Multi segment acquisition can be activated by setting `card.params.segments` to greater than 1. After receiving a trigger, the digitizer will store the data into the next segment. Maximum number of segments is 8191. If `card.params.averages` is non-zero, the on-card averaging will be in "round of robin" mode. Auto software averaging is not implemented for multi segment mode, so maximum average is 65536.

- **Known issue**: Because of memory limit of the digitizer, **samples × segments** needs to be less than 2^21. When running the following code to switch from single segment to multi segment mode,

  ```matlab
  % Single segment mode
  card.params.segments = 1;
  card.params.samples = 10000;

  % Mulit segement mode
  card.params.segment = 1000;
  card.params.samples = 100;
  ```
  
  **an error will occur** although `samples × segments` < 2^21 in both cases. The reason is that when executing `card.params.segments`, `card.params.samples` is still set to 10000, so `samples × segments` exceeds 2^21 temporarily. To avoid this, either run the last two lines again, or change their order:

  ```matlab
  % Single segment mode
  card.params.segments = 1;
  card.params.samples = 10000;

  % Mulit segement mode
  card.params.samples = 100;  % reduce samples first
  card.params.segment = 1000;
  ```

### Timeout
The acquistion will terminate if it is completed, or a timeout is reached, whichever happens first. To ensure a normal completion of acquisition, make sure **trigger period > (delaytime + sampleinterval × numsamples)** so that the current acquistion is finished before the next trigger arrives.

## Class definition
#### *class* U1082ADigitizer < handle
* **Properties**: 
  * **address** (*string*, Read-only): PXI address of the instrument
  * **instrID** (*integer*, Read-only): ID of the instrument
  * [**params**](#params) (*object*): Contains parameters

* **Methods**:
  * **card = U1082ADigitizer(address)**: Opens the instrument with `address` and returns a `card` object
  * **card.SetParams(cardparams)**: Sets parameters
  * **cardparams = card.GetParams()**: Gets parameters
  * **[IData, QData] = card.ReadIandQ()**: Reads data. `IData` and `QData` are M × N arrays where M = number of segments and N = number of samples
  * **card.Finalize()**: Closes the instrument
  
#### <a name="params"></a>*class* paramlib.acqiris
A class to store parameters for Acqiris digitizer
* **Properties**:
  * **fullscale** (*float*): Full scale in volts, from 0.05 V to 5 V in 1, 2, 5 sequence
  * **offset** (*float*): Offset in volts, within ± 2 V for 0.05/0.5 V full scale, and ± 5 V for 1 to 5 V fullscale
  * **sampleinterval** (*float*): Sampling interval in seconds, from 1 ns to 0.1 ms in 1, 2, 2.5, 4, 5 sequence
  * **samples** (*integer*): Number of samples for each segment, from 16 to 2 Mega (2^21) in steps of 16
  * **averages** (*integer*): Number of averages, from 1 to 65536
  * **segments** (*integer*): Number of segments, from 1 to 8191
  * **delaytime** (*float*): Delay time in seconds before starting acquistion
  * **couplemode** (*string*): Coupling mode, possible values are 'AC' and 'DC'
  * **trigSource** (*string*): Trigger source, can be 'External1' (default) or 'Channel1', 'Channel2'
  * **trigLevel** (*float*): Trigger level, in volts within ± 2.5 (default = 0.5) for external trigger, and in fraction of fullscale within ± 0.5 for internal trigger
  * **trigPeriod** (*float*): Trigger period in seconds (default = 100e-6), used to calculate timeout
* **Methods**:
  * **s = self.toStruct()**: Converts the object to a struct
  
## Hardware specifications
The following specs are only for reference. Check the [datasheet](./Specs.pdf) for details.

- **fullscale**  can be selectable from 0.05 V to 5 V in 1, 2, 5 sequence
- **offset** can be within ± 2 V for 0.05/0.5 V fullscale, and ± 5 V for 1 to 5 V fullscale
- **sampleinterval** is selectable from 1 ns to 0.1 ms in 1, 2, 2.5, 4, 5 sequence
- **samples** can be 16 to 2 Mega (2^21) in steps of 16
- **segments** can be 1 to 8191
- **samples × segments** needs to be less than 2^21
- **averages** can be between 1 and 65536
- **trigLevel** can be within ± 2.5 V for external trigger, or in fraction of fullscale within ± 0.5 for internal trigger
