testNum = 0;
while 1
    testNum = testNum+1;
    display(' ')
    display(' ')
    display(' ')
    display('**********************************')
    display(['Test number ' num2str(testNum)])
    whos
    memory   
%     clear x
%     x=explib.X90DragCal_memLeakTest(pulseCal);
%     playlist = x.directDownloadM8195A(awg);
    result = x.directRunM8195A(awg,card,cardparams,playlist);
end