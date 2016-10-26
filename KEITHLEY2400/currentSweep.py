import numpy as np
import matplotlib.pyplot as plt
from keithley import KEITHLEY2400
# %%
instr = KEITHLEY2400()
# %%
# Set parameters
start = 0.0
stop = 5.0e-6
step = 0.05e-6
compliance = 5.0
# Get data
Vlist, Ilist = instr.sweepI(start, stop, step, compliance)
# Plot and fit data
Vlist = np.array(Vlist)
Ilist = np.array(Ilist)
R, V0 = np.polyfit(Ilist, Vlist, 1)
plt.close('all')
plt.figure(1)
plt.plot(Ilist, Vlist, '*')
plt.plot(Ilist, Ilist*R+V0)
plt.xlabel('Current (A)')
plt.ylabel('Voltage (V)')
plt.legend(['Data', 'Fit'], loc='lower right')
plt.text(0.1, 0.9,
         r'$V = I \times %f + %f$' % (R, V0),
         transform=plt.gca().transAxes,
         fontsize=20)
# %%
instr.finalize()
