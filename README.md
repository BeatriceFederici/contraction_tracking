# contraction_tracking
Open-source Software Tool to Quantify Cardiomyocyte and Cardiac Muscle Cells Contraction In Vitro

Compute cell contraction rate
Code written by Beatrice Federici, Dec 2020. 

Please cite the following paper when using this code: 
V.Vurro et al, "Optical modulation of excitation-contraction coupling in human induced pluripotent stem cell-derived cardiomyocytes", iScience

Basic principle: Features area is expected to shrink when cell contracts.
Further details are presented in the aforementioned journal paper.
Note: code is written for algorithm demonstrative purpose and it requires user interaction. 
When required, follow the instruction displayed in the Command Window to proceed.

Overview:
1. initialize
2. display video
3. user-defined ROI (cellsto analyze)
4. pre-process frames: equalize illumination, sub-areas for each ROI to ensure proper tracking
5.a tracking algorithm
5.b extract parameters: contraction rate, contraction amplitude, contraction velocity
6. display results in command window

In 4. users can modify the starting and ending frame of the running observation
window (ROW) where the contractile behavior is analyzed. 
For example, one can modify the ROW to estimate the contractile behavior pre stimulus, 
during stimulus and post stimulus, as done in the cited paper.
