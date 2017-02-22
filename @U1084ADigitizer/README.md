# Acqiris U1084A 8-Bit Digitizer
## Contents
- [Usage](#usage)
- [Remarks](#remarks)
- [Class definition](#class-definition)
- [Hardware specifications](#hardware-specifications)

## Usage
### Open instrument
```matlab
address = 'PXI7::4::0::INSTR';  % PXI address
card = U1084ADigitizer(address);
```
### Set/get parameters
To set the parameters, first create a [**paramlib.acqiris**](../+paramlib/README.md#class-paramlibacqiris) *object* that contains the parameters:
```matlab
cardparams = paramlib.acqiris();
cardparams.fullscale = 0.2;
cardparams.sampleinterval = 1e-9;
cardparams.samples = 10240;
cardparams.averages = 30000;
cardparams.segments = 1;
cardparams.delaytime = 2e-6;
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

## Remarks
### Averaging
No software averaging is implemented because on-card averaging can be as large as 16777216.

### Multi segment mode
Multi segment acquisition can be activated by setting `card.params.segments` to greater than 1. After receiving a trigger, the digitizer will store the data into the next segment. Maximum number of segments is 131072.
  
### Timeout
The acquistion will terminate if it is completed, or a timeout is reached, whichever happens first. In the code, timeout is set to be **trigger period × on-card averages × segments**. To ensure a normal completion of acquisition, make sure **trigger period > (delaytime + sampleinterval × numsamples)** so that the current acquistion is finished before the next trigger arrives.

## Class definition
#### *class* U1084ADigitizer < handle
* **Properties**: 
  * **address** (*string*, Read-only): PXI address of the instrument
  * **instrID** (*integer*, Read-only): ID of the instrument
  * [**params**](../+paramlib/README.md#class-paramlibacqiris) (*object*): Contains parameters

* **Methods**:
  * **card = U1082ADigitizer(address)**: Opens the instrument with `address` and returns a `card` object
  * **card.SetParams(cardparams)**: Sets parameters
  * **cardparams = card.GetParams()**: Gets parameters
  * **[IData, QData] = card.ReadIandQ()**: Reads data. `IData` and `QData` are M × N arrays where M = number of segments and N = number of samples
  * **card.Finalize()**: Closes the instrument
  
## Hardware specifications
The following specs are only for reference. Check the [datasheet](./U1084ASpecs.pdf) for details.

- **fullscale**  can be selectable from 0.05 V to 5 V in 1, 2, 5 sequence
- **offset** can be within ± 2 V for 0.05/0.5 V fullscale, and ± 5 V for 1 to 5 V fullscale
- **sampleinterval** is selectable from 1 ns to 2048 ns in 2<sup>n</sup> sequence
- **samples** can be 2048 to 2<sup>18</sup> in steps of 2048
- **segments** can be 1 to 131072
- **samples × segments** needs to be less than 2<sup>25</sup>
- **averages** can be between 1 and 16777216
- **trigLevel** can be within ± 2.5 V for external trigger, or in fraction of fullscale within ± 0.5 for internal trigger
