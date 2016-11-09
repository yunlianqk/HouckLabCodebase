function datatrace = Read(pxa)

fprintf(pxa.instrhandle, ':FORMat ASCii');
fprintf(pxa.instrhandle, ':TRACe? TRACE1');
data_buffer = fscanf(pxa.instrhandle, '%s');
datatrace = str2num(data_buffer);

end