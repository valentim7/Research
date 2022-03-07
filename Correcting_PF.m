%% This Program will plot an spectrogram for a selected range of timestamps
% Author: Renato Valentim, Dartmouth College
% Updated: September 01, 2021

%% clean up workspace

close all; clear all; clc;

%%

format longG

% Loading data with points for the interpolated frequency

load IF_TRICE2H

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

%plasma_frequency = importdata([path, file]).data;
plasma_frequency = importdata([path, file]); % --> In case PFPs are just
% arrays.

%% Getting timestamps values

t = power_main(power_main >= 0);
time = transpose(power_main(power_main >= 0));

%% Getting power values

power = power_main(power_main <= 0);
power_reshaped = reshape(power,[], length(time));

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

%% Inserting intervals of correction

prompt = 'Insert desired time range [t1 t2] from the file selected (choose a very small interval): ';
t_range = input(prompt);

timestamps = time(time < t_range(2) & time > t_range(1));
indices = ones(1, length(timestamps)); % pre-allocation

for j = 1:length(timestamps)
    
    indices(j) = find(time==timestamps(j));
end

%
log_power = 10.^((power_reshaped)./1000);
running_average = movmean(log_power, 60);
averaged_power = 1000 * log10(running_average);

% Power vs Frequency + selecting points

% Values for the time range selected

selected_power = averaged_power(:, indices(1):indices(end));
selected_p = plasma_frequency(indices(1):indices(end), :);
selected_pf = transpose(selected_p);
selected_if = f(:, indices(1):indices(end));

pf_freq = ones(1, length(timestamps)); % pre-allocation
pf_pwr = ones(1, length(timestamps)); % pre-allocation

for p = 1:length(timestamps)
    
    figure(p)
    
    plot(freq, selected_power(:, p), 'g', 'linewidth', 1.5);
    
    hold on
    
    int_f = xline(selected_if(:, p), '-.r', 'linewidth', 2);
    p_f = xline(selected_pf(:, p), '-.r', 'linewidth', 2);
    
    title(['Spectrum in the range of ' num2str(t_range(1)) ' and ' num2str(t_range(2)) ' seconds '], 'FontSize', 15);
    xlabel('Frequency [kHz]', 'FontSize', 14);
    ylabel('Power', 'FontSize', 14);
    
    [pf_freq(p), pf_pwr(p)] = ginput(1);
    
    hold off

end

close all

% Replacing points

for q = 1:length(timestamps)
    
    plasma_frequency(indices(q)) = pf_freq(q);
end

% calculation of n_e (Charge density)

n_e = (plasma_frequency./8.98).^2;

% Writing Points to .txt file

Table = [t, plasma_frequency, n_e];

%
filename = strcat('Table for ', num2str(time(1)), '-', num2str(time(end)), ' seconds.txt');

fid = fopen(filename, 'wt');
fprintf(fid, '%8s %11s %8s\r\n', 'time', 'p. freq', 'n_e');

for r = 1:length(Table)
   fprintf(fid, '%f %f %f\n', Table(r, :));
end

fclose(fid);

filename2 = strcat('Plasma frequency points for ', num2str(time(1)), '-', num2str(time(end)), ' seconds.txt');
fid2 = fopen(filename2, 'wt');
fprintf(fid2, '%s \n', 'Plasma Frequency');
fprintf(fid2, '%f \n', plasma_frequency);

fclose(fid2);