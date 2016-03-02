================================================================================
FOR USERS
================================================================================
To set up a transmission scan, first fill the fiels in pnax.transparams.
You can create a struct and then pass it to pnax.transparams:
    transparams.start = 6.25087e9;
    transparams.stop = 6.26087e9;
    transparams.points = 3001;
    transparams.power = -60;
    transparams.averages = 65536;
    transparams.ifbandwidth = 3e3;
    pnax.transparams = transparams;
	
Or edit pnax.transparams directly:
    transparams.trace = 1;
    transparams.meastype = 'S21';
    transparams.format = 'MLOG';
    pnax.transparams = transparams;

Unfilled fields will remain their previously set values.

Then use pnax.SetTransParams() to set up the scan.
use pnax.Read() and pnax.GetAxis() to read the data.

To set up multiple traces, use
    pnax.transparams.trace = 2;
    pnax.transparams.format = 'UPH';
    pnax.SetTransParams();
to add traces.
Use pnax.SetActiveTrace(2) to switch to phase trace and then pnax.Read().
================================================================================
IMPORTANT!!
================================================================================
The trace number set in the code is DIFFERENT than the trace number displayed on
the PNAX panel. The trace number in the code is for remote control only. The
trace number on the panel will be in the order of the creation of the trace.
To pick a specific trace in your program, you should always use the trace number
set by pnax.transparams.trace.

================================================================================
FOR PROGRAMMERS
================================================================================
The elements in PNAX programming include "windows", "channels", "traces" and
"measurements". Read the manual and get familiar with these concepts.

In the current implementation, the conventions are:
- Use only one window (window 1) for all measurments.
- Use channel 1 for transmission and channel 2 for spectroscopy.
- The name of each measurement is 'CHx_TRy' where x and y are the channel number
  and trace number respectively.
  
The method MeasName generates the name for the measurement according to the 
above convention. The method CreateMeas creates a measurement and feed it to a
trace according to its parameters.