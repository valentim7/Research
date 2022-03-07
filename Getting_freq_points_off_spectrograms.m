i%% Plotting HF Data and highlighting features
% Chrystal Moser Dartmouth College
% Created: July 7 2020
% Updated: Nov 25 2020

%%
close all;
clear all;
clc;

% matlab display format
format longG

%% Loading save file of HF data
[file, path] = uigetfile('*.mat');
load([path, file]);

%% getting times to plot, for HF data make it short interval, or else computer will freeze
t = input('What time interval? [t1 t2]  ');
f = input('What freq interval? [f1 f2]  ');

pt = hftime(hftime < t(2) & hftime > t(1));
pf = hffreq(hffreq < f(2) & hffreq > f(1));
phf= hfdata(hffreq < f(2) & hffreq > f(1),hftime < t(2) & hftime > t(1));
%% Plotting HF Spectrogram with point finder

figure(100)

% HF spectrogram
surf(pt,pf,phf./100,'EdgeColor','none');  

% Setting axis view and colors
axis xy; axis tight; colormap(jet); view(0,90);
caxis([-120 -60]);
% c = colorbar;

% Labels
xlabel(strcat('UTC 08:26:00 [sec]'));%, 'Fontsize', 18);
ylabel('Frequency [kHz]');%, 'Fontsize', 18);
% c.Label.String = '10log_{10}(V^2/(m^2 Hz))';
title('HF Data');%, 'Fontsize', 22);


%% Selecting points off the spectrogram, press enter when done
% Getting points
[fpe_time, fpe_freq] = ginput;

%% Save Plasma Frequency points in .mat  file 
filename = strcat('plasma_freq_points_', num2str(t(1)), '-', num2str(t(2)),'sec');
save(filename, 'fpe_time', 'fpe_freq')

%% Writing Points to .txt file
filename = strcat('plasma_freq_points_', num2str(t(1)), '-', num2str(t(2)),'sec.txt');

fid = fopen(filename, 'w');
fprintf(fid, '%f %f\n', [fpe_time'; fpe_freq']);

fclose(fid);

