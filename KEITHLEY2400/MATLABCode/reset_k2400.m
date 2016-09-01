% reset all the registers & clean up
% if the registers are not properly reset, 
% subsequent runs will not work!
fprintf(k2400,'*RST');
fprintf(k2400,':*CLS ');
fprintf(k2400,':*SRE 0');
% make sure STB bit is 0
STB = query(k2400, '*STB?');
fclose(k2400);
delete(k2400)
clear k2400