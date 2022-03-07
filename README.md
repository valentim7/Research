# Research Proposal

Professor LaBelle and his group has launched a rocket in 2019 into the daytime aurora borealis. With the assistance of a wave receiver, variations in the electric field at a range of low and high frequencies were detected. Through the set of power and frequency data obtained, spectrograms could be created, as portrayed by the one below:

<p align = "center">
<img width="600" alt="image" src="https://user-images.githubusercontent.com/101138915/157105418-1a9935df-3d3e-4964-8e3d-d64a567d989a.png">
</p>
<p align = "center">
Figure 1 - Spectrogram for the CAPER-2 flight
</p>

We see here that there is a cutoff delimited by the spectrum of the waves. These cutoffs denote the plasma frequency, which is the fundamental resonant frequency in a charged particle gas. This is important because once the plasma frequency can be attained, the density as a function of time of the charged particles can be also calculated. Moreover, it was detected through those spectrograms that strong waves are present even at very low frequencies. Those waves are electric field waves, and theory suggests that they are directly intertwined with charge density variations, something known as the Boltzmann relation. Therefore, with the density and the electric field variations at hand, we can test this theoretical relationship.
As such, the entire process begins with finding the largest downward transition in a plot (power vs frequency) for a specific timestamp. As illustrated in the figure below:

<p align = "center">
<img width = "600" alt="image" src = "https://user-images.githubusercontent.com/101138915/157120700-75b638a8-e11e-4710-b120-9e4a48eb336a.jpeg">
</p>
<p align = "center">
Figure 2 -  Spectra with plasma frequency
</p>

The first vertical red line from left to right denotes the value of the plasma frequency. The second one, also named as the interpolated frequency, serves as a tool to position the first red line properly. From this graph, we see that the interpolated frequency is always greater than the value of the plasma frequency, and here is where the logic for our programs begins.
Our first task is to create an array of frequencies, for the entire flight, that are just above the real possible values for the plasma frequency. This can be done manually by simply creating spectrograms for a given time range and selecting the points above the “cutoffs.” To do so, we use a program created by Chrystal Moser, named as getting_freq_points_off_spectrograms.m. To use this program, however, we need another of her programs, entitled as Saving_specific_intervals_of_HF_and_VLF_data.m.

# General comments on the process of getting the plasma frequency and generating the density profile
## 1) Spectrograms_PF

The basic idea of this program is to go through every timestamp for a given time range and obtain the value of the plasma frequency. The time range is a portion of the big graydata you used in Saving_specific_intervals_of_HF_and_VLF_data.m, as illustrated below:
<p align = "center">
<img width = "600" alt="image" src = "https://user-images.githubusercontent.com/101138915/157133621-bc772fbb-c980-4fb8-8738-d923de3b1fd6.jpeg">
</p>
<p align = "center">
Figure 3 - Time ranges of the flight
</p>

The program first calculates the interpolated frequency:

<p align = "center">
<img width = "300" alt="image" src = "https://user-images.githubusercontent.com/101138915/157134048-5c89e49a-7217-42c1-b16e-4707a4848f13.jpg">
</p>

Where t denotes a time in the range selected, t1 is the first timestamp after t and t2 is the first timestamp before t. Consequently, f1 and f2 are the corresponding frequencies for t1 and t2. In any case, once we have f, we set two boundaries:

a) We take the average of the first 2500 points after the interpolated frequency, which correspond to a frequency range of [interpolated frequency, interpolated frequency + ~750kHz]. This process gives us our lower bound.

b) We take the average of the points that are below the interpolated frequency and above the lower horizontal line, giving us the upper bound.

Further improvements to this upper bound could account for rising the lower bound by ~10%. That would ensure that we do not consider in our calculations some deeps that very often appear between [0, ~100Khz].

From that, we calculate the average of the two lines, which is denoted by the yellow line in figure 1. Preferably, we do not want this line to be in the middle of the two horizontal lines. This will depend on the shape of our spectra for a given time range. The interpolated frequency is the first intersection of the yellow line from right to left; sometimes, moving this yellow line up a little bit will make us reach more correct intersection points, but occasionally, it could be the other way around. Therefore, we make those changes by altering the default value of 0.997 in the section “Third Horizontal Line.” The table below provides a better depiction for the effect of changing the default value to another, closer decimal number. 



From here, the first data for the plasma frequency is obtained and it is plotted in purple along with the spectrogram for the specified time range. This is the first “sketch” of the plasma frequency since the program not always recognizes the correct downward transition. You can sometimes get some spikes or deeps that do not follow the trend of the cutoffs. For those cases, there is no other way! We need to manually correct them. The correcting_PF.m does that for us. However, before running this program, we must keep track of all intervals that need correction.
	1) Zoom in the desired area—the more you zoom in the more specific the x-axis gets.
	2) Annotate all the time ranges that need correction into a separate document or paper. Here is an example of this process:

 
Figure 4 Process for the detecting points that need correction

	For the case above, for instance, the time range that certainty needs correction is [628.2 628.55]. We see this is the case especially if we look at the shape of the upper hybrid frequency, the faint blue cutoff at [~1100 kHz ~1250 kHz], which mimics the shape of the real plasma frequency. Running the Spectrograms_PF.m is straight forward: just select the file with your desired time range and the program will do the rest for you. At the end, it will give you a .txt file with the first draft data for the plasma frequency.

