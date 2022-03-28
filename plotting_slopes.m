%% Description: Extracting Data from TRICE2-LOW
% Author: Renato Valentim, Dartmouth College
% Updated: March 24, 2022

%% clean up workspace
clear; close all; clc;

%% loading necessary files and variables

load slopes.txt;
load charge_profile.mat;
load my_slopes.mat;
density_time = chargeProfile(:, 1);

m = 0:8192;
freq = m*20000/2^16;
freq(end) = [];
time = my_slopes(:, 3:4);

% possible_indices = [3,18,42,66,71,79,89,93,97,101,107,108,143];
% possible_slopes = slopes(possible_indices, :);

%% calculating variables for the desired ranges

prompt = 'please insert desired time range between 500 and 820 seconds [t1 t2]: ';
timeRange = input(prompt);

time_density = density_time(density_time < timeRange(:, 2) & density_time > timeRange(:, 1));
indices_density = ones(1, length(time_density));

for i = 1:length(time_density)
    indices_density(i) = find(density_time == time_density(i));
end

density = chargeProfile(indices_density, 3);

time_slopes = time(time(:, 2) < timeRange(:, 2) & time(:, 1) > timeRange(:, 1));
indices_slopes = ones(1, length(time_slopes));

for j = 1:length(time_slopes)
    indices_slopes(j) = find(time == time_slopes(j));
end

desired_slopes = my_slopes(indices_slopes, 1:2);

%% plotting results

subplot(2, 1, 1);

plot(time_density, density);
title('Slopes: Charge Density and Electric Field', 'FontSize', 17);
xlim([time_slopes(1) max(time_slopes)]);
xlabel('TIME [sec]'), ylabel('DENSITY');

subplot(2, 1, 2);

p1 = scatter(time_slopes, desired_slopes(:, 1), 'b', 'filled');

hold on

p2 = scatter(time_slopes, desired_slopes(:, 2), 'r', 'filled');

title('Slopes: Charge Density and Electric Field', 'FontSize', 17);
xlim([time_slopes(1) max(time_slopes)]);
xlabel('TIME [sec]'), ylabel('SLOPE');
legend('Density','Electric Field', 'Location', 'southeast', 'FontSize', 17);

hold off

% subplot(4, 1, 4);
% 
% p3 = plot(possible_slopes(:, 4), possible_slopes(:, 1), 'g', 'filled');

% hold on
% 
% p4 = plot(possible_slopes(:, 4), possible_slopes(:, 2), 'm', 'filled');
% 
% title('Possible slopes: Charge Density and Electric Field', 'FontSize', 17);
% xlim([possible_slopes(1, 4) max(possible_slopes(:, 4))]);
% xlabel('TIME [t]'), ylabel('SLOPE');
% legend('Density','Electric Field', 'Location', 'southeast', 'FontSize', 17);

% hold off