# GPIBINSTR
A superclass containing some basic properties and methods that any GPIB instrument can inherit.

## Class definition
#### *class* GPIBINSTR < handle
* **Properties**: 
  * **address** (*string*): GPIB address of the instrument
  * **instrhandle** (*GPIB object*):  Handle to communicate with instrument
  
* **Methods**:
  * **self = GPIBINSTR(address)**: Opens the instrument using the GPIB `address` and returns an object
  * **self.SendCommand(command)**: Sends *string* `command` to the instrument
  * **self.GetReply()**: Reads data from the instrument's output buffer
  * **self.Query(command)**: Sends *string* `command` to the instrument and reads its output
  * **self.Info()**: Displays general information about instrument
  * **self.Reset()**: Resets instrument
  * **self.Finalize()**: Closes the instrument
