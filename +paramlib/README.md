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
  * **format** (*string*): measurement format, possible values are 'MLOG', 'MLIN', 'PHAS', 'UPH', 'REAL', 'IMAG', 'SMIT', 'SADM', 'SWR', 'GDE', 'KELV', 'FAHR', 'CELS'

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
  * **format** (*string*): measurement format, possible values are 'MLOG', 'MLIN', 'PHAS', 'UPH', 'REAL', 'IMAG', 'SMIT', 'SADM', 'SWR', 'GDE', 'KELV', 'FAHR', 'CELS'
  
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
  * **format** (*string*): measurement format, possible values are 'MLOG', 'MLIN', 'PHAS', 'UPH', 'REAL', 'IMAG', 'SMIT', 'SADM', 'SWR', 'GDE', 'KELV', 'FAHR', 'CELS'
  
#### *class* paramlib.acqiris
A class to store parameters for Acqiris digitizer
* **Properties**:
  * **fullscale** (*float*): Full scale in volts
  * **sampleinterval** (*float*): Sampling interval in seconds
  * **samples** (*integer*): Number of samples for each segment
  * **averages** (*integer*): Number of averages
  * **segments** (*integer*): Number of segments
  * **delaytime** (*float*): Delay time in seconds before starting acquistion
  * **couplemode** (*string*): Coupling mode, possible values are 'AC' and 'DC'
