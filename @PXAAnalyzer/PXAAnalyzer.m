classdef PXAAnalyzer < GPIBINSTR
% Contains paramaters and methods for PNA-X Network Analyzer

    properties
        start;
        stop;
        bw;
        video;
        numPoints;
        averageCount;
    end
    properties (Access = private)
        timeout = 5;
    end
    methods
        function pxa = PXAAnalyzer(address)
            pxa = pxa@GPIBINSTR(address);
            fclose(pxa.instrhandle);
            set(pxa.instrhandle, 'InputBufferSize', 100000);
            fopen(pxa.instrhandle);
        end
        function set.start(pxa, start)
            SetStartFreq(pxa, start);
        end  
        function start = get.start(pxa)
            start = GetStartFreq(pxa);
        end
        
        function set.stop(pxa, stop)
            SetStopFreq(pxa, stop);
        end
        function stop = get.stop(pxa)
            stop = GetStopFreq(pxa);
        end
        
        function set.bw(pxa, bw)
            SetBW(pxa, bw);
        end
        function bw = get.bw(pxa)
            bw = GetBW(pxa);
        end
        
        function set.video(pxa, video)
            SetVideo(pxa, video);
        end
        function video = get.video(pxa)
            video = GetVideo(pxa);
        end
        
        function set.numPoints(pxa, numPoints)
            SetNumPoints(pxa, numPoints);
        end
        function numPoints = get.numPoints(pxa)
            numPoints = GetNumPoints(pxa);
        end
        
        function set.averageCount(pxa, averageCount)
            SetAverageCount(pxa, averageCount);
        end
        function averageCount = get.averageCount(pxa)
            averageCount = GetAverageCount(pxa);
        end
       
        
        AvgClear(pxa)
        data = Read(pxa);
        
        % Declaration of all other methods
        % Each method is defined in a separate file
    end
    methods (Access = protected)

    end
end