function Generate(awg_handle, wform, channelnum)
  
    if channel
    trigWaveform = ones(1,length(taxis)).*(taxis>(triggerWaitTime)).*(taxis<(triggerWaitTime+1e-6));
    % set up trigger
    trig = trigWaveform;

    %Download waveforms
    fprintf(awg_handle, 'wlis:wav:del all');
    fprintf(awg_handle,'awgc:stop');
    fprintf(awg_handle, 'awgc:rmod trig');
   

    %load waveforms onto waveform list
    DigWform = ADConvert(wform, 'ch');
    WformName = 'wform';
    DigWform_Markers = ADConvert(trig,trig,'ch_marker');
    TekTransferWform2(awg_handle, WformName, DigWform, DigWform_Markers, length(wform));
    
    %load waveforms from the list onto the channels
    fprintf(awg_handle, 'sour2:wav "wform" ');
    % fprintf(tek.instrhandle, 'sour2:Dig:Voltage:OFFSET 0.0') %this does nothing, set manually
    fprintf(awg_handle, 'output2 on');

    fprintf(awg_handle,'awgc:run');
    %
    % Start pulse generation. 
    fprintf(awg_handle,'awgc:run'); 
    
end