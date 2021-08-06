% Montana State University
% Electrical & Computer Engineering Department
% Created by Alexander Salois
clear; clc; close all;
rng(123)
nSyms = 2^4;
nSamples = 2^10;
M = 4;
msg = randi([0 M-1],nSyms,1);
symbols = pammod(msg,M);
sig = rectpulse(symbols, nSamples);
niosySig = awgn(sig,10,'measured');
x = 1:nSamples;
pulse = gaussmf(x ,[nSamples/4 nSamples/2]);
pulse = pulse / sum(pulse);
pulseShapedSig = filter(pulse,1,sig);

%%
figure()
plot(x,pulse)

%%
figure()
hold on
plot(sig)
plot(pulseShapedSig)
hold off

%%
eyediagram(sig,nSamples)
eyediagram(pulseShapedSig,nSamples)

