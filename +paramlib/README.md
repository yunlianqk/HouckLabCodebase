# paramlib
A library containing the parameter classes for different instruments.

## Contents
- [Usage of pulseCal class](#usage-of-pulsecal-class)
- [Class definitions](#class-definitions)
    - [paramlib.pnax.trans](#-class-paramlib-pnax-trans)
    - [paramlib.pnax.spec](#-class-paramlib-pnax-spec)
    - [paramlib.pnax.psweep](#-class-paramlib-pnax-psweep)
    - [paramlib.acqiris](#-class-paramlib-acqiris)
    - [paramlib.m9703a](#-class-paramlib-m9703a)
    - [paramlib.pulseCal](#-class-paramlib-pulsecal)

## Usage of pulseCal class
See also [example code](../ExampleCode/ExampleCode_pulseCal.m).

`pulseCal` provides an interface between qubit gate parameters and [`pulselib`](../+pulselib/README.md) objects. All parameters for a single qubit gate (amplitude, duration, DRAG, azimuth angle, etc.) are stored in the corresponding properties of a pulseCal object, and it provides methods to create a gate object with these properties.

```matlab
% Create 'pulseCal' object
pulseCal = paramlib.pulseCal();

% Set up parameters
pulseCal.sigma = 10e-9;
pulseCal.cutoff = 4*pulseCal.sigma;
pulseCal.X180Amplitude = 0.8;
pulseCal.X180DragAmplitude = 0.25;
```
Calling `pulseCal.X180()` will return a [`pulselib.singleGate` ](../+pulselib/README.md#-class-pulselib-singlegate-handle) object with its stored parameters:
```
>> pulseCal.X180()

ans = 

  singleGate with properties:

             name: 'X180'
          unitary: [2x2 double]
         rotation: 3.1416
          azimuth: 0
        amplitude: 0.8000
    dragAmplitude: 0.2500
            sigma: 1.0000e-08
           cutoff: 4.0000e-08
           buffer: 4.0000e-09
    totalDuration: 4.4000e-08
```
Remember MATLAB supports **obj.(property/method name)** syntax to access properties and methods of an object using their name string. This is useful for converting a list of gate names to gate objects:
```matlab
nameList = {'X180', 'X180', 'X90', 'Y90'};  % List of gate names
pulseCal = paramlib.pulseCal();
gateList = [];

for gate = nameList
    % pulseCal.(gate{:}) converts gate name to gate object
    gateList = [gateList, pulseCal.(gate{:})];
end
```
`gateList` is now a 1 &times; 4 gate object array:
```
gateList = 

  1x4 singleGate array with properties:

    name
    unitary
    rotation
    azimuth
    amplitude
    dragAmplitude
    sigma
    cutoff
    buffer
    totalDuration
```

## Class definitions
#### *class* paramlib.pnax.trans
A class to store parameters for transmission measurement
* **Properties**: 
  * **start** (*float*): start frequency
  * **stop** (*float*): stop frequency
  * **power** (*float*): RF power
  * **points** (*integer*): number of sweeping points
  * **averages** (*integer*): number of averages
  * **ifbandwidth** (*float*): IF bandwidth
  * **channel** (*integer*): channel number
  * **trace** (*integer*): trace number
  * **meastype** (*string*): measurement type, e.g., 'S21', 'S13', etc.
  * **format** (*string*): measurement format, possible values are 'MLOG', 'MLIN', 'PHAS', 'UPH', 'REAL', 'IMAG', 'SMIT', 'SADM', 'SWR', 'GDEL', 'KELV', 'FAHR', 'CELS'
* **Methods**:
  * **params = paramlib.pnax.trans()**: returns an object `params`
  * **s = params.toStruct()**: converts the object to a struct
  
#### *class* paramlib.pnax.spec
A class to store parameters for spectroscopy measurement
* **Properties**: 
  * **start** (*float*): start frequency
  * **stop** (*float*): stop frequency
  * **power** (*float*): RF power
  * **points** (*integer*): number of sweeping points
  * **averages** (*integer*): number of averages
  * **ifbandwidth** (*float*): IF bandwidth
  * **cwfreq** (*float*): CW frequency
  * **cwpower** (*float*): CW power
  * **channel** (*integer*): channel number
  * **trace** (*integer*): trace number
  * **meastype** (*string*): measurement type, e.g., 'S21', 'S13', etc.
  * **format** (*string*): measurement format, possible values are 'MLOG', 'MLIN', 'PHAS', 'UPH', 'REAL', 'IMAG', 'SMIT', 'SADM', 'SWR', 'GDEL', 'KELV', 'FAHR', 'CELS'
* **Methods**:
  * **params = paramlib.pnax.spec()**: returns an object `params`
  * **s = params.toStruct()**: converts the object to a struct

  
#### *class* paramlib.pnax.psweep
A class to store parameters for power sweep measurement
* **Properties**:
  * **start** (*float*): start power
  * **stop** (*float*): stop power
  * **points** (*integer*): number of sweeping points
  * **averages** (*integer*): number of averages
  * **ifbandwidth** (*float*): IF bandwidth
  * **cwfreq** (*float*): CW frequency
  * **trace** (*integer*): trace number
  * **meastype** (*string*): measurement type, e.g., 'S21', 'S13', etc.
  * **format** (*string*): measurement format, possible values are 'MLOG', 'MLIN', 'PHAS', 'UPH', 'REAL', 'IMAG', 'SMIT', 'SADM', 'SWR', 'GDEL', 'KELV', 'FAHR', 'CELS'
* **Methods**:
  * **params = paramlib.pnax.psweep()**: returns an object `params`
  * **s = params.toStruct()**: converts the object to a struct


#### *class* paramlib.acqiris
A class to store parameters for Acqiris digitizers ([U1082A](../@U1082ADigitizer/README.md#hardware-specifications) and [U1084A](../@U1084ADigitizer/README.md#hardware-specifications)). Note that the allowed values for some properties are different for the two models. Click the links to see details.
* **Properties**:
  * **fullscale** (*float*): Full scale in volts
  * **offset** (*float*): Offset in volts
  * **sampleinterval** (*float*): Sampling interval in seconds
  * **samples** (*integer*): Number of samples for each segment
  * **averages** (*integer*): Number of averages
  * **segments** (*integer*): Number of segments
  * **delaytime** (*float*): Delay time in seconds before starting acquistion
  * **couplemode** (*string*): Coupling mode, possible values are 'AC' and 'DC'
  * **trigSource** (*string*): Trigger source, can be 'External1' (default) or 'Channel1', 'Channel2'
  * **trigLevel** (*float*): Trigger level
  * **trigPeriod** (*float*): Trigger period in seconds (default = 100e-6), used to calculate timeout
* **Methods**:
  * **params = paramlib.aqiris()**: returns an object `params`
  * **s = params.toStruct()**: converts the object to a struct

  
### *class* paramlib.m9703a
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
  
### *class* paramlib.pulseCal
A class to store parameters for qubit gates. 
* **Properties**:

    *Qubit pulse shape properties* 
    * **sigma** (*float*): sigma for Gaussian pulse, in seconds
    * **cutoff** (*float*): cutoff for gaussian pulse, in seconds
    * **buffer** (*float*): buffer between gaussian pulses, in seconds

    *Measurement pulse properties*
    * **cavityAmplitude** (*float*): amplitude for measurement
    * **measDuration** (*float*): 
    * **loAmplitude** (*float*): 
    
    *Microwave generator properties*
    * **qubitFreq** (*float*): 
    * **cavityFreq** (*float*): 
    * **intFreq** (*float*): 
    * **specPower** (*float*): 
    * **rfPower** (*float*): 
    * **loPower** (*float*): 

    *Qubit gate properties*
    * **X90Amplitude** (*float*): 
    * **X90DragAmplitude** (*float*): 
    * **X90Azimuth** (*float*): 
    
    *similar properties for X180, Y90, etc.* ...
* **Methods**:
    * **pulseCal = paramlib.pulseCal()**: returns a `pulseCal` object
    * **gate = pulseCal.X90()**: returns a X180 gate object with the parameters stored in `pulseCal`
    
    *similar methods for X180, Y90, measurement pulse, etc.* ...

