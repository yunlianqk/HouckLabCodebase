classdef IQData
% Raw and processed data for pulsed measurements

    properties
        meastype = []; % A string that describes the measurement
        rawdataI = []; % raw data
        rawdataQ = [];
        ampI = []; % integrated/demodulated data
        ampQ = [];
        phaseI = [];
        phaseQ = [];
        colAxis = []; % Corresponds to columns in rawdata
        rowAxis = []; % Corresponds to rows in rawdata
        intRange = []; % The start and end time for data integration
        intFreq = []; % Intermediate frequency when using heterodyne
        sampleinterval = [];
    end
    
    methods
        function s = toStruct(self)
        % Converts data object to a struct
            warning('off', 'MATLAB:structOnObject');
            s = struct(self);
            warning('on', 'MATLAB:structOnObject');
        end
        
        function data = integrate(self, data)
        % Integrate data
            if nargin == 1
                data = self;
            end
            if isempty(data.intRange)
                data.intRange = [data.colAxis(1), data.colAxis(end)];
            end
            sub = find(data.colAxis >= data.intRange(1), 1) ...
                  :find(data.colAxis >= data.intRange(2), 1);
            if isempty(data.sampleinterval)
                data.sampleinterval = data.colAxis(2) - data.colAxis(1);
            end
            % Software heterodyne demodulation
            [data.ampI, data.phaseI] = funclib.Demodulate(data.sampleinterval, ...
                                                data.rawdataI(:, sub), ...
                                                data.intFreq);
            [data.ampQ, data.phaseQ] = funclib.Demodulate(data.sampleinterval, ...
                                                data.rawdataQ(:, sub), ...
                                                data.intFreq);
        end

        function plot(self, data)
            % Plot data
            if nargin == 1
                data = self;
            end
            if isempty(data.intRange)
                data.intRange = [data.colAxis(1), data.colAxis(end)];
            end
            data = self.integrate(data);
            figure(123);
            % Plot raw data
            subplot(2, 3, 1);
            imagesc(data.colAxis, data.rowAxis, data.rawdataI);
            hold on;
            plot([data.intRange(1), data.intRange(1)], [1, length(data.rowAxis)], ...
                 '--r', 'LineWidth', 2);
            plot([data.intRange(2), data.intRange(2)], [1, length(data.rowAxis)], ...
                 '--r', 'LineWidth', 2);
            hold off;
            title('Raw data I');
            subplot(2, 3, 4);
            imagesc(data.colAxis, data.rowAxis, data.rawdataQ);
            hold on;
            plot([data.intRange(1), data.intRange(1)], [1, length(data.rowAxis)], ...
                 '--r', 'LineWidth', 2);
            plot([data.intRange(2), data.intRange(2)], [1, length(data.rowAxis)], ...
                 '--r', 'LineWidth', 2);
            hold off;
            xlabel('Time (\mus)');
            title('Raw data Q');
            % Plot integrated/demodulated data
            subplot(2, 3, 2);
            plot(data.rowAxis, data.ampI);
            title('Amplitude I');
            subplot(2, 3, 5);
            plot(data.rowAxis, data.ampQ);
            title('Amplitude Q');
            subplot(2, 3, 3);
            plot(data.rowAxis, data.phaseI);
            title('Phase I');
            subplot(2, 3, 6);
            plot(data.rowAxis, data.phaseQ);
            title('Phase Q');
        end
    
        function result = fit(self, data)
            if nargin == 1
                data = self;
            end
            if isempty(data.intRange)
                data.intRange = [data.colAxis(1), data.colAxis(end)];
            end
            data = self.integrate(data);
            tAxis = data.colAxis/1e-6;
            tRange = data.intRange/1e-6;
            figure;
            ax1 = subplot(2,2,2);
            ax2 = subplot(2,2,4);

            switch data.meastype
                % Fit the data according to the measurement type
                case 'Rabi'
                    dataAxis = data.rowAxis;
                    ytext = 'Rabi amplitude';
                    resultI = funclib.RabiFit(dataAxis, data.ampI, ax1)*2;
                    resultQ = funclib.RabiFit(dataAxis, data.ampQ, ax2)*2;
                    textI = sprintf('\\theta_{0.5} = %.3f \\pi', resultI/pi);
                    textQ = sprintf('\\theta_{0.5} = %.3f \\pi', resultQ/pi);
                case 'T1'
                    dataAxis = data.rowAxis/1e-6;
                    ytext = 'Delay (\mus)';
                    resultI = funclib.ExpFit(dataAxis, data.ampI, ax1);
                    resultQ = funclib.ExpFit(dataAxis, data.ampQ, ax2);
                    textI = sprintf('T_1 = %.2f \\mus', resultI);
                    textQ = sprintf('T_1 = %.2f \\mus', resultQ);
                case 'Ramsey'
                    dataAxis = data.rowAxis/1e-6;
                    ytext = 'Delay (\mus)';
                    resultI = funclib.ExpCosFit(dataAxis, data.ampI, ax1);
                    resultQ = funclib.ExpCosFit(dataAxis, data.ampQ, ax2);
                    textI = sprintf('T_2^* = %.2f \\mus', resultI);
                    textQ = sprintf('T_2^* = %.2f \\mus', resultQ);
                case 'Echo'
                    dataAxis = data.rowAxis/1e-6;
                    ytext = 'Delay (\mus)';
%                     resultI = funclib.ExpCosFit(dataAxis, data.ampI, ax1);
%                     resultQ = funclib.ExpCosFit(dataAxis, data.ampQ, ax2);
                    resultI = funclib.ExpFit(dataAxis, data.ampI, ax1);
                    resultQ = funclib.ExpFit(dataAxis, data.ampQ, ax2);
                    textI = sprintf('T_2^E = %.2f \\mus', resultI);
                    textQ = sprintf('T_2^E = %.2f \\mus', resultQ);
                otherwise
                    error('Unknown measurement type');
            end

            % Plot raw, integrated and fitted data
            subplot(2,2,1);
            imagesc(tAxis, dataAxis, data.rawdataI);
            hold on;
            plot([tRange(1), tRange(1)], [dataAxis(1), dataAxis(end)], ...
                 '--r', 'LineWidth', 2);
            plot([tRange(2), tRange(2)], [dataAxis(1), dataAxis(end)], ...
                 '--r', 'LineWidth', 2);
            hold off;
            ylabel(ytext);
            title('Raw data I');
            subplot(2,2,3);
            imagesc(tAxis, dataAxis, data.rawdataQ);
            hold on;
            plot([tRange(1), tRange(1)], [dataAxis(1), dataAxis(end)], ...
                 '--r', 'LineWidth', 2);
            plot([tRange(2), tRange(2)], [dataAxis(1), dataAxis(end)], ...
                 '--r', 'LineWidth', 2);
            hold off;
            xlabel('Time (\mus)');
            ylabel(ytext);
            title('Raw data Q');

            subplot(2,2,2);
            ylabel('V_I (V)');
            title('Integrated data I');
            text(0.1, 0.85, textI, 'Units', 'normalized', 'FontSize', 16);
            axis tight;
            subplot(2,2,4);
            xlabel(ytext);
            ylabel('V_Q (V)');
            axis tight;
            title('Integrated data Q');
            text(0.1, 0.85, textQ, 'Units', 'normalized', 'FontSize', 16);

            result = mean([resultI, resultQ]);
        end
    end
end