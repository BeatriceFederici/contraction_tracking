# contraction_tracking
Open-source Software Tool to Quantify Cardiomyocyte and Cardiac Muscle Cells Contraction In Vitro

Code written by Beatrice Federici, Dec 2020. 
Please cite the following paper when using this code: 
V.Vurro et al, "Optical modulation of excitation-contraction coupling in human induced pluripotent stem cell-derived cardiomyocytes", iScience

Basic principle: contraction-induced retraction of cell body towards nucleus.
The user defines one or more regions of interest (ROI) by the means of bounding boxes. Each ROI should contain one cell.
For each ROI a set of features is identified and tracked across video frames by means of Kanade-Lucas-Tomasi algorithm (Lucas and Kanade; Jianbo Shi and Tomasi, 1994). Since the ROI is delimiting a cell, the features are expected to belong to cell body. 
Averaging the estimated motion fields of all these feature points returns a mean geometric transformation, which can be applied to the bounding box delimiting the ROI. The area of this bounding box is measured over time and presents minima at cellular contractions. 
The number of contractions per time interval yields an estimate of the cell contraction rate. 

Note: code is written for algorithm demonstrative purpose and it requires user interaction. Hence, when required, follow the instruction displayed in the Command Window to proceed.

Overview:
1. initialize
2. display video
3. user-defined ROI (cellsto analyze)
4. pre-process frames: equalize illumination, sub-areas for each ROI to ensure proper tracking
5. (a) tracking algorithm
   (b) extract parameters: contraction rate, contraction amplitude, contraction velocity
6. display results in Command Window 

In 4. users can modify the starting and ending frame of the running observation window (ROW) where the contractile behavior is analyzed. 
For example, one can modify the ROW to estimate the contractile behavior pre light stimulus, during light stimulus and post light stimulus, as done in the cited paper.
