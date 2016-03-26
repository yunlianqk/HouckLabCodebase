# GPIBINSTR
A superclass containing some basic properties and methods that any GPIB instrument can inherit.

## Class definition
#### *class* GPIBINSTR < handle
* **Properties**: 
  * **address** (*integer*): GPIB address of the instrument
  * **instrhandle** (*GPIB object*):  Handle to communicate with instrument
  
* **Methods**:
  * **self = GPIBINSTR(address)**: Open the instrument using the GPIB `address` and returns an object
  * **self.Finalize()**: Close the instrument
  * **self.SendCommand(command)**: Send *string* `command` to the instrument
