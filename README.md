# Research Proposal

Professor LaBelle and his group has launched a rocket in 2019 into the daytime aurora borealis. With the assistance of a wave receiver, variations in the electric field at a range of low and high frequencies were detected. Through the set of power and frequency data obtained, spectrograms could be created, as portrayed by the one below:

<p align = "center">
<img width="600" alt="image" src="https://user-images.githubusercontent.com/101138915/157105418-1a9935df-3d3e-4964-8e3d-d64a567d989a.png">
</p>
<p align = "center">
Figure 1 - Spectrogram for the CAPER-2 flight
</p>

We see here that there is a cutoff delimited by the spectrum of the waves. These cutoffs denote the plasma frequency, which is the fundamental resonant frequency in a charged particle gas. This is important because once the plasma frequency can be attained, the density as a function of time of the charged particles can be also calculated. For example, it was detected through those spectrograms that strong waves are present even at very low frequencies. Those waves are electric field waves, and theory suggests that they are directly intertwined with charge density variations, something known as the Boltzmann relation. Therefore, with the density and the electric field variations at hand, we can test this theoretical relationship.
As such, the entire process begins with finding the largest downward transition in a plot (power vs frequency) for a specific timestamp. As illustrated in the figure below:

<p align = "center">
<img width = "500" alt="image" src="https://user-images.githubusercontent.com/101138915/157120700-75b638a8-e11e-4710-b120-9e4a48eb336a.jpeg">
</p>
<p align = "center">
Figure 2 -  Spectra with plasma frequency
</p>

The first vertical red line from left to right denotes the value of the plasma frequency. The second one, also named as the interpolated frequency, serves as a tool to position the first red line properly. From this graph, we see that the interpolated frequency is always greater than the value of the plasma frequency, and here is where the logic for our programs begins.
Our first task is to create an array of frequencies, for the entire flight, that are just above the real possible values for the plasma frequency. This can be done manually by simply creating spectrograms for a given time range and selecting the points above the “cutoffs.” To do so, we use a program created by Chrystal Moser, named as getting_freq_points_off_spectrograms.m. To use this program, however, we need another of her programs, entitled as Saving_specific_intervals_of_HF_and_VLF_data.m.

## 1.	Getting candidates for the interpolated frequency
## 1.1.	Saving_specific_intervals_of_HF_and_VLF_data.m.

Once you run this program, you are asked the following commands:
1)	Input a specific time range. E.g.: [150 200].
a.	Make sure to include a time range that lies within the range of the data you have.
b.	Do not include intervals beyond 50 seconds. Otherwise, the program will be very slow.
2)	Input the HF frequency range. E.g.: [0 2000]
a.	This frequency range is sufficient for visualizing and tracking the points above the plasma frequency. You can put values above 2000, but this is not necessary.
3)	Select the graydata file for your flight.
4)	Done! The program will save a .mat extension (e.g.: 13-Oct-2021-Trice2-Hi-HF--0-2000kHz_spectrogram_data--150-200s) with the necessary power, frequency, and time data for getting_freq_points_off_spectrograms.m.

## 1.2.	Getting_freq_points_off_spectrograms.m

1)	Load your saved file from the previous program.
2)	Input the same time and frequency range.
3)	Once the spectrogram appears, scroll your mouse to your desired point and right click on it.
4)	Do so until you reach the end of your spectrogram.
5)	Press enter and close the spectrogram.
6)	Done! Now you have a .mat and .txt version (e.g: plasma_freq_points_150-200sec) portraying the values of the frequencies you selected and their corresponding time.

## 1.3.	General discussion

The aforementioned steps can be done in two main ways: you can start with 1.1 and do it for the entire flight first, saving all the .mat extensions and applying them to 1.2 afterwards. Or you can do 1.1 and proceed right to 1.2, repeating this process until you reach the end of the flight.

## 1.3.1. Concatenating the files

Once you have the .txt files, make sure to add them to a specific folder. We need to concatenate them, because we are only interested in a single, concise file containing all the data we need. We can do so by using the terminal window.

# General comments on the process of getting the plasma frequency and generating the density profile
## 2. Spectrograms_PF

The basic idea of this program is to go through every timestamp for a given time range and obtain the value of the plasma frequency. The time range is a portion of the big graydata you used in Saving_specific_intervals_of_HF_and_VLF_data.m, as illustrated below:

