# PNA-X Network Analyzer
## Usage
See also the [example code](../ExampleCode/PNAX.m).
### Open instrument
```matlab
address = 16; % GPIB address
pnax = PNAXAnalyzer(address);
```
### Create measurements
To set up a transmission scan, first create a [**paramlib.pnax.trans**](#transparams) *object* that contains the parameters:
```matlab
transCh1 = paramlib.pnax.trans();
transCh1.start = 5e9;
transCh1.stop = 6e9;
transCh1.points = 1001;
transCh1.power = -50;
transCh1.averages = 1000;
transCh1.ifbandwidth = 5e3;
transCh1.channel = 1;
transCh1.trace = 1;
transCh1.meastype = 'S21';
transCh1.format = 'MLOG';
```
Then either use the `SetParams` method
```matlab
pnax.SetParams(transCh1);
```
or use the assignment
```matlab
pnax.params = transCh1;
```
to pass the parameters to the instrument.

Repeat the above procedure to add new channels/traces:
```matlab
transCh2 = transCh1;
transCh2.channel = 2;
transCh2.trace = 2;
transCh2.meastype = 'S13';
transCh2.format = 'UPH';

pnax.params = transCh2;
```
### Select measurements
Once you have set up some measurements, you can select a measurement using its trace number:
```matlab
pnax.SetActiveTrace(transCh2.trace);
```
You can also use ```SetActiveChannel``` or ```SetActiveMeas``` with a channel number or a measurement name.

### Modify parameters
To modifiy a single parameter (e.g. stop frequency) of the current trace:
```matlab
pnax.params.stop = 10e9;
```
Of course you can also use 
```matlab
transCh2.stop =  10e9;
transCh2.power = -40;
pnax.SetParams(transCh2);
```
to modify multiple parameters.

### Read data
To read data from PNAX, first select the **trace** and then call the `Read` method:
```matlab
trace = 1;
pnax.SetActiveTrace(trace);
S21amp = pnax.Read();
trace = 2;
pnax.SetActiveTrace(trace);
S13phase = pnax.Read();
pnax.params.format = 'MLOG';
S13amp = pnax.Read();
```
You can also use 
```matlab
data = pnax.ReadTrace(trace);
```
to read a desired trace.

To get the x-axis, call the `ReadAxis` method:
```matlab
freqvector = pnax.ReadAxis();
```

## Discussion
- A **channel** contains several **measurements** that are of the same type. For example, all transmission measurements can (but not necessarily) be in channel 1 and all spectroscopy measurements can be in channel 2, but a trans and a spec cannot be in the same channel.
- A **measurement** is fed to a **trace** to be displayed in the front panel. To activate an existing measurement, use the corresponding trace number and set it to active. The trace number is **NOT** the "TR#" displayed in the front panel, it is for the purpose of remote control only.
- <a name="measname"></a>The **naming convention** for a measurement follows the default setting: a measurement in channel X, measuring Sij and fed to trace Y is named `'CHX_Sij_Y'`.

## Class definition
#### *class* PNAXAnalyzer < GPIBINSTR
* **Properties**: 
  * **address** (*integer*, Read-only): GPIB address of the instrument
  * **instrhandle** (*GPIB object*, Read-only):  Handle to communicate with instrument
  * [**params**](#transparams) (*object*): Contains parameters for a measurement
  * **timeout** (*float*, Private): Wait time when there is error in communication

* **Methods**:
  * [**PNAXAnalyzer**](#pnaxanalyzer)
  * [**SetParams**](#setparams)
  * [**SetActiveChannel**](#setactivechannel)
  * [**SetActiveTrace**](#setactivetrace)
  * [**SetActiveMeas**](#setactivemeas)
  * [**GetParams**](#getparams)
  * [**GetChannelList**](#getchannellist)
  * [**GetTraceList**](#gettracelist)
  * [**GetMeasList**](#getmeaslist)
  * [**GetActiveChannel**](#getactivechannel)
  * [**GetActiveTrace**](#getactivetrace)
  * [**GetActiveMeas**](#getactivemeas)
  * [**Read**](#read)
  * [**ReadAxis**](#readaxis)
  * [**ReadTrace**](#readtrace)
  * [**ReadChannel**](#readchannel)
  * [**CreateMeas**](#createmeas)
  * [**DeleteChannel**](#deletechannel)
  * [**DeleteTrace**](#deletetrace)
  * [**DeleteMeas**](#deletemeas)
  * [**DeletaAll**](#deleteall)
  * [**PowerOn**](#poweron)
  * [**PowerOff**](#poweroff)
  * [**TrigContinuous**](#trigcontinuous)
  * [**TrigHold**](#trighold)
  * [**TrigSingle**](#trigsingle)
  * [**TrigHoldAll**](#trigholdall)
  * [**AvgOn**](#avgon)
  * [**AvgOff**](#avgoff)
  * [**AutoScale**](#autoscale)
  * [**AutoScaleAll**](#autoscaleall)
  * [**Reset**](#reset)
  * [**Finalize**](#finalize)


#### <a name="transparams"></a>*class* paramlib.pnax.trans
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
  * **format** (*string*): measurement format, possible values are 'MLOG', 'MLIN', 'PHAS', 'UPH', 'REAL', 'IMAG', 'SMIT', 'SADM', 'SWR', 'GDE', 'KELV', 'FAHR', 'CELS'
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
  * **format** (*string*): measurement format, possible values are 'MLOG', 'MLIN', 'PHAS', 'UPH', 'REAL', 'IMAG', 'SMIT', 'SADM', 'SWR', 'GDE', 'KELV', 'FAHR', 'CELS'
* **Methods**:
  * **s = self.toStruct()**: Converts the object to a struct
  
## API Specifications
##### PNAXAnalyzer
`pnax = PNAXAnalyzer(address)` opens PNAX with `address` and returns a `pnax` object.

##### SetParams
`pnax.SetParams(transparams)` sets up the [parameters](#transparams) for a measurement.

##### SetActiveChannel
`pnax.SetActiveChannel(channel)` sets the channel specified by *interger* `channel` as active.

##### SetActiveTrace
`pnax.SetActiveTrace(trace)` sets the trace specified by *integer* `trace` as active.

##### SetActiveMeas
`pnax.SetActiveMeas(meas)` sets the measurement specified by *string* `meas` as active.

##### GetParams
`params = pnax.GetParams()` returns a *object* `params` containing the [parameters](#transparams) of the active measurement.

##### GetChannelList
`chlist = pnax.GetChannelList()` returns an *array* `chlist` containing the number for each channel.

##### GetTraceList
`trlist = pnax.GetTraceList()` returns an *array* `trlist` containing the number for each trace.

##### GetMeasList
`measlist = pnax.GetMeasList([channel])` returns an *string cell array* `mealist` containing the name of each measurement in `channel`.

If `channel` is not specified, the active channel will be used.

##### GetActiveChannel
`channel = pnax.GetActiveChannel()` returns the active channel number to *integer* `channel`.

##### GetActiveTrace
`trace = pnax.GetActiveTrace()` returns the active trace number to *integer* `trace`.

##### GetActiveMeas
`meas = pnax.GetActiveMeas()` returns the active measurement name to *string* `meas`.

##### Read
`data = pnax.Read()` reads the active trace and returns `data`. Same as `pnax.ReadTrace()`.

##### ReadAxis
`xaxis = pnax.ReadAxis()` reads the x-axis of the active trace and returns `xaxis`.

##### ReadTrace
`data = pnax.ReadTrace([trace])` reads the trace specified by *integer* `trace` and returns `data`. 

If `trace` is not specified, the active trace will be used.

##### ReadChannel
`dataarray = pnax.ReadChannel([channel])` reads all the measurements in the channel specified by *integer* `channel` and returns `dataarray`.

`dataaaray` contains n lines of data, where n is the number of measurements in `channel` and each line contains the data for one measurement.

If `channel` is not specified, the active channel will be used.

##### CreateMeas
`pnax.CreateMeas(channel, trace, meas, meastype)` creates a measurement according to the input parameters. Use this method if you need to manually create measurement.
  * *integer* `channel`: channel number
  * *integer* `trace`: trace number
  * *string* `meas`: measurement name. Please follow [naming convention](#measname) when naming a measurement.
  * *string* `meastype`: measurement type, e.g., 'S21', 'S13', etc.

##### DeleteChannel
`pnax.DeleteChannel(channel)` deletes a channel specified by *integer* `channel`.

##### DeleteTrace
`pnax.DeleteTrace(trace)` deletes a trace specified by *integer* `trace`.

##### DeleteMeas
`pnax.DeleteMeas(channel, meas)` deletes a measurement named `meas` from `channel`.

##### DeleteAll
`pnax.DeleteAll()` deletes all channels.

##### PowerOn
`pnax.PowerOn()` turns on the output power.

##### PowerOff
`pnax.PowerOff()` turns off the output power.

##### TrigContinuous
`pnax.TrigContinuous([channel])` sets the trigger of a channel to continuous.

If `channel` is not specified, the active channel will be used.

##### TrigHold
`pnax.TrigHold([channel])` sets the trigger of a channel to hold.

If `channel` is not specified, the active channel will be used.

##### TrigSingle
`pnax.TrigSingle([channel])` sets the trigger of a channel to single.

If `channel` is not specified, the active channel will be used.

##### TrigHoldAll
`pnax.TrigHoldAll()` holds the trigger for all channels.

##### AvgOn
`pnax.AvgOn([channel])` turns on average in a channel.

If `channel` is not specified, the active channel will be used.

##### AvgOff
`pnax.AvgOff([channel])` turns off average in a channel.

If `channel` is not specified, the active channel will be used.

##### AvgClear
`pnax.AvgClear([channel])` clears average in a channel.

If `channel` is not specified, the active channel will be used.

##### AutoScale
`pnax.AutoScale([trace])` auto scales a trace.

If `trace` is not specified, the active trace will be used.

##### AutoScaleAll
`pnax.AutoScaleAll()` auto scales all traces.

##### Reset
`pnax.Reset()` resets PNAX to default settings.

##### Finalize
`pnax.Finalize()` closes PNAX.