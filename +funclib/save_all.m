function  save_all(save_path)
%save all .m files in directiory,
%and all variables in the name space of the .m file from which this is
%called


full_path_info = evalin('base', 'mfilename(''fullpath'')');
current_file_name = evalin('base', 'mfilename()');
folder_breaks = regexp(full_path_info,'\');
current_file_location = full_path_info(1:max(folder_breaks));
clear folder_breaks full_path_info




% who_to_save = evalin('base', 'who');
% disp(who_to_save)
whos_to_save = evalin('base', 'whos');
% disp(whos_to_save)

AllFiles = funclib.TextSave(current_file_location);
all_vars = whos_to_save;
save_variables = struct;
for i=1:length(all_vars)
    var_name = all_vars(i).name;
%     disp(var_name)
%     disp(evalin('base', var_name))
%     if isa(eval(var_name),'Experiment') || isa(eval(var_name),'Block')
%         continue
%     end
    if all_vars(i).global == 1
      try
        save_variables.(var_name) = struct(evalin('base',var_name));
      catch
        save_variables.(var_name) = evalin('base',var_name);
      end
    else
        save_variables.(var_name) = evalin('base',var_name);
    end
end
save_variables.('current_file_location') = eval('current_file_location');
save_variables.('current_file_name') = eval('current_file_name');

save(save_path, 'save_variables', 'AllFiles');



end

