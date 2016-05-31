function run(self)
% Run pulsed measurement with M9330A AWG and acqiris digitizer

    self.setWaveforms();
    self.setInstr();
    pause(0.2);
    % Get time axis from mpulsegen for plotting pulse sequences
    tAxis = self.instr.mpulsegen.timeaxis;
    % Get time axis from digitizer for plotting raw data
    tDigitizer = (0:self.instr.digitizer.params.samples-1) ...
                 *self.instr.digitizer.params.sampleinterval;
    self.data.tAxis = tDigitizer;
    % preallocate rawdata
    numSteps = size(self.qWaveforms, 1)/2;
    self.data.rawdataI = zeros(numSteps, self.instr.digitizer.params.samples);
    self.data.rawdataQ = zeros(numSteps, self.instr.digitizer.params.samples);
    
    tStart = tic();
    for step = 1:numSteps
        % Load waveforms for qpulsegen
        % Odd lines are inphase component
        % Even lines are quadrature component
        self.instr.qpulsegen.waveform1 = self.qWaveforms(2*step-1,:);
        self.instr.qpulsegen.waveform2 = self.qWaveforms(2*step,:);
        % Generate qubit drive pulse
        self.instr.qpulsegen.AutoMarker();
        self.instr.qpulsegen.Generate();
        % Turn specgen on and off, subtract "off signal" from "on signal"
        self.instr.specgen.PowerOn();
        pause(0.1);
        [Ondatai, Ondataq] = self.instr.digitizer.ReadIandQ();
        self.instr.specgen.PowerOff();
        pause(0.1);
        [Offdatai, Offdataq] = self.instr.digitizer.ReadIandQ();
        self.data.rawdataI(step,:) = Ondatai - Offdatai;
        self.data.rawdataQ(step,:) = Ondataq - Offdataq;
        % Update plots every 10 steps
        if mod(step, 10) == 1
            figure(20);
            % Plot pulse sequence
            subplot(2,2,1);
            hold off;
            plot(tAxis/1e-6, self.instr.qpulsegen.waveform1, ...
                 tAxis/1e-6, self.instr.qpulsegen.waveform2, 'r');
            ylim([-1, 1]);
            legend('I', 'Q');
            ylabel('Amplitude');
            title('Drive pulses');
            subplot(2,2,3);
            hold off;
            plot(tAxis/1e-6, self.instr.mpulsegen.waveform1);
            xlabel('Time (\mus)');
            ylabel('Amplitude');
            title('Measurement pulse');
            % Plot raw data
            subplot(2,2,2);
            hold off;
            imagesc(tDigitizer/1e-6, 1:step, ...
                    self.data.rawdataI(1:step,:));
            ylabel('# of experiment');
            title('Inphase');
            subplot(2,2,4);
            hold off;
            imagesc(tDigitizer/1e-6, 1:step, ...
                    self.data.rawdataQ(1:step,:));
            xlabel('Time (\mus)');
            ylabel('# of experiment');
            title('Quadrature');
            % Create a process bar that estimates remaining time
            if step == 1
                h = waitbar(0);
            end
            waitbar(step/numSteps, h, ...
                    sprintf('Step %d of %d, remaining time: %d seconds', ...
                            step, numSteps, round(toc(tStart)/step*(numSteps-step))));
        end
    end
    delete(h);
    self.data.intdataI = [];
    self.data.intdataQ = [];
    self.data.tRange = [];
end