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
Before using the code, run [setpath.m](./setpath.m) to set the search path.

A typical usage of the code to communicate with an instrument involves **opening instrument**, **setting parameters**,  **getting data** and **closing instrument**.

For example, to communicate with a YOKOGAWA GS200 voltage/current source, first create a **YOKOGS200** object using its GPIB address:
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
To close the instrument, use the `Finalize` method:
```matlab
yoko.Finalize();
```
## Usage
The code can be used in various ways depending on your own preference.

In [instruments_initialize.m](./instruments_initialize.m), all the instrument objects are declared as *global* variables:
```matlab
global pnax;
address = 16;
pnax = PNAXAnalyzer(address);
```
1.  To use them in a script:
    ```matlab
    global pnax;
    display(pnax.params);
    ```

2.  To use them in a MATLAB function, you can either declare it inside the function as shown above, or pass them as the input parameters to the function:
    ```matlab
    function data = MyMeasurement(argument1, ..., pnax)
        ...
        pnax.PowerOn();
        data = pnax.Read();
        ...
    end
    ```

3.  To build your own classes that have the instrument objects as properties:
    ```matlab
    classdef MyMeasurement
        properties
            ...
            pnax;
        end
        
        methods
            function self = MyMeasurement(pnax)
                self.pnax = pnax;
                ...
            end
            function data = run(self)
                ...
                pnax.PowerOn();
                data = pnax.Read();
                ...
            end 
        end
    end
    ```
    and then pass them when you construct a measurement object:
    ```matlab
    mymeas = MyMeasurement(pnax);
    data = mymeas.run();
    ```
    You can also define class methods that call `pnax` in the same way as method 2.

## Search path and namespace
In order for the code to work consistently, we need a well defined search path and namespace. The [setpath.m](./setpath.m) script add **only the root folder** of the repository to MATLAB search path. Be careful with the namespace when you add subfolders or your own code folders to the search path. In particular, **do not** add subfolders inside a folder that starts with '@' or '+'.

All the classes for accessing instruments are contained in **class folders** starting with '@'. Other instrument related classes are contained in **package folders** starting with '+'.

## Documentation
Click the instrument to see the documents.

- [GPIB instrument](./@GPIBINSTR/README.md)
- [E8267D microwave generator](./@E8267DGenerator/README.md)
- [PNAX network analyzer](./@PNAXAnalyzer/README.md)
- [YOKOGAWA GS200 voltgae/current source](./@YOKOGS200/README.md)
- [YOKOGAWA 7651 voltage/current source](./@YOKO7651/README.md)
- [U1082A digitizer](./@U1082ADigitizer/README.md)
- [M9330A arbitrary waveform generator](./@M9330AWG/README.md)
- [33250A 80 MHz waveform generator](./@AWG33250A/README.md)
