
w = paramlib.M8195A.wavesetM8195A()
p = paramlib.M8195A.playlistItem()

%%
clear s, test=sin(10.*linspace(0,pi,200));
s1 = paramlib.M8195A.segment(test), s1.draw()
s2 = paramlib.M8195A.segment(zeros(1,length(test))), s2.draw()
%%
p1 = paramlib.M8195A.playlistItem();
p1.segment=s1; p1.loops=10; p1.draw();
p2 = paramlib.M8195A.playlistItem()
p2.segment=s2; p2.loops=1; p2.draw()

%%
clear w
w = paramlib.M8195A.wavesetM8195A()
s1 = paramlib.M8195A.segment();
s1.waveform=sin(10.*linspace(0,pi,200));
s2 = paramlib.M8195A.segment();
s2.waveform=zeros(1,111);
%%
w.addSegment(s2)
