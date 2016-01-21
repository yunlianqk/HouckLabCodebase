function test_function(rfparams)

global rfgen logen triggen card

triggen.SetPeriod(40e-6);

card.fullscale = 1;
card.sampleinterval = 1e-9;
card.samples = 10000;
card.averages = 10000;
card.delaytime = 5e-6;
card.SetParams();

rfgen.SetFreq(rfparams.freq);
rfgen.SetPower(rfparams.power);
logen.SetFreq(rfparams.freq + rfparams.intfreq);
logen.SetPower(8);
rfgen.ModOff();
rfgen.PowerOn();
logen.PowerOn();
pause(rfparams.waittime);

[Idata, Qdata] = card.ReadIandQ();
figure(10);
subplot(2,1,1);
plot((0:card.samples-1)*card.sampleinterval/1e-6, Idata);
ylabel('V_I (V)');
subplot(2,1,2);
plot((0:card.samples-1)*card.sampleinterval/1e-6, Qdata);
ylabel('V_Q (V)');
xlabel('Time (\mus)');
end