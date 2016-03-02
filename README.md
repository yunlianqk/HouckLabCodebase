# Houck Lab Measurement Code

## Introduction
This is the MATLAB code for communication with measurement equiqments in Houck Lab.

To make changes/pull requests to the repository, please use the HouckLab GitHub account:
- Username: houcklab
- Password: "eletrcon charge"
- Email: houcklabprinceton@gmail.com

## Purpose
The goal is to encapsulate the lower level equiment codes and provide a unified interface for measurements.
Equipment-indepdent programs can then be built with these interfaces.
Update and maintanence of the code will be done through GitHub.

## Progess
Equipments that have been implemented:

- E8267D microwave generator
- PNAX network analyzer
- YOKOGAWA GS200 voltgae/current source
- YOKOGAWA 7621 voltage/current source
- U1082A digitizer
- M9330A AWG

## Usage
To control an instrument, first set up the desired parameters and then call the corresponding method. For example, the set the output voltage of a YOKOGAWA 7621, first create a `YOKOGS200` object using its GPIB address:
```matlab
address = 2
yoko = YOKOGS200(address);
```
Then set up the parameters:
```matlab
yoko.rampstep = 0.002;      % Increment for each step
yoko.rampinterval = 0.01;   % Time between 2 steps
yoko.voltage = 0.5;         % Desired voltage  
```
Finally call the `SetVoltage` method:
```matlab
yoko.SetVoltage();
```
You can also use
```matlab
yoko.SetVoltage(0.5);
```
to directly set the voltage.