<p align = "center">
<img width = "500" alt="image" src="https://user-images.githubusercontent.com/101138915/157133621-bc772fbb-c980-4fb8-8738-d923de3b1fd6.jpeg">
</p>

<p align = "center">
Figure 3 - Time ranges of the flight
</p>

The program first calculates the interpolated frequency:

<p align = "center">
<img width = "250" alt="image" src= "https://user-images.githubusercontent.com/101138915/157134048-5c89e49a-7217-42c1-b16e-4707a4848f13.jpg">
</p>

Where t denotes a time in the range selected, t1 is the first timestamp after t and t2 is the first timestamp before t. Consequently, f1 and f2 are the corresponding frequencies for t1 and t2. In any case, once we have f, we set two boundaries:

a)	We take the average of the first 2500 points after the interpolated frequency, which correspond to a frequency range of [interpolated frequency, interpolated frequency + ~750kHz]. This process gives us our lower bound.
b)	We take the average of the points that are below the interpolated frequency and above the lower horizontal line, giving us the upper bound. Further improvements to this upper bound could account for raising the lower bound by ~10%. That would ensure that we do not consider in our calculations some deeps that very often appear between [0, ~100Khz].

From that, we calculate the average of the two lines, which is denoted by the yellow line in figure 1. Preferably, we do not want this line to be in the middle of the two horizontal lines. This will depend on the shape of our spectra for a given time range. The interpolated frequency is the first intersection of the yellow line from right to left; sometimes, moving this yellow line up a little bit will make us reach more correct intersection points, but occasionally, it could be the other way around. Therefore, we make those changes by altering the default value of 0.997 in the section “Third Horizontal Line.” The table below provides a better depiction for the effect of changing the default value to another, closer decimal number. 

<p align = "center">
<img width = "500" alt="image" src = "https://user-images.githubusercontent.com/101138915/157134656-0350bd04-8c4c-4dde-9aa6-95905730cdf4.jpg">
</p>

From here, the first data for the plasma frequency is obtained and it is plotted in purple along with the spectrogram for the specified time range. This is the first “sketch” of the plasma frequency since the program does not always recognize the correct downward transition. You can sometimes get some spikes or minima that do not follow the trend of the cutoffs. For those cases, there is no choice except to manually correct them. The correcting_PF.m does that for us. However, before running this program, we must keep track of all intervals that need correction.

c)	Zoom in the desired area—the more you zoom in the more specific the x-axis gets.
d)	Annotate all the time ranges that need correction into a separate document or paper. Here is an example of this process:

<p align = "center">
<img width = "500" img height = "500" alt="image" src = "https://user-images.githubusercontent.com/101138915/157134406-6969985d-3834-427a-8078-73d4a3b3cb53.jpeg">
</p>
<p align = "center">	
Figure 4 - Process for the detecting points that need correction
</p>

For the case above, for instance, the time range that certainty needs correction is [628.2 628.55]. We see this is the case especially if we look at the shape of the upper hybrid frequency, the faint blue cutoff at [~1100 kHz ~1250 kHz], which mimics the shape of the real plasma frequency. Running the Spectrograms_PF.m is straight forward: just select the file with your desired time range and the program will do the rest for you. At the end, it will give you a .txt file with the first draft data for the plasma frequency.
	
## 3.	Putting points where they were supposed to be
## 3.1.	Correcting_PF.m

The code follows the same logic from Spectrograms_PF, but this time, instead of spectrograms we are going to analyze spectra by spectra. Here comes the importance of annotating only the intervals that need correction, otherwise, we would have to analyze thousands of thousands of plots. Also, that is why it is crucial to be specific with the intervals, since just 1 second of the flight gives more than 150 plots to consider.
1)	Load your desired time range.
2)	Load the .txt file with the draft data for the plasma frequency.
3)	Provide an interval that needs correction.
4)	Scroll your mouse to the correct point and right click on it.
5)	Do so for each timestamp on that interval.
6)	Run just the “Inserting intervals of correction” section again and again until you do not have any more intervals to correct.

Here is an example of how the program looks like for the interval we just annotated [628.2 628.55]:

<p align = "center">
<img width = "500" alt="image" src = "https://user-images.githubusercontent.com/101138915/157134831-f63c8ffa-c460-48a2-b8d2-15cea2fe94fa.jpeg">
</p>
<p align = "center">
Figure 5 - Selecting correct candidates for the plasma frequency
</p>

The program will give you a .txt file containing a table with the plasma frequencies and their corresponding timestamps and charge densities, which are calculated through the following relation:

<p align = "center">
<img width = "150" alt="image" src = "https://user-images.githubusercontent.com/101138915/157136080-628af89e-42f3-4ea8-ba3f-f54b38174a54.jpg">
</p>

Where fpe represents the plasma frequency at a given point.

## 4.	Checking if the manual corrections, indeed, worked
## 4.1.	Spectrograms.m

Sometimes, we end up choosing the wrong points to denote the plasma frequency. The best way to check if this was the case is by creating another spectrogram with the corrected plasma frequency points. If we still see spikes or minima deviating from the cutoffs, that means we still have intervals to fix. This is where Spectrograms.m comes into play:

1)	Load your desired time range.
2)	Select the .txt file with the table for the plasma frequency points in that time range.
3)	Look for deviations from the cutoffs.
4)	Annotate the intervals of correction (if there are still some).
5)	Run Correcting_PF.m again and repeat process three and four until no wrong points are found.
6)	Save the .txt tables into a specific folder.
7)	Once the entire flight is corrected, concatenate all the .txt files by using the cat command in the terminal window.

# Getting and plotting the slopes for the density and electric field
## 5. Taking Fourier Series of the density and calculating slopes

With the data for the density and electric field at hand, we can now calculate their respective slopes using Fourier series. Unfortunately, the electric field data is filled with “sun spikes” that occur at a somewhat regular rate. We want to avoid those spikes, since they interfere directly on the value of the electric field slopes. In that case, we are only interested in the ranges that are between the sun spikes. The program fourier_series takes thirty of those ranges, calculate their Fourier series, and average every two of those intervals together, providing us with fifteen graphs at the end. Here is how the program works:

a. Select a time range that you want to look at, always try for an interval equal or greater than 40 seconds. After selecting this interval, a graph of the electric field vs time will appear.
<p align = "center">
<img width="500" alt="image" src="https://user-images.githubusercontent.com/101138915/160319608-9a0ce12e-a4fa-4c32-a7e6-15ca0758b165.png">
</p>
<p align = "center">
Figure 6 - Electric field as a function of time
</p>

b. Take a close look at the graph and select a starting point that is right after a sun spike.

If you input the correct starting point, you will be able to see the fifteen graphs encompassing a range of 30 seconds in total approximately, with no evidence of a sun spike. If you do see a sun spike in one of the graphs for the electric field, run the program again until you find a correct starting point. For the TRICE2-High flight, I have mapped those points already, they are, in seconds:

• 500.75, 531.17, 559.76, 587.43, 615.97, 644.6, 673.12, 701.71, 730.35, 758.87, 787.47.

Here is an example for the starting point 615.97:
<p align = "center">
<img width="500" alt="image" src="https://user-images.githubusercontent.com/101138915/160320263-627e1619-b20c-40ba-8902-14a48951b10b.png">
</p>
<p align = "center">
Figure 7 - Slopes without the presence of a sun spike in the electric field
</p>

Once you obtain the correct list of starting points, uncomment the lines from the section “saving the slopes to a .txt file” in the program. Run the program again using those starting points and you will get a .txt file with the slopes for the density and electric field along with their respective timestamps.

Note: usually, because of some spikes and/or the presence of non-stationary intervals in the density, some of those slopes will not be considered. Write down the number corresponding to the graphs you think are working well. You are going to need those numbers, as they will be the indices used to extract the correct slopes from the .txt file you just created.

## 6. Plotting density along the extracted slopes

The program plotting_slopes is simple. You just have to select the interval you want to plot, and the program will do the rest for you. Keep in mind, however, that I am passing to this program the file with the slopes already selected, which in my case is the file my_slopes.mat.

Note: the commented lines are for slopes that were considered as possible ones but were not included in the result for the selected files. They provide a good example, however, of how you can extract the correct slopes in the program without the need of loading a file with the slopes already extracted.

<p align = "center">
<img width="600" alt="image" src="https://user-images.githubusercontent.com/101138915/160320291-3d8296d9-b81c-41ef-80c6-065eef7787ef.png">
</p>
<p align = "center">
Figure 8 - Slopes for the density and electric field
</p>
