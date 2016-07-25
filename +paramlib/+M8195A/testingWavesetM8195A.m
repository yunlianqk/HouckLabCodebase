%%
clear all;
a=sin(10.*linspace(0,pi,200));
b=zeros(1,2.*length(a));
w = paramlib.M8195A.wavesetM8195A();
s1 = w.newSegment(a);
s2 = w.newSegment(b);
p1 = w.newPlaylistItem(s1);p1.loops=10;
p2 = w.newPlaylistItem(s2);
% w.playlist(1).draw()
% w.drawSegmentLibrary()
w.drawPlaylist()