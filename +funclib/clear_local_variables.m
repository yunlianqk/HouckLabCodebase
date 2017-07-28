function clear_local_variables()
%%%%This function does not work!!!!!!

%     disp('inside the clear function')
    %clear all local variables
    all_vars = evalin('base','whos');
    for i=1:length(all_vars)
       var_name = all_vars(i).name;
%        disp(var_name)
       if strcmp(var_name, 'all_vars')
           continue
       elseif all_vars(i).global ==1
           continue
       end
       cmdstr = num2str(['clearvars(''' var_name ''')']);
       evalin('base', cmdstr)
    end
    clearvars('i')
    clearvars('all_vars')
    clearvars('var_name')
    
%     disp('exiting the clear function')


end