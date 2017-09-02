function params = GetParams(self)
    %how to get software default
    params = paramlib.m9703a(); %will be overwritten with actual hardware settings

    %matlab syntax to get variables, it works if you can find the heading
    %they are under
%     params.trigSource = self.instrID.Trigger.Active_Trigger_Source 

    %C-style syntax for getting variables. You need to look up their type
    %and identification number in the c driver AgMD1_chm
%     params.samplerate = invoke(self.instrID.Attributeaccessors, 'getattributevireal64',...
%     '', 1250015);



    warning('off', 'instrument:ivicom:MATLAB32bitSupportDeprecated');
    

    params.samplerate = invoke(self.instrID.Attributeaccessors, 'getattributevireal64',...
    '', 1250015); 
%     disp(['samplerate ' params.samplerate])
%     disp( params.samplerate)
    
    params.samples = invoke(self.instrID.Attributeaccessors, 'getattributeviint64',...
    '', 1250014); %record_size
%     disp(['samples ' params.samples])
%     disp(params.samples)
    
    params.averages= 1;
    
    params.segments = invoke(self.instrID.Attributeaccessors, 'getattributeviint64',...
    '', 1250013); %num_records
%     disp(['segments ' params.segments])
%     disp(params.segments)
    
    params.fullscale = invoke(self.instrID.Attributeaccessors, 'getattributevireal64',...
    'Channel1', 1250026); %vertical_range
%     disp(['fullscale ' params.fullscale])
    
    params.offset = invoke(self.instrID.Attributeaccessors, 'getattributevireal64',...
    'Channel1', 1250025); %vertical_offset
%     disp(['offset ' params.offset])
    
    couplecode = invoke(self.instrID.Attributeaccessors, 'getattributeviint32',...
    'Channel1', 1250024); %vertical_coupling
    if couplecode == 1
        params.couplemode == 'DC';
    elseif couplecode == 0
        params.couplemode == 'AC';
    end
%     disp(['couplemode ' params.couplemode])
    
    params.delaytime = invoke(self.instrID.Attributeaccessors, 'getattributevireal64',...
    '', 1250017); %trigger_delay
%     disp(['delaytime ' params.delaytime])
    
    params.trigSource = invoke(self.instrID.Attributeaccessors, 'getattributevistring',...
    '', 1250001, 256); %active_trigger_source
%     disp(['trigsource ' params.trigSource])
    
    params.trigLevel = invoke(self.instrID.Attributeaccessors, 'getattributevireal64',...
    params.trigSource, 1250019); %active_trigger_source
%     disp(['trigLevel ' params.trigLevel])
    
    
   
end