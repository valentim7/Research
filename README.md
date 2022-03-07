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
