# Paramlib
A library containing the parameter classes for different instruments.

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
  * **s = self.toStruct()**: Converts the object to a struct
  
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
  * **s = self.toStruct()**: Converts the object to a struct
  
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
  * **s = self.toStruct()**: Converts the object to a struct

#### *class* paramlib.acqiris
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
  
#### *class* paramlib.m9703a
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
