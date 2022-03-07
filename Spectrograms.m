%% This Program will plot a spectrogram for a selected range of timestamps
% Author: Renato Valentim, Dartmouth College
% Updated: August 05, 2021

%% clean up workspace

close all; clear all; clc;

%%

format longG

%% Calculating frequency [0kHz - 2500kHz]

m = 0:8192;
freq = m*20000/2^16;
freq(end) = [];

%% Loading data with power values in a specific time range (main file)

disp('Please select file with your desired time range...');
[file, path] = uigetfile('*.*');
power_main   = importdata([path, file]);

%% Loading plasma frequency points for the specified time range

disp('Now, please select file with the plasma freq. points for the specified time range...');
[file, path] = uigetfile('*.*');
plasma_frequency = importdata([path, file]).data;

%% Getting timestamps values

time = transpose(power_main(power_main >= 0));

%% Getting power values

power = power_main(power_main <= 0);
power_reshaped = reshape(power,[], length(time));

%% Spectogram

plot(time, plasma_frequency, 'm', 'linewidth', 1.3);

hold on

surf(time,freq,power_reshaped./100,'EdgeColor','none'); 

axis xy; axis tight; view(0,90);
xlim([min(time) max(time)])

%labeling
xlabel(strcat('TIME [sec]'));
ylabel('FREQUENCY [kHz]');
title('SPECTOGRAM + PLASMA FREQUENCY POINTS');

% Colorbar axes
colormap(jet);
caxis([-130 -70])
c = colorbar;
c.Label.String = '10log_{10}(V^2/(m^2 Hz))';

hold off