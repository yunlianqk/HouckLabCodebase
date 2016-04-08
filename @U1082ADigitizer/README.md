# Acqiris U1082A 8-Bit Digitizer
## Usage
### Open instrument
```matlab
address = 'PXI7::4::0::INSTR';
card = U1082ADigitizer(address);
```
### Set/get parameters
To set the parameters, first create a [**ACQIRISParams**](#params) *object* that contains the parameters:
```matlab
cardparams = ACQIRISParams();
cardparams.fullscale = 0.2;
cardparams.sampleinterval = 1e-9;
cardparams.samples = 10000;
cardparams.averages = 30000
cardparams.segments = 1;
cardparams.delaytime = 10e-6;
cardparams.couplemode = 'DC';
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
`Idata` and `Qdata` are both m × n arrays, where `m = card.params.samples` and `n = card.params.segments`.

## Class definition
#### *class* U1082ADigitizer < handle
* **Properties**: 
  * **address** (*string*, Read-only): PXI address of the instrument
  * **instrID** (*integer*, Read-only): ID of the instrument
  * [**params**](#params) (*object*, Dependent): Contains parameters

* **Methods**:
  * **card = U1082ADigitizer(address)**: Opens the instrument with `address` and returns a `card` object
  * **card.SetParams(cardparams)**: Sets parameters
  * **cardparams = card.GetParams()**: Gets parameters
  * **[IData, QData] = card.ReadIandQ()**: Reads data
  * **card.Finalize()**: Closes the instrument
  
#### <a name="params"></a>*class* ACQIRISParams
A class to store parameters for Acqiris digitizer
* **Properties**:
  * **fullscale** (*float*): Full scale in volts
  * **sampleinterval** (*float*): Sampling interval in seconds
  * **samples** (*integer*): Number of samples for each segment
  * **averages** (*integer*): Number of averages
  * **segments** (*integer*): Number of segments
  * **delaytime** (*float*): Delay time in seconds before starting acquistion
  * **couplemode** (*string*): Coupling mode, possible values are 'AC' and 'DC'
  
## Hardware specifications
The following specs are only for reference. Check the [datasheet](./Specs.pdf) for details.

- **fullscale**  is selectable from 0.05 V to 5 V in a 1, 2, 5 sequence
- **sampleinterval** is selectable from 1 ns to 2.048 μs in binary (multiply by 2^n) sequence
- **samples** can be 16 to 2 Mega in steps of 16
- **segments** can be 1 to 8191
