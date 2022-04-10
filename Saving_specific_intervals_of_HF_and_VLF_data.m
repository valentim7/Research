%% Saving HF and VLF data for specific intervals
% Author: Chrystal Moser, dartmouth college
% Created: May 7 2020
%% Clearing workspace
fclose('all');
close all; 
clear all;
clc;

%% Matlab format
format longG

%% Getting time input

% Time range to compare
t = input('Enter time range [t1 t2]: ');

%% =============================================== HF ==========================================================
%% get all the inputs for the HF spectrograms
% HF File
[hffilename, path] = uigetfile('*.*');
hffid = fopen([path hffilename], 'r');

% HF frequency range
f(1:2) = input('Enter HF freq (kHz) range [HF-f1 HF-f2]: ');

%% Info abouty hf data

% Sampling frequency in kHz
sf = 19999.879;

if contains(hffilename, 'log15')
    N = 2^15; %number of points per fft for log15
elseif contains(hffilename, 'log16')
    N = 2^16;
elseif contains(hffilename, 'log18')
    N = 2^18;
end

% Number of lines in the graydata per fft + timestamp
if contains(hffilename, '2500kHz')
    n_total = round(N*2500/sf)+1;
elseif contains(hffilename, '5000kHz')
    n_total = round(N*5000/sf)+1;
else
    n_total = N/2+1;
end

% Starting/End Point in fft for input frequency range
n_start = round(N*f(1)./sf)+2;
n_end = round(N*f(2)./sf)+2;
n_lines = length(n_start:n_end);

% Frequency variable
hffreq = linspace(f(1),f(2), n_lines);

%% Loading HF data
clear hfdata hftime;
while ~feof(hffid) 
    A = fscanf(hffid, '%f\n', [n_total, 1]);
    if (round(A(1), 2) >= t(1))
        break;
    end
end

hftime(1) = A(1);
hfdata(1:n_lines, 1) = A(n_start:n_end);
i = 1; k = 0;
while hftime(i) <= t(2) 
    i = i+1; k = k+1;
    A = fscanf(hffid, '%f\n', [n_total, 1]);
    hftime(i) = A(1);
    hfdata(1:n_lines, i) = A(n_start:n_end);
end

%% Uncomments/Run Section if you want to plot an averaged HF spectrogram 
clear hfavgdata hfavgtime;
n_avg   = 10;
j       = 1;
last    = floor(length(hftime)/(n_avg))*(n_avg);
n_lines = length(hffreq);
for i = 1:(n_avg):last
    pwr = mean(10.^(hfdata(:,i:(i+n_avg-1))./1000),2);
    hfavgdata(1:n_lines, j) = 1000*log10(pwr);
    hfavgtime(j) = mean(hftime(i:(i+n_avg-1)));
    j = j+1;
end

clear hftime hfdata;

hfdata = hfavgdata;
hftime = hfavgtime;

%% cleaning up and saving
clearvars -except hfdata hftime hffreq t f;

% vlfdata vlftime vlffreq;

% % Both
% save_file = strcat(date,'-HF--', num2str(f(1)), '-',...
   % num2str(f(2)),'kHz_and_VLF--'...
   % , num2str(f(3)),'-',num2str(f(4)),'kHz_spectrogram_data--', ...
   % num2str(t(1)), '-', num2str(t(2)), 's.mat');
% save(save_file, 'hfdata', 'hftime', 'hffreq', 't', 'f', 'vlfdata', 'vlftime', 'vlffreq');


% Just HF
save_file = strcat(date,'-Trice2-Hi-HF--', num2str(f(1)), '-', num2str(f(2)),'kHz_spectrogram_data--', ...
    num2str(t(1)), '-', num2str(t(2)), 's.mat');
save(save_file, 'hfdata', 'hftime', 'hffreq', 't', 'f','-v7.3' );

% % Just VLF
% save_file = strcat(date,'-VLF--',num2str(f(3)),'-',num2str(f(4)),'kHz_spectrogram_data--', ...
%     num2str(t(1)), '-', num2str(t(2)), 's.mat');
% save(save_file, 't', 'f', 'vlfdata', 'vlftime', 'vlffreq');