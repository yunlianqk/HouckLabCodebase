classdef RBRepeat < handle
    % Repeat RB experiment to get gate fidelity
    
    properties
        experimentName;
        repeat = 10;
        sequenceLengths = [];
        sequenceIndices = [];
        rb = [];
        pulseCal;
        result;
        autosave = 0;
        savepath = 'C:\data\';
        savefile;
    end
        
    methods
        function self = RBRepeat(pulseCal)
            self.pulseCal = pulseCal;
            name = strsplit(class(self), '.');
            self.experimentName = name{end};
        end
            
        function SetUp(self)
            if isempty(self.rb)
                self.rb = explib.RBExperiment(self.pulseCal);
                self.rb.sequenceLengths = unique(round(logspace(log10(1), log10(1000), 20)));
                self.rb.cavitybaseband = 1;
                self.rb.bgsubtraction = 0;
                self.rb.normalization = 1;
                self.rb.cardAverages = 50;
                self.rb.softwareAverages = 30;
            end
            if ~isempty(self.sequenceLengths)
                self.rb.sequenceLengths = self.sequenceLengths;
            else
                self.sequenceLengths = self.rb.sequenceLengths;
            end
        end
        
        function Run(self)
            tic;
            self.savefile = [self.experimentName, '_', datestr(now(), 'yyyymmddHHMMSS'), '.mat'];
            self.result.AmpInt = zeros(self.repeat, length(self.sequenceLengths));
            self.result.AmpGnd = zeros(1, self.repeat);
            self.result.AmpEx = zeros(1, self.repeat);
            x = self.rb;
            for ind = 1:self.repeat
                display(['RBSequence ', num2str(ind), ' running']);
                x.sequenceIndices = [];
                if size(self.sequenceIndices, 1) >= ind
                    x.sequenceIndices = self.sequenceIndices(ind, :);
                end
                x.SetUp();
                self.sequenceIndices(ind, :) = x.sequenceIndices; 
                x.Download();
                x.Run();
                toc;
                self.result.AmpInt(ind, :) = x.result.AmpInt;
                self.result.AmpGnd(ind) = x.result.AmpGnd;
                self.result.AmpEx(ind) = x.result.AmpEx;
                figure(144);
                subplot(1, 2, 1);
                imagesc(self.result.AmpInt(1:ind, :));
                title([x.experimentName, ' ', num2str(ind), ' of ', num2str(self.repeat)]);
                subplot(1, 2, 2);
                self.result.rbFit ...
                    = funclib.RBFit(self.sequenceLengths, self.result.AmpInt(1:ind, :));
                if self.autosave
                    self.Save();
                end
            end
            subplot(1, 2, 1);
            imagesc(self.sequenceLengths, 1:ind, self.result.AmpInt);
            xlabel('# of Cliffords');
            ylabel('Sequence');
            title(self.experimentName);
            colorbar;
        end
        
        function Plot(self)
            figure(144);
            subplot(1, 2, 1);
            imagesc(self.sequenceLengths, 1:self.repeat, self.result.AmpInt);
            xlabel('# of Cliffords');
            ylabel('Sequence');
            colorbar;
            title(self.experimentName);
            subplot(1, 2, 2);
            rbFit = funclib.RBFit(self.sequenceLengths, self.result.AmpInt);
            self.result.Fidelity = rbFit.avgGateFidelity;
        end
        
        function Save(self)
            path = self.savepath;
            if ~strcmp(path(end), filesep())
                path = [path, filesep()];
            end
            result = self.result;
            temppulseCal = self.pulseCal;
            self.pulseCal = funclib.obj2struct(self.pulseCal);
            x = funclib.obj2struct(self);           
            save([path, self.savefile], 'x', 'result');
            display(['Data saved to ', path, self.savefile]);
            self.pulseCal = temppulseCal;
        end
    end
end