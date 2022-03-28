%% Description: Extracting Data from TRICE2-LOW
% Author: Renato Valentim, Dartmouth College
% Updated: March 16, 2022

%% clean up workspace
clear; close all; clc;

%% loading data and performing necessary manipulations

load EF_RawData.mat;
load charge_profile.mat;

%% calculating desired variables

sf = 1/0.0066;
sfNE = 1/0.0004;

time = raw_data(:, 1);
ef = raw_data(:, 2);

density_time = chargeProfile(:, 1);

%% plotting for a specific interval for the purpose of picking the starting time

prompt = 'please insert desired time range [t1 t2]: ';
timeRange = input(prompt);

t = time(time < timeRange(2) & time > timeRange(1));

index_first = find(t(1)==time);
index_last = find(t(end)==time);
index_range = index_first:index_last;

efield = ef(index_range);
plot(t, efield);

%% calculating intervals

prompt = 'please insert desired starting time: ';
starting_time = input(prompt);

number_intervals = 30;

starting_points  = ones(1:length(number_intervals));      % pre-allocation
end_points = ones(1:length(number_intervals));            % pre-allocation

% making sure the input is included in the range

starting_points(1) = starting_time;
end_points(1) = starting_time + 0.75;

% performing calculations for the rest

for i = 2:number_intervals
    
    starting_points(i)  = ((0.92 * i) + starting_time); 
    end_points(i) = ((0.92 * i) + (starting_time + 0.75));
end

% concatanating

intervals = [transpose(starting_points), transpose(end_points)];

% electric field

% pre-allocation

m = length(intervals);

timestamps = cell(1, m);
sizes = ones(1, m);

for j = 1:m
    
    % electric field
    
    timestamp = time(time < intervals(j, 2) & time > intervals(j, 1));
    timestamps{j} = timestamp;
    
    sizes(j) = length(timestamp);  
end

% pre-allocation

number_points = min(sizes);

electric_field = ones(number_points, m);
efield_time = ones(number_points, m);
efield_mag = ones(number_points, m);

for k = 1:m
    
    time_selected = timestamps{:, k};
    timestamps_selected = time_selected(1:number_points);
    efield_time(:, k) = timestamps_selected;
    
    start_indx = find(time>=timestamps_selected(1));
    final_indx = find(time>=timestamps_selected(end));
    indx_range = start_indx(1):final_indx(1);
    
    selected_efield = raw_data(indx_range, 2);
    electric_field(:, k) = selected_efield;
    
    % fft of the electric field
    
    n_efield = length(selected_efield);
    fourier_efield = fft(hanning(n_efield) .* selected_efield);
    efmag_sq = abs(fourier_efield).^2;
    f_efield = (0:n_efield-1) * sfNE/n_efield; 
    
    mag_efield = efmag_sq;
    
    selected_magef = efmag_sq(1:number_points);
    efield_mag(:, k) = selected_magef;
end

% taking averages and fitting data

average_magef = ones(length(efield_time), length(intervals)/2);
increments_01 = 1:2:30;
increments_02 = 2:2:30;

for r = 1:(length(intervals)/2)
    average_mage = mean(efield_mag(:, increments_01(r):increments_02(r)), 2);
    average_magef(:, r) = average_mage;
end

time_reshaped = reshape(efield_time, [], 15);
efield_reshaped = reshape(electric_field, [], 15);

% density calculations and desired graphs

timestamp_ranges = [intervals(1:2:30, 1), intervals(2:2:30, 2)];
slopes = ones(length(timestamp_ranges), 2);

