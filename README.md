# Houck Lab Measurement Code

## Introduction
This is the MATLAB code for communication with measurement equiqments in Houck Lab. 

The goal is to encapsulate the lower level equiment codes and provide a unified interface for measurements.
Equipment-indepdent programs can then be built with these interfaces.
Update and maintanence of the code will be done through GitHub.

## Installation and maintanence
Please use the HouckLab GitHub account:
- Username: houcklab
- Password: "eletrcon charge"
- Email: houcklabprinceton@gmail.com

or your own GitHub account to access the repository.

To download the code, navigate to your destination folder:
```bash
$ cd YourDestFolder
$ git clone https://github.com/houcklab/HouckLabMeasurementCode.git
```

To sync with the lastest version (assuming `origin` is defined as the above repository):
```bash
$ git pull origin master
```

To upload your changes to the repository:
```bash
$ git add --all
$ git commit -m "Some message"
$ git push origin master
```

## Quick start
A typical usage of the code to communicate with an instrument involves **opening instrument**, **setting parameters**,  **getting data** and **closing instrument**. For example, to communicate with a YOKOGAWA 7621 voltage/current source, first create a `YOKOGS200` object using its GPIB address:
```matlab
address = 2
yoko = YOKOGS200(address);
```
Then set up the parameters:
```matlab
yoko.rampstep = 0.002;      % Voltage increment for each step
yoko.rampinterval = 0.01;   % Time interval between 2 steps
```
To set the voltage, call the `SetVoltage` method:
```matlab
yoko.SetVoltage(0.5);
```
Alternatively, you can use an assignment
```matlab
yoko.voltage = 0.5;
```
to directly set the voltage.

To get the current output voltage, call the `GetVoltage` method:
```matlab
voltage = yoko.GetVoltage();
```
or use a direct assignment:
```matlab
voltage = yoko.voltage;
```

## Documentation
Click the instrument to see the documents.

- E8267D microwave generator
- [PNAX network analyzer](./@PNAXAnalyzer/README.md)
- YOKOGAWA GS200 voltgae/current source
- YOKOGAWA 7621 voltage/current source
- U1082A digitizer
- M9330A AWG
