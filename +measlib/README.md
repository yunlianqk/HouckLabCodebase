# measlib
A library containing classes for measurements using M9930A AWG and E8267D generators.

See also [single qubit gate calibration and randomized benchmarking procedure](./GateCalib&RB.md).

## Contents
- [Hardware configuration](#hardware-configuration)
- [SmartSweep class](#smartsweep-class)
    - [For users](#for-users)
        - [Setting paremeters](#setting-parameters)
        - [Pulse sequence](#pulse-sequence)
        - [Setting digitizer](#setting-digitizer)
        - [Running measurement](#running-measurement)
        - [Plotting data](#plotting-data)
        - [Saving data](#saving-data)
    - [For developers](#for-developers)
        - [Pulse timing and generation](#pulse-timing-and-generation)
        - [Setting up sweeps](#setting-up-sweeps)
        - [Adding new sweeps](#adding-new-sweeps)
- [API specifications](#api-specifications)

## Hardware configuration
The figure below shows the wiring of vector/analogue generators, AWG and acquisition card. The name of matlabs object for each equipment is shown in blue.The AWG **channels** connect to **wideband I/Q input** ports at the back of E8267D generators. The AWG **markers** connect to **gate/pulse/trigger input** ports at the front of E8267D generators. **Marker 1 of pulsegen1** connects to the trigger input of acquistion card.

![HardwareConfig](./SmartSweepInstrConfig.png)

See [M9330A AWG document](../@M9330AWG/README.md#multiple-module-synchronization) for AWG trigger, clock and synchronization settings.

## SmartSweep class
[`SmartSweep`](#class-smartsweep--handle) is an attempt to provide a generic, extensible interface for measurements using E8267D microwave generators and M9330A AWG.

### For users
For pre-defined measurements such as `TransSweep`, `SpecSweep`, `Rabi`, `T1`, etc., see [example code](../ExampleCode/ExampleCode_measlib.m).

To customize your own measurement:
- For CW measurement, set up the parameters you want to sweep (see discussion below).
- For pulsed measurement, provide `gateseq` and `measpulse` (and `fluxpulse` if there is any).
- Currently supported equipments are listed below.

|Class|Object name|Sweepable parameter|
|-----|-----------|-------------------|
|<br><br>E8267DGenerator<br><br>|rfgen<br>specgen<br>logen<br>fluxgen<br>specgen2|rffreq, rfpower, rfphase<br>specfreq, specpower, specphase<br>lofreq (automatically sweeps with rffreq)<br>fluxfreq, fluxpower, fluxphase<br>spec2freq, spec2power, spec2phase|
|YOKOGS200<br>YOKO7651|yoko1<br>yoko2|yoko1volt<br>yoko2volt|
|<br>M9330AWG<br>|pulsegen1<br>pulsegen2<br>|gateseq (for pulsegen1.waveform1 and waveform2)<br>measpulse (for pulsegen2.waveform1, **NON sweepable**)<br>fluxseq (for pulsegen2.waveform2)|

The objects for instruments **must be named** as listed in the second column above. For E8267D generators and YOKOGAWA voltage sources, sweeping paramters can be scalar, row vector, column vector, or 2D array (see next section for details). For M9330A AWG's, `gateseq` and `fluxseq` can be an object array of [`pulsegen.gateSequence`](../+pulselib/README.md#class-pulselibgatesequence--handle); `measpulse` can only be a single object of [`pulsegen.measPulse`](../+pulselib/README.md#class-pulselibmeaspulse--handle).

#### Setting parameters
The parameters can be scalar, row vector, column vector or 2D array. The result is shown in the code and table below.

```matlab
x = measlib.SmartSweep();
x.rfpower = -30;  % scalar: constant in measurement
x.rffreq = [5e9, 5.5e9, 6e9];  % row vector: inner loop
x.specfreq = [3e9; 4e9; 5e9];  % column vector: outer loop
x.specpower = [-10, -5, 0; ... 
               -20, -15, -10; ...
               -30, -25, -20];  % 2D array: both loops
```
||1|2|3|
|--------|--------|--------|--------|
|1|rfpower = -30<br>rffreq = 5e9<br>specfreq = 3e9<br>specpower = -10|rfpower = -30<br>rffreq = 5.5e9<br>specfreq = 3e9<br>specpower = -5|rfpower = -30<br>rffreq = 6e9<br>specfreq = 3e9<br>specpower = 0|
|2|rfpower = -30<br>rffreq = 5e9<br>specfreq = 4e9<br>specpower = -20|rfpower = -30<br>rffreq = 5.5e9<br>specfreq = 4e9<br>specpower = -15|rfpower = -30<br>rffreq = 6e9<br>specfreq = 4e9<br>specpower = -10|
|3|rfpower = -30<br>rffreq = 5e9<br>specfreq = 5e9<br>specpower = -30|rfpower = -30<br>rffreq = 5.5e9<br>specfreq = 5e9<br>specpower = -25|rfpower = -30<br>rffreq = 6e9<br>specfreq = 5e9<br>specpower = -20|

In the experiment, the sweep will go from one row to the next and the parameters will be looped accordingly.

#### Pulse sequence
Currently `SmartSweep` only supports pulsed measurements with a **single measurement pulse** and **multiple gateseq and/or fluxseq**. The waveforms of `gateseq` and `fluxseq` are aligned to their **end time**, as shown in the figure below. To adjust the timing of each sequence, add [`pulselib.delay`](../+pulselib/README.md#class-pulselibdelay--handle) objects when needed.  
![gateseq](./gateseq.png)  
The parameters `startBuffer`, `measBuffer` and `endBuffer` can be used to adjust pulse timing, as illustrated in the figure below.  
![waveforms](./waveforms.png)  
The duration of each pulse sequence is therefore `startBuffer + max([gateseq.totalDuration]) + measBuffer + measpulse.totalDuration + endBuffer`.

#### Setting digitizer
- `cardavg` specifies the number of averages for the digitizer.
- `trigperiod` and `cardacqtime` can be set to `'auto'` or manually specified. When set to `'auto'`, trigger period will be slightly longer than the full pulse sequence, and acquisition time will be slightly longer than the measurement pulse duration.
- `carddelayoffset` can be used to fine tune the delay time for the digitizer. When set to zero, acquisition should start roughly at the beginning of the measurement pulse. `carddelayoffset` specifies the **additional** delay (can be positive or negative) with respect to that value.

#### Running measurement
- `SetUp` method handles pulse timing, generates waveforms for AWG's and sets up relevant instruments.
- `bgsubtraction` property can be set to `[]`, `'speconoff'`, `'rfonoff'`, `'fluxonoff'`, `'pulseonoff'` for background subtraction.
- `Run` method starts the measurement and stores the measured data.

#### Plotting data
During the measurement the data will be plotted and updated.
- `plotsweep1 = 1/0` turns on/off plotting of outer loop.
- `plotsweep2 = 1/0` turns on/off plotting of inner loop.
- `plotupdate = n` updates the plot every `n` sweeping points.
- `intrange` sets the start and stop time for integrating raw data. For example, the following figure shows a T1 measurement with `intrange = [62e-6, 66e-6]` (dashed lines). Changing `intrange` and rerunning `Plot()` will calculate and plot the updated data.  
  ![intrange](./intrange.png)
  
#### Saving data
The measured data is stored in a *struct* `result`, which contains the following fields:
- `dataI` (*2D array*): raw data for I channel
- `dataQ`(*2D array*): raw data for Q channel
- `ampInt` (*1D array*): demodulated and integrated amplitude
- `phaseInt` (*1D array*): demodulated and integrated phase
- `tAxis` (*1D array*): time axis for digitizer
- `rowAxis` (*1D array*): axis corresponding to row in rawdata
- `intRange` (*2-element array*): start and stop time for integration window
- `intFreq` (*float*): intermediate frequency
- `sampleinterval` (*float*): sampling rate for digitizer

Most of the fields will be automatically filled when the measurement finishes and result can be visualized using `Plot` method. To save data, specify
- `savepath` (*string*): path for saving data. When left empty, path will be `C:\Data\`.
- `savefile` (*string*): file name for saving data. When left empty, file name will be the name of the class and a timestamp, e.g., `T1_20170205151747.mat`.
- `autosave` (*1/0*): turns on/off auto saving.

### For developers
See [pulselib](../+pulselib/README.md) and [pulseCal](../+paramlib/README.md#class-paramlibpulsecal) documents to get familiar with the classes that generates pulse sequences. In short, [`paramlib.pulseCal`](../+paramlib/README.md#class-paramlibpulsecal) provides an interface between gate parameters and gate objects, and [`pulselib.gateSequence`](../+pulselib/README.md#class-pulselibgatesequence--handle) provides an interface between gate objects and AWG waveforms.

The main method is `SetUp`, which is further divided into
- `UpdateParams`: updates parameters from `self.pulseCal` if it exists.
- `SetPulse`: calculates the pulse timing based on `gateseq`, `fluxseq`, `measpulse` and ``startBuffer`, `measBuffer`, `endBuffer`.
- `SetSweep`: decides the sweep type of each parameter based on its shape. Then sets up values and function handles for each parameter.
- `InitInstr`: starts relevant instrument and sets parameters for the first sweep.
- `SetOutput`: sets up function handles for plotting, background subtraction, waveform generation and fills some fields in `result`.

#### Pulse timing and generation
Pulse timing parameters are calculated in [SetPulse](./@SmartSweep/SetPulse.m) method:
```matlab
seqDuration = 0;
measDuration = 0;
try
    seqDuration = max([self.gateseq.totalDuration]);
catch
end

try
    seqDuration = max(seqDuration, ...
                      max([self.fluxseq.totalDuration]));
catch
end

try
    measDuration = self.measpulse.totalDuration;
catch
end

self.seqEndTime = self.startBuffer + seqDuration;
self.measStartTime = self.seqEndTime + self.measBuffer;
self.waveformEndTime = self.measStartTime + measDuration + self.endBuffer;
self.awgtaxis = 0:1/pulsegen1.samplingrate:self.waveformEndTime;
```
These parameters are then used in [SetSweep](./@SmartSweep/SetSweep.m) and [InitInstr](./@SmartSweep/InitInstr.m) methods when setting up function handles for waveform generation:
```matlab
% In SetSweep.m
function setgatewav(gateseq)
    ...
    [pulsegen1.waveform1, pulsegen1.waveform2] ...
        = gateseq.uwWaveforms(self.awgtaxis, self.seqEndTime-gateseq.totalDuration);
    ...
end

function setfluxwav(fluxseq)
    [pulsegen2.waveform2, ~] ...
        = fluxseq.uwWaveforms(self.awgtaxis, ...
                              self.seqEndTime-fluxseq.totalDuration);
end

% In InitInstr.m
% Measurement pulse is not in sweep setup because it is always the same
% Setting it once when initializing pulsegen2.waveform1 is enough
if ~isempty(self.measpulse)
    [pulsegen2.waveform1, ~] ...
        = self.measpulse.uwWaveforms(self.awgtaxis, self.measStartTime);
end
```

#### Setting up sweeps
This is done in [SetSweep](./@SmartSweep/SetSweep.m) method and is the most opaque part of the code. The idea is maintaining three **cell arrays of function handles** corresponding to the three types of sweeps ("inner loop", "outer loop" and "both loops") and three **data arrays** corresponding to the values that need to be swept. Then go through each parameter and decide whether it needs to be swept based on its shape. If it needs to be swept, create a corresponding function handle that sets the value of the instrument, and add it to the corresponding cell array (row vector -> inner loop; column vector -> outer loop; 2D array -> both loops). The values of the parameter that needs to be swept are added to the corresponding data array.
```matlab
global rfgen yoko1 yoko2;

% Error messages
emsg1 = 'Arrays must have the same number of rows';
emsg2 = 'Arrays must have the same number of columns';

% Length of outer loop
self.numSweep1 = 1;
% Length of inner loop
self.numSweep2 = 1;
% Data arrays
self.sweep1data = {};
self.sweep2data = {};
self.sweep3data = {};
% Function handle arrays
self.sweep1func = {};
self.sweep2func = {};
self.sweep3func = {};
% Loop indices
ii = 1;
jj = 1;
kk = 1;

% Each entry in pName is the name string of one parameter that can be swept
% Each entry in fHdle is the function handle that sets the parameter
pName = {'rffreq', 'rfpower', 'rfphase', ...
         'yoko1volt', 'yoko2volt'};
fHdle = {@rfgen.SetFreq, @rfgen.SetPower, @rfgen.SetPhase, ...
         @yoko1.SetVoltage, @yoko2.SetVoltage};
% Set up the sweep according to the shape of the pName{idx}
for idx = 1:length(pName)
    shape = size(self.(pName{idx}));
    if prod(shape) > 1
    % If not scalar
        if shape(1) > 1
            if shape(2) == 1
            % If column vector, add to outer loop
                self.sweep1data{ii} = self.(pName{idx});
                self.sweep1func{ii} = fHdle{idx};
                ii = ii + 1;
                if (self.numSweep1 > 1) && (self.numSweep1 ~= shape(1))
                    error(emsg1);
                end
                self.numSweep1 = shape(1);
            else
            % If 2D array, add to both loops
                self.sweep3data{kk} = self.(pName{idx});
                self.sweep3func{kk} = fHdle{idx};
                kk = kk + 1;
                if (self.numSweep1 > 1) && (self.numSweep1 ~= shape(1))
                    error(emsg1);
                end
                if (self.numSweep2 > 1) && (self.numSweep2 ~= shape(2))
                    error(emsg2);
                end
                self.numSweep1 = shape(1);
                self.numSweep2 = shape(2);
            end
        else
        % If row vector, add to inner loop
            self.sweep2data{jj} = self.(pName{idx});
            self.sweep2func{jj} = fHdle{idx};
            jj = jj + 1;
            if (self.numSweep2 > 1) && (self.numSweep2 ~= shape(2))
                error(emsg2);
            end
            self.numSweep2 = shape(2);
        end
    end
end
```
In the [`Run`](./@SmartSweep/Run.m) method, each value in the data arrays is passed to the corresponding function handle using `feval`.
```matlab
% Outer loop
for row = 1:self.numSweep1
    for idx1 = 1:length(self.sweep1data)
        feval(self.sweep1func{idx1}, self.sweep1data{idx1}(row));
    end
    % Inner loop
    for col = 1:self.numSweep2
        for idx2 = 1:length(self.sweep2data)
            feval(self.sweep2func{idx2}, self.sweep2data{idx2}(:, col));
        end
        for idx3 = 1:length(self.sweep3data)
            feval(self.sweep3func{idx3}, self.sweep3data{idx3}(row, col));
        end
        ...
    end
```

#### Adding new sweeps
To add a new instrument and its parameters (`yoko3` and `yoko3volt` are used in the example below) to `SmartSweep`,
- In class definition, add property `yoko3volt` to `SmartSweep`.
- In `SetSweep` method, add declaration `global yoko3` to the top.
- In `SetSweep` method, add `yoko3volt` to `pName`  
  ```matlab
  pName = {'rffreq', 'rfpower', 'rfphase', ...
           'yoko1volt', 'yoko2volt', 'yoko3volt'};
  ```
  and `@yoko3.SetVoltage` to `fHdle`  
  ```matlab
  fHdle = {@rfgen.SetFreq, @rfgen.SetPower, @rfgen.SetPhase, ...
           @yoko1.SetVoltage, @yoko2.SetVoltage, @yoko3.SetVoltage};
  ```
  
- In `InitInstr` method, add declaration `global yoko3` to the top.
- In `InitInstr` method, add initialization for `yoko3`  
  ```matlab
  if ~isempty(self.yoko3volt)
      yoko3.SetVoltage(self.yoko3volt(1));
  end
  ```

## API specifications
#### *class* SmartSweep < handle
- **Properties**:
    - **name** (*string, read-only*): Name of the measurement
    
    *Sweep control parameters*
    - **rffreq** (*float*): rfgen frequency
    - **rfpower** (*float*): rfgen power
    - **rfphase** (*float*): rfgen phase
    - **rfcw** (*0/1*): rfgen cw mode

    *similar parameters for specgen, logen, fluxgen, yokos, etc.*...
    
    *Pulse generation parameters*
    - **pulseCal** (*[paramlib.pulseCal](../+paramlib/README.md#class-paramlibpulsecal) object*): pulse paramters
    - **gateseq** (*[pulselib.gateSequence](../+pulselib/README.md#class-pulselibgatesequence--handle) object*): qubit pulse sequences
    - **measpulse** (*[pulselib.measPulse](../+pulselib/README.md#class-pulselibmeaspulse--handle) object*): measurement pulse
    - **fluxseq** (*[pulselib.gateSequence](../+pulselib/README.md#class-pulselibgatesequence--handle) object*): addition pulse sequence when needed

    *Pulse timing parameters*
    - **startBuffer** (*float*): buffer before pulse sequence starts
    - **measBuffer** (*float*): buffer between qubit pulses and measurement pulse
    - **endBuffer** (*float*): buffer after measurement pulse

    *Acquisition and trigger parameters*
    - **waittime** (*float*): wait time for instrument to stablize
    - **trigperiod** (*float or 'auto'*): trigger period
    - **carddelayoffset** (*float*): compensation for automatic acquisition delay
    - **cardacqtime** (*float or 'auto'*): duration of acquistion
    - **cardavg** (*integer*): number of averages
    - **bgsubtraction** (*string*): background subtraction. Current options are 'speconoff', 'rfonoff', 'fluxonoff', 'pulseonoff'.
    - **normalization** (*0/1*): append zero and pi gate to gate sequence for readout normalization
    - **intrange** (*2-element array*): start and stop time for integrating rawdata

    *Plotting parameters*
    - **plotsweep1** (*0/1*): plot on/off for outer loop
    - **plotsweep2** (*0/1*): plot on/off for inner loop
    - **plotupdate** (*integer*): plot updating frequency

    *Data saving parameters*
    - **autosave** (*0/1*): automatic data saving
    - **savepath** (*0/1*): file path for saving data
    - **savefile** (*string*): file name for saving data
    - **result** (*struct*): measured data. Contains fields
        - **dataI** (*2D array*): raw data for I channel
        - **dataQ** (*2D array*): raw data for Q channel
        - **ampInt** (*1D array*): demodulated and integrated amplitude
        - **phaseInt** (*1D array*): demodulated and integrated phase
        - **tAxis** (*1D array*): time axis for digitizer
        - **rowAxis** (*1D array*): axis corresponding to row in rawdata
        - **intRange** (*2-element array*): start and stop time for integration window
        - **intFreq** (*float*): intermediate frequency
        - **sampleinterval** (*float*): sampling rate for digitizer
- **Methods**:
    - **x = SmartSweep()**: returns a SmartSweep object `x`
    - **x.SetUp()**: sets up the measurement
    - **x.Run()**: runs the measurement
    - **x.Plot()**: plots the measured data
    - **x.Save()**: saves the measured data
