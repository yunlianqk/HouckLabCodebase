# PNA-X Network Analyzer
## Usage

## Class Definition
#### *class* PNAXAnalyzer < GPIBINSTR
* **Properties**: 
  * **address** (*integer*, Read-only): GPIB address of the instrument
  * **instrhandle** (*GPIB object*, Read-only):  Handle to communicate with instrument
  * [**transparams**](#transparams) (*structure*, Dependent): Contains parameters for transmission measurement
  * [**specparams**](#specparams) (*structure*, Dependent):Contains parameters for spectroscopy measurement 
  * **defaulttransparams** (*structure*, Private): Contains default transmission parameters
  * **defaultspecparams** (*structure*, Private): Contains default spectroscopy parameters
  * **timeout** (*float*, Private): Wait time when there is error in communication

* **Methods**:
  * [**PNAXAnalyzer**](#pnaxanalyzer)
  * [**SetTransParams**](#settransparams)
  * [**SetSpecParams**](#setspecparams)
  * [**SetActiveChannel**](#setactivechannel)
  * [**SetActiveTrace**](#setactivetrace)
  * [**SetActiveMeas**](#setactivemeas)
  * [**GetTransParams**](#gettransparams)
  * [**GetSpecparams**](#getspecparams)
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

## API Specifications
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

##### PNAXAnalyzer
`pnax = PNAXAnalyzer(address)` opens PNAX with `address` and returns a `pnax` object.

##### SetTransParams
`pnax.SetTransParams(transparams)` sets up the [parameters](#transparams) for transmission measurement.

##### SetSpecParams
`pnax.SetSpecParams(specparams)` sets up the [parameters](#specparams) for spectroscopy measurement.

##### SetActiveChannel
`pnax.SetActiveChannel(channel)` sets the channel specified by *interger* `channel` as active.

##### SetActiveTrace
`pnax.SetActiveTrace(trace)` sets the trace specified by *integer* `trace` as active.

##### SetActiveMeas
`pnax.SetActiveMeas(meas)` sets the measurement specified by *string* `meas` as active.

##### GetTransParams
`transparams = pnax.GetTransParams()` returns a *structure* `transparams` containing the parameters of the active transmission measurement.

##### GetSpecparams
`specparams = pnax.GetSpecparams()` returns a *structure* `specparams` containing the parameters of the active spectroscopy measurement.

##### GetChannelList
`chlist = pnax.GetChannelList()` returns an *array* `chlist` containing the number for each channel.

##### GetTraceList
`trlist = pnax.GetTraceList()` returns an *array* `trlist` containing the number for each trace.

##### GetMeasList
`measlist = pnax.GetMeasList(channel)` returns an *string cell array* `mealist` containing the name of each measurement in `channel`.

If `channel` is missing, the active channel will be used.

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
`data = ReadTrace(pnax, trace)` reads the trace specified by *integer* `trace` and returns `data`. 

If `trace` is missing, the active trace will be used.

##### ReadChannel
`dataarray = ReadChannel(channel)` reads all the measurements in the channel specified by *integer* `channel` and returns `dataarray`.

`dataaaray` contains n lines of data, where n is the number of measurements in `channel` and each line contains the data for one measurement.

If `channel` is miising, the active channel will be used.

##### CreateMeas
`pnax.CreateMeas(channel, trace, meas, meastype)` creates a measurement according to the input parameters.
  * *integer* `channel`: channel number
  * *integer* `trace`: trace number
  * *string* `meas`: measurement name
  * *string* `meastype`: measurement type, e.g., 'S21', 'S13', etc.

##### DeleteChannel
`pnax.DeleteChannel(channel)` deletes a channel specified by *integer* `channel`.

##### DeleteTrace
`pnax.DeleteTrace(trace)` deletes a trace specified by *integer* `trace`.

##### DeleteMeas
`pnax.DeleteMeas(channel, meas)` deletes a measurement named `meas` from `channel`.

##### PowerOn
`pnax.PowerOn()` turns on the output power.

##### PowerOff
`pnax.PowerOff()` turns off the output power.

##### TrigContinuous
`pnax.TrigContinuous()` sets the trigger to continuous for the active channel.

##### TrigHold
`pnax.TrigHold()` sets the trigger to hold for the active channel.

##### TrigSingle
`pnax.TrigSingle()` sets the trigger to single for the active channel.

##### TrigHoldAll
`pnax.TrigHoldAll()` holds the trigger for all channels.

##### AvgOn
`pnax.AvgOn()` turns on average.

##### AvgOff
`pnax.AvgOff()` turns off average.

##### AvgClear
`pnax.AvgClear()` clears average.

##### AutoScale
`pnax.AutoScale()` auto scales the active trace.

##### AutoScaleAll
`pnax.AutoScaleAll()` auto scales all traces.

##### Reset
`pnax.Reset()` resets PNAX to default settings.

##### Finalize
`pnax.Finalize()` closes PNAX.
