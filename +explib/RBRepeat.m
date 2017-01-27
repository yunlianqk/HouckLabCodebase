classdef RBRepeat < handle
    % Repeat RB experiment to get gate fidelity
    
    % To use this class, generate an 'explib.RBExperiment' object first
    % and set its properties (sequenceLengths, card/soft averages, etc.)
    % Then pass it to self.rb
    % 'repeat' specifies how many times the RB sequence is repeated
    % Each repeat uses a different random sequence of Clifford gates
    
    % For normal usage, leave 'sequenceLengths' and 'sequenceIndices' as empty.
    
    % sequenceIndices can be specified manually. It should be a 2D array of
    % random numbers between 0 and 24 (for single qubit Clifford group).
    % The size of the array should be [self.repeats, max(self.rb.sequenceLengths)].
    % This is useful to redo an exact realization of RBRepeat experiment.
    
    properties
        experimentName;
        repeat = 10;
        sequenceLengths = [];
        sequenceIndices = [];
        rb = [];
        result;
        autosave = 0;
        savepath = 'C:\data\';
        savefile;
    end

    methods
        function self = RBRepeat(rb)
            self.rb = rb;
            name = strsplit(class(self), '.');
            self.experimentName = name{end};
            self.sequenceLengths = self.rb.sequenceLengths;
        end
        
        function SetUp(self)
            self.sequenceLengths = self.rb.sequenceLengths;
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
                    = funclib.RBFit(x.sequenceLengths, self.result.AmpInt(1:ind, :));
                if self.autosave
                    self.Save();
                end
            end
            subplot(1, 2, 1);
            imagesc(x.sequenceLengths, 1:ind, self.result.AmpInt);
            xlabel('# of Cliffords');
            ylabel('Sequence');
            title(self.experimentName);
            colorbar;
			drawnow;
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
			drawnow;
            self.result.Fidelity = rbFit.avgGateFidelity;
        end
        
        function Save(self)
            global card;
            path = self.savepath;
            if ~strcmp(path(end), filesep())
                path = [path, filesep()];
            end
            temppulseCal = self.rb.pulseCal;
            
            result = self.result;
            self.rb.pulseCal = funclib.obj2struct(self.rb.pulseCal);
            x = funclib.obj2struct(self);
            x.rb = funclib.obj2struct(self.rb);
            cardparams = funclib.obj2struct(card.params);
            save([path, self.savefile], 'x', 'result', 'cardparams');
            display(['Data saved to ', path, self.savefile]);
            self.rb.pulseCal = temppulseCal;
        end
    end
end