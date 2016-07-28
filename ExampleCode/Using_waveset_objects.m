% Example code for using Waveset Objects with M8195A
% In the future waveset objects may be defined for other AWGs if it's
% useful.
% JJR - 2016

%% Manually creating a M8195A waveset object
% paramlib.M8195A is a package that contains the waveset, segment, and
% playlist item objects. The M8195A needs a segment library and a playlist
% to run.  

% The waveset object contains both of these. 
ws = paramlib.M8195A.waveset();

% New segments can be added to the segment library in a few ways
waveform1=zeros(1,1000);
s1 = paramlib.M8195A.segment(waveform1);
ws.addSegment(s1);
% or alternatively
waveform2=ones(1,1000);
s2 = ws.newSegment(waveform2);
% the functions can also take extra arguments, like a channel map
waveform3=(sin(linspace(0,8*pi,1000)));
s3 = ws.newSegment(waveform3,[0 0; 1 0; 0 0; 0 0]);
% segments can be easily visualized
s3.draw()

%% Creating the playlist
% The playlist is built up from playlist items, which specify a segment id
% and other parameters (loop count and trigger mode, etc.)

% again these can be created and added to playlist in a couple of ways
p1 = paramlib.M8195A.playlistItem(s1);
ws.addPlaylistItem(p1);
% option 2
p2 = ws.newPlaylistItem(s2);
% option 3 - with variable arguments
p3 = ws.newPlaylistItem(s3,'Conditional', 50);
% and visualized
p3.draw()

%% Inspecting Segment Library and Playlist
ws.drawSegmentLibrary();
ws.drawPlaylist();

%% Downloading and running the waveset to the M8195A
% this code probably won't work unless you are on a computer with a working
% awg...

% create the M8195A object
awg = M8195AWG();

% Option 1 - generate and use the Wavelib and Playlist structs AWG expects
Wavelib = awg.WavesetExtractSegmentLibraryStruct(ws);
Playlist = awg.WavesetExtractPlaylistStruct(ws);
awg.ApplyCorrection(WaveLib);
awg.Wavedownload(WaveLib);
awg.SeqRun(PlayList);
awg.SeqStop(PlayList);

% Option 2 - There are also awg methods that handle the waveset directly
correctedWaveset = awg.WavesetApplyCorrection(ws);
awg.WavesetDownloadSegmentLibrary(correctedWaveset);
awg.WavesetRunPlaylist(correctedWaveset);
awg.WavesetSeqStop(correctedWaveset);





