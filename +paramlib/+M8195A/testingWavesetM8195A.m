%%
clear all;
a=sin(10.*linspace(0,pi,200));
b=zeros(1,2.*length(a));
w = paramlib.M8195A.wavesetM8195A();
s1 = w.newSegment(a);
s2 = w.newSegment(b);
p1 = w.newPlaylistItem(s1);p1.loops=10;
p2 = w.newPlaylistItem(s2);
p3 = w.newPlaylistItem(s1);p3.advance='Conditional';
p4 = w.newPlaylistItem(s2);p4.loops=2;
p5 = w.newPlaylistItem(s1);
p6 = w.newPlaylistItem(s2);p6.advance='Conditional';
p7 = w.newPlaylistItem(s1);p7.advance='Conditional';
p8 = w.newPlaylistItem(s1);
% w.playlist(1).draw()
% w.drawSegmentLibrary()
w.drawPlaylist()
%%
clear all;
a=sin(10.*linspace(0,pi,200));
b=zeros(1,2.*length(a));
w = paramlib.M8195A.wavesetM8195A();
s= paramlib.M8195A.segment(a,2,'Q',false)
p=paramlib.M8195A.playlistItem(s,'Auto',10)
p.draw()

