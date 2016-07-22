
w = paramlib.M8195A.wavesetM8195A()
p = paramlib.M8195A.playlistItem()
s = paramlib.M8195A.segment()

%%
s.waveform=sin(10.*linspace(0,pi,200));
s.id=1;
s.channel=1;
s.quadrature='I'
s.draw()
%%
p.segment=s
p.loops=10;
p.draw()
%%
clear w
w = paramlib.M8195A.wavesetM8195A()
s1 = paramlib.M8195A.segment();
s1.waveform=sin(10.*linspace(0,pi,200));
s2 = paramlib.M8195A.segment();
s2.waveform=zeros(1,111);
%%
w.addSegment(s2)
