classdef M8195AWG < handle
% Contains parameters and methods for M8195A awg

    properties (Access = public)
        samplerate;     % sample rate
        granularity;    % segement length needs to be multiple of segment granularity
        minSegSize;     % minimum number of samples per segement
        maxSegSize;     % maximum number of samples per segment
        maxSegNumber;   % maximum number of segments we can download
        
    end

    methods
        function self = M8195AWG()
            % Add iqtools folder to path
            addpath('C:\Users\newforce\Documents\GitHub\HouckLabMeasurementCode\iqtools')
            
            % Open IQ config window in iqtools
            % choose the configuration settings
            % Then press Ok button to finalize
            iqconfig();
            message={'Have you finalized M8195AWG configuration?','If yes press OK'};
            uiwait(msgbox(message));
            
            % Import correction .mat file
            % to be used for downloading predistorted waveforms to the awg
            % this needs to be done only once
            iqcorrmgmt();
            message={'Have you imported correction file?',' If yes press OK'};
            uiwait(msgbox(message));
            
            % Make sure you can connect to the awg
            f = iqopen();
            fprintf(f, ':abort');
            
            % update awg sample rate property
            arbConfig = loadArbConfig();
            self.samplerate = arbConfig.defaultSampleRate;
            self.granularity = arbConfig.segmentGranularity;
            self.minSegSize = arbConfig.minimumSegmentSize;
            self.maxSegSize = arbConfig.maximumSegmentSize;
            self.maxSegNumber = arbConfig.maxSegmentNumber;

            display([class(self), ' object created.']);
        end
        
        % Declaration of all methods
        % Each method is defined in a separate file
        WaveLib = ApplyCorrection(self,WaveLib) % returns predistorted waveform library
        Wavedownload(self, WaveLib) % download waveform library to the awg
        SeqRun(self,PlayList)       % Run sequence playlist based on the downloaded library
        SeqStop(self,PlayList)      % Stop sequence playlist
        
        % methods to work with waveset interface
        WaveLib = WavesetExtractSegmentLibraryStruct(self, waveset) % translates segmentLibrary into struct used by iqtools
        Playlist = WavesetExtractPlaylistStruct(self,waveset) % translates playlist object (see paramlib.M8195A) into playlist struct used by iqtools
        waveset = WavesetApplyCorrection(self, waveset) % apply predistortion filter to necessary segments in segmentLibrary
        WavesetDownloadSegmentLibrary(self, waveset) % download segment library of provided waveset object
        WavesetRunPlaylist(self, waveset) % run playlist
        WavesetSeqStop(self, waveset) % stop playlist
    end
end