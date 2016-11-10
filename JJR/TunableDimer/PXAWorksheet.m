
pxa.bw=30e3;
pxa.video=20e3;
pxa.start=1;
pxa.stop=10e6;
pxa.averageCount=1000;

%%

% freqVec=[linspace(7.586254e9-detuning,7.586254e9+detuning,5)];
freqVec=[7.587334e9];
for idx=1:length(freqVec)
    
    rfgen.freq=freqVec(idx);
    rfgen.startPow=20;
    rfgen.stopPow=-20;
    
    rfgen.numPoints=40;
    rfgen.powVec=linspace(rfgen.startPow,rfgen.stopPow,rfgen.numPoints);

    
    pxaspect.span=20.0e6;
    pxaspect.startFreq=rfgen.freq-pxaspect.span/2;
    pxaspect.stopFreq=rfgen.freq+pxaspect.span/2;
    pxaspect.numPoints=3001;
    pxaspect.freqVec=linspace(pxaspect.startFreq,pxaspect.stopFreq,...
        pxaspect.numPoints);
    
    pxaspect.waitTime=25;
    saveBOOL=1;
    
    fprintf(instr.rfgen, 'OUTP 0');
    %% Set up Spectrum Analyzer
    % pxaspect settings
    fclose(instr.pxaspect);
    set(instr.pxaspect, 'InputBufferSize', 10000000);
    %set(instr.spect, 'Timeout',
    fopen(instr.pxaspect);
    pxaspect.bW=0.5e3;
    pxaspect.video=2.5e3;
    pxaspect.averageCount=3000;
    % pxaspect.freqSpan = pxaspect.stopFreq-pxaspect.startFreq ;
    % pxaspect.centerFreq = (pxaspect.stopFreq+pxaspect.startFreq)/2 ; %% From Reference Fig. populate with 5 nearest peaks.
    pxaspect.averWait = 100;
    pxaspect.readWait = 100;
    % freqVec = linspace(pxaspect.centerFreq-pxaspect.freqSpan/2,pxaspect.centerFreq+...
    %     pxaspect.freqSpan/2,pxaspect.numPoints);
    fprintf(instr.pxaspect, [':SENSE:BAND ' num2str(pxaspect.bW) 'HZ ']);
    fprintf(instr.pxaspect, [':SENSE:Band:video  ' num2str(pxaspect.video) 'HZ '] );
    fprintf(instr.pxaspect, ':AVER ON ');
    fprintf(instr.pxaspect, [':AVER:Count ' num2str(pxaspect.averageCount)] );
    fprintf(instr.pxaspect, [':SWEEP:POINTS ' num2str(pxaspect.numPoints)]);
    
    
    
    %% Set up Scan Parameters
    
    % set up rfgen
    fprintf(instr.rfgen, ['FREQ ', num2str(rfgen.freq)]);
    
    fprintf(instr.rfgen, 'OUTP 0');
    pause(1)
    clear pxaspectData pxaspectDataDiff pxaspectDataBaseLine
    
    for counter = 1:length(rfgen.powVec)
        if counter == 1
            tStart = tic;
            time = clock;
            fprintf(instr.pxaspect, ['freq:start ' num2str(pxaspect.startFreq) 'HZ']);
            fprintf(instr.pxaspect, ['freq:stop ' num2str(pxaspect.stopFreq) 'HZ']);
            fprintf(instr.pxaspect,':AVERage:CLEar');
            pause(pxaspect.waitTime);
            pxaspectDataBaseLine = read_PXA(instr);
        end
        filename=['fluorescencePowerSweepI1O3_A3_PXA_' num2str(rfgen.freq/1e9) '_' ...
            num2str(time(1)) num2str(time(2)) num2str(time(3))...
            num2str(time(4)) num2str(time(5))];
        
        fprintf(instr.rfgen, ['FREQ ', num2str(rfgen.freq)]);
        fprintf(instr.rfgen, ['POW ', num2str(rfgen.powVec(counter)),' dBm']);
        fprintf(instr.rfgen, 'OUTP 1');
        
        fprintf(instr.pxaspect, ['freq:start ' num2str(pxaspect.startFreq) 'HZ']);
        fprintf(instr.pxaspect, ['freq:stop ' num2str(pxaspect.stopFreq) 'HZ']);
        fprintf(instr.pxaspect,':AVERage:CLEar');
        pause(pxaspect.waitTime);
        pxaspectData(counter,:) = read_PXA(instr);
        pxaspectDataDiff(counter,:) = pxaspectData(counter,:)-pxaspectDataBaseLine;
        
        fig = figure(idx+700);
        set(fig,'Position', [100, 100, 1449, 895]);
        imagesc(pxaspect.freqVec/1e9,rfgen.powVec(1:counter),...
            pxaspectDataDiff(1:counter,:))
        ylabel('Drive Power [dBm]')
        xlabel('Frequency [GHz]')
        title(['rfgen.freq = ',num2str(rfgen.freq/1e9), ' GHz,',...
            filename]);
        c=colorbar;
        caxis([0 20]);
        colormap(brewermap([],'Blues'));
        hL=ylabel(c,'Power [dBm]','FontSize',10);
        set(hL,'Rotation',270);
        set(hL,'Units','Normalized','Position',[4.2,0.5,0]);
        
        
        if counter == 1;
            deltaT = toc(tStart);
            disp(['Estimated Time is ',...
                num2str(length(freqVec)*length(rfgen.powVec)*deltaT/3600),' hrs']);
        end
        if saveBOOL & mod(counter,10)==0
            save([filename '.mat'],...
                'rfgen',...
                'pxaspect','pxaspectData',...
                'pxaspectDataDiff',...
                'pxaspectDataBaseLine');
        end
    end
    if saveBOOL
        save([filename '.mat'],...
            'rfgen',...
            'pxaspect','pxaspectData',...
            'pxaspectDataDiff',...
            'pxaspectDataBaseLine');
        savefig([filename '.fig']);
    end
end
fprintf(instr.rfgen, 'OUTP 0');
