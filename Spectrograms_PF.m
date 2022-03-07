%% Description: Creating file with plasma freq. points
% Author: Renato Valentim, Dartmouth College
% Updated: July 15, 2021

%% Clean up workspace

clear all; close all; clc;

%% Loading data with points for the interpolated frequency

load IF_TRICE2H

%% Calculating frequency [0kHz - 2500kHz]

m = 0:8192;
freq = m*20000/2^16;
freq(end) = [];

%% Loading data with power values in a specific time range (main file)

disp('Please select file with your desired time range...');
[file, path] = uigetfile('*.*');
power_main = importdata([path, file]);

%% Organizing timestamps and their respective power values

% creating array with the timestamps of the main file
t = power_main(power_main >= 0);

% creating array with the amplitudes of each timestamp in the main file
power = power_main(power_main <= 0);

% creating columns of amplitudes for each timestamp -- each collumn
% corresponds to a timestamp
power_reshaped = reshape(power, [], length(t));

%% Calculating variables for the interpolated frequency

data_time = IF_TRICE2H(:,1);
data_time_reversed = flip(data_time);

data_freq = IF_TRICE2H(:, 2);
data_freq_reversed = flip(data_freq);

t1_indx = ones(1, length(t)); % pre-allocation
t2_indx = ones(1, length(t)); % pre-allocation

for i = 1:length(t)
    
    t1_indx(i) = find(data_time > t(i), 1);
    t1 = data_time(t1_indx);
    f1 = IF_TRICE2H(t1_indx, 2);

    t2_indx(i) = find(data_time_reversed < t(i), 1);
    t2 = data_time_reversed(t2_indx);
    f2 = data_freq_reversed(t2_indx);  
end

% interpolated frequency -- each collum corresponds to a timestamp as well
f_int = ((t-t1)./(t1-t2)).*(f1-f2)+f1;
f = transpose(f_int);

%% Running average of the power values

log_power = 10.^((power_reshaped)./1000);
running_average = movmean(log_power, 100);
averaged_power = 1000 * log10(running_average);

%% First horizontal line

NUMBER_OF_POINTS = 2500;

average_level = ones(1, length(f)); % pre-allocation

for j = 1:length(f)
    
    int_freq = find(freq > f(j));
    int_freq2 = int_freq(1:NUMBER_OF_POINTS);
    lgt_f = int_freq2; 
    
    average_level(1, j) = mean(log_power(lgt_f, j));
end

horizontal_line1 = 1000 * log10(average_level);

%% Second horizontal line

horizontal_line2 = ones(1, length(f));

for k = 1:length(f)
    
    int_freq3 = find(freq < f(k));
    pwr = averaged_power(int_freq3, k);
    horizontal_line2(:, k) = mean(pwr(pwr > horizontal_line1(k))); 
end
%% Third horizontal line

horizontal_line3 = (0.997) * (1/2) * (horizontal_line1 + horizontal_line2);

%% Plasma frequency

% finding points of intersections

averaged_power2 = transpose(averaged_power);

horizontal_line4 = transpose(horizontal_line3);
horizontal_line = repmat(horizontal_line4, 1, 2);

r = [0 2500];

plasma_freq = ones(1, length(f)); % pre-allocation

for l = 1:length(f)
    [freq_p, ~] = intersections(freq, averaged_power2(l,:), r, horizontal_line(l,:));
    
    if isempty(freq_p)
        freq_p = plasma_freq(l - 1);
        plasma_freq(:, l) = freq_p;
    else
        
        freq_candidates = freq_p(freq_p < f(:,l));
        
        if isempty(freq_candidates)
            freq_candidates = plasma_freq(l - 1);
            plasma_freq(:, l) = freq_candidates;
        end
        
        plasma_freq(:, l) = freq_candidates(end);
    end 
end

%% Plasma frequency vs time + spectogram

plot(t, plasma_freq, 'm', 'linewidth', 1.3);

hold on

gcf = surf(t,freq,power_reshaped./100,'EdgeColor','none'); 

axis xy; axis tight; view(0,90);
xlim([min(t) max(t)])

%labeling
xlabel(strcat('TIME [sec]'));
ylabel('FREQUENCY [kHz]');
title('SPECTOGRAM + PLASMA FREQUENCY POINTS');

set(gca, 'Tickdir', 'out');

% Colorbar axes
colormap(jet);
caxis([-130 -70])
c = colorbar;
c.Label.String = '10log_{10}(V^2/(m^2 Hz))';

hold off

%% Writing Plasma Frequency Points to .txt file

filename = strcat('PFP_for ', num2str(t(1)), '-', num2str(t(end)), ' seconds.txt');

fid = fopen(filename, 'w');
fprintf(fid, '%f \n', plasma_freq);

fclose(fid);