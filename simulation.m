% Montana State University
% Electrical & Computer Engineering Department
% Created by Alexander Salois
clear; clc; close all; % clean up
rng(123) % set for repeatabilty
tic % start timing
nSyms = 2^15; % number of symbols to sim
nSamples = 2^7; % number of samples per symbol
M = 4; % modulation order
msg = randi([0 M-1],nSyms,1); % the msg to send
symbols = pammod(msg,M); % the symbols to send
sig = rectpulse(symbols, nSamples); % the sampled symbols

%% pulse shaping
x = 1:nSamples; % make the pulse the right length
pulse = gaussmf(x ,[nSamples/4 nSamples/2]); % gaussian pluse
pulse = pulse / sum(pulse); % normalize
pulseShapedSig = filter(pulse,1,sig); % filter the signal for pulse shape

% figure()
% plot(x,pulse) % plot pulse 

%% remove delay
delay = nSamples/2;
pulseShapedSig = pulseShapedSig(delay+1:end); % cut from tip
sig = sig(1:end-delay); % cut from tail

%% add Noise
niosySig = awgn(pulseShapedSig,10,'measured');

%% plot the signals
% figure()
% hold on
% plot(sig)
% % plot(pulseShapedSig)
% plot(niosySig)
% hold off
% toc
%% plot eye diagrams
% eyediagram(sig,nSamples)
% eyediagram(pulseShapedSig,nSamples)
% eyediagram(niosySig,nSamples)
% toc
%% pick samples for BER
start = delay; % the delay
picks = niosySig(start:nSamples:end); % simulated
correctPicks = sig(start:nSamples:end); % refrence

% Demod
bits = pamdemod(picks,M);
correctBits = pamdemod(correctPicks,M);

[numWrong, ber] = biterr(correctBits,bits) % get the ber
toc
%% make a BER vs SNR plot

% make a matrix to hold ber
begin = 1;
fin = 25;
berR = zeros(fin-(begin -1),1);

% the correct bits only needs to be computed once
start = delay;
correctPicks = sig(start:nSamples:end);
correctBits = pamdemod(correctPicks,M);
    
for snr = begin:fin
    niosySig = awgn(pulseShapedSig,snr,'measured'); % change niose per iter
    picks = niosySig(start:nSamples:end); % pick the samples
    bits = pamdemod(picks,M); % demod
    [~, ber] = biterr(correctBits,bits); % get ber
    idx = snr - (begin -1); % get the index into berR
    berR(idx) = ber;
end
x = begin:fin;

%%
figure()
semilogy(x,berR','-*')
xlabel('SNR [dB]')
ylabel('BER')
% legend('NO EQ','LMS','DFE 128','DFE 256','Location','southwest')
titleName = sprintf('PAM %d with %0.4g Symbols',M,nSyms);
title(titleName)
saveName = sprintf('pam_%03d_simulation.png',M);
saveas(gcf,saveName)
% save('Eqsfor13mPOF')

toc