for l = 1:length(timestamp_ranges)
    
    indx_first = find(density_time >= timestamp_ranges(l, 1));
    indx_last = find(density_time >= timestamp_ranges(l, 2));
    indx_range = indx_first(1):indx_last(1);
    
    % density related to each timestamp range
    
    timestamps_density = chargeProfile(indx_range, 1);
    density = chargeProfile(indx_range, 3);
    
    % fft with hanning window of the density

    n = length(density);                              % delta x
    fourier = fft(hanning(n) .* density);             % fourier with hanning window
    mag_sq = abs(fourier).^2;                         % magnitude squared of dft
    f = (0:n-1) * sf/n;
    
    log_f = log10(f(2:cast(n, 'int8')));              % log format of "f"
    log_mag = log10(mag_sq(2:cast(n, 'int8')));       % log format of the magnitude
    
    figure(l);
    
    % density fft
    
    subplot(3, 2, 1);
    
    plot(log_f, log_mag);
    title('Fourier Transform of the density');
    
    % density slope 
    
    hold on
    
    xlim1d_range = find(log_f >= 1);   % indices of the first numbers above 1
    xlim2d_range = find(log_f >= 1.6); % indices of the first numbers above 1.6
    xd1 = log_f(xlim1d_range(1));      % first x value
    xd2 = log_f(xlim2d_range(1));      % second x value

    log_fRange = log_f(xlim1d_range(1):xlim2d_range(1));     % values of x between 1 and 1.6
    log_magRange = log_mag(xlim1d_range(1):xlim2d_range(1)); % values of y between 1 and 1.6
    
    xlim([log_f(2) max(log_f)]);
    scatter(log_fRange, log_magRange, 'w');

    line = lsline;

    line1 = line(1,1);
    line1.Color = 'r';
    line1.LineWidth = 1.5;

    p1 = [ones(size(line1.XData(:))), line1.XData(:)]\line1.YData(:);
    slope1 = p1(2);

    redLine = sprintf('Slope: %0.03f ', slope1); 
    s = legend(line1, redLine);
    s.FontSize = 14;

    hold off
    
    efieldlog_f = log10(f_efield(2:cast(end/2, 'int8')));
    efieldlog_mag = log10(average_magef(2:cast(end/2, 'int8'), l));
    
    % efield

    subplot(3, 2, 2);
    plot(efieldlog_f, efieldlog_mag);

    % Determining x limits for the interval [1:1.6] - EF EAST

    xlim1e_range = find(efieldlog_f >= 1);   % indices of the first numbers above 1
    xlim2e_range = find(efieldlog_f >= 1.6); % indices of the first numbers above 1.6
    xe1 = efieldlog_f(xlim1e_range(1));      % first x value
    xe2 = efieldlog_f(xlim2e_range(1));      % second x value

    log_fERange = efieldlog_f(xlim1e_range(1):xlim2e_range(1));     % values of x between 1 and 1.6
    log_magERange = efieldlog_mag(xlim1e_range(1):xlim2e_range(1)); % values of y between 1 and 1.6

    xlim([efieldlog_f(2) max(efieldlog_f)]);
    title('Fourier Transform of the Electric Field');

    % calculating slope

    hold on

    scatter(log_fERange, log_magERange, 'w');

    line = lsline;

    line2 = line(1,1);
    line2.Color = 'b';
    line2.LineWidth = 1.5;

    p2 = [ones(size(line2.XData(:))), line2.XData(:)]\line2.YData(:);
    slope2 = p2(2);
    
    slopes(l, :) = [slope1, slope2];
    
    blueLine = sprintf('Slope: %0.03f ', slope2);
    s = legend(line2, blueLine);
    s.FontSize = 14;

    hold off
    
    % density vs time
    
    subplot(3, 1, 2);
    
    plot(timestamps_density, density); 
    xlim([timestamps_density(1) max(timestamps_density)]);
    title ('Charge Densities [N_e(t)]');
    
    % electric field vs time
    subplot(3, 1, 3);

    plot(time_reshaped, efield_reshaped);
    xlim([time_reshaped(1, l) time_reshaped(end, l)]);
    title ('Electric Field');
    
end
%%

table = [slopes timestamp_ranges];

%% saving the slopes to a .txt file

%file_id = fopen('slopes.txt', 'a');
%fprintf(file_id, '%f %f %f %f\n', table');
%fclose(file_id);