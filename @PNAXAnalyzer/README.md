# PNA-X Network Analyzer
## Interfaces
#### *class* PNAXAnalyzer < GPIBINSTR
* **Properties** : 
  * **address** (Read-only): GPIB address of the instrument
  * **instrhandle** (Read-only): GPIB object to communicate with instrument
  * [**transparams**](#transparams) (Dependent): A structure that contains parameters for transmission measurement
  * [**specparams**](#specparams) (Dependent): A structure that contains parameters for spectroscopy measurement 

##### transparams
Contains the following fields:
  * start (*float*): start frequency
  * stop (*float*): stop frequency
  * power (*float*): RF power
  * points (*integer*): number of sweeping points
  * averages (*integer*): number of averages
  * ifbandwidth (*float*): IF bandwidth
  * channel (*integer*): channel number
  * trace (*integer*): trace number
  * meastype (*string*): measurement type, e.g., 'S21', 'S13', etc.
  * format (*string*): measurement format, possible values are 'MLOG', 'MLIN', 'PHAS', 'UPH', 'REAL', 'IMAG', 'SMIT', 'SADM', 'SWR', 'GDE', 'KELV', 'FAHR', 'CELS'.

##### specparams
Contains the following fields:
  * start (*float*): start frequency
  * stop (*float*): stop frequency
  * power (*float*): RF power
  * points (*integer*): number of sweeping points
  * averages (*integer*): number of averages
  * ifbandwidth (*float*): IF bandwidth
  * cwfreq (*float*): CW frequency
  * cwpower (*float*): CW power
  * channel (*integer*): channel number
  * trace (*integer*): trace number
  * meastype (*string*): measurement type, e.g., 'S21', 'S13', etc.
  * format (*string*): measurement format, possible values are 'MLOG', 'MLIN', 'PHAS', 'UPH', 'REAL', 'IMAG', 'SMIT', 'SADM', 'SWR', 'GDE', 'KELV', 'FAHR', 'CELS'. 
