%% Compute cell contraction rate
% Code written by Beatrice Federici, Dec 2020. 
% 
% Please cite the following paper when using this code: 
% V.Vurro et al, "Optical modulation of excitation-contraction coupling in human induced
% pluripotent stem cell-derived cardiomyocytes", iScience
%
% Basic principle: Features area is expected to shrink when cell contracts.
% Further details are presented in the aforementioned journal paper.
% Note: code is written for algorithm demonstrative purpose and it requires user interaction. 
% When required, follow the instruction displayed in the Command Window to proceed.
%
% Overview:
% 1. initialize
% 2. display video
% 3. user-defined ROI (cellsto analyze)
% 4. pre-process frames: equalize illumination, sub-areas for each ROI to ensure proper tracking
% 5.a tracking algorithm
% 5.b extract parameters: contraction rate, contraction amplitude, contraction velocity
% 6. display results in command window
%
% In 4. users can modify the starting and ending frame of the running observation
% window (ROW) where the contractile behavior is analyzed. 
% For example, one can modify the ROW to estimate the contractile behavior pre stimulus, 
% during stimulus and post stimulus, as done in the cited paper.
%
%% 1. INITIALIZE
close all
clearvars

addpath('utilities\')  

filename = 'video_example\Vetrino4_Campo1.avi'; %'video_folder\video.avi';
VideoReader(filename)
videoReader = vision.VideoFileReader(filename); 
videoInfo=info(videoReader); % get info of videoReader
FrameRate= videoInfo.VideoFrameRate; % extract Frame Rate

%% 2. DISPLAY VIDEO
confirm=0;
while confirm == 0
    depVideoPlayer = vision.DeployableVideoPlayer;
    numFrames = displayVideo(videoReader, depVideoPlayer);
    release(videoReader)
    release(depVideoPlayer)
    yesno = string(input('Press [y] to proceed or any other key to display the video again \n\n', 's'));
    if isequal(yesno, "y")
        confirm = 1;
    end
    close all;
end


%% 3. USER INPUTS
confirm = 0;
while confirm == 0
    numROI = input('Enter the number of ROI \n\n');
    if isnumeric(numROI)== 0
        fprintf('Please insert a numeric value.\n');
        continue
    elseif numROI ~= round(numROI)
        fprintf('Please insert an integer value.\n');
        continue
    end
    fprintf('\n Number of ROI indicated equals to # %d . \n', numROI);
    yesno = string(input('Press [y] to confirm or any other key to choose again\n\n', 's'));
    if isequal(yesno, "y")
        confirm = 1;
    end
    close all;
end

%% 4. PRE-PROCESS FRAME
% define (1) Starting frame and (2) Ending frame of Observation Window
startingFrame=1;
endingFrame=numFrames; 
selectStartingFrame(startingFrame, filename);
videoFrame = videoReader();

% Define tunable parameters
sigma=30; 
minArea=600;
bidirectErr = 3;
pyrLev = 2;
minVisFeatures = 3;
maxDistTransform = 10;

videoFrame = equalizeIllumination(videoFrame, sigma);
videoFrame = imadjust(videoFrame, stretchlim(videoFrame));
multipleBbox = getMultipleROI(videoFrame, numROI);

%% 5. PROCESS EACH ROI
for CurrentROI = 1:numROI
    
    fprintf('Processing ROI #%d \n', CurrentROI);
    
    %% 5.a TRACK FEATURES AND COMPUTE BOX AREA OVER TIME 
    [numSubAreas, bboxSet, videoFramePlot] = subAreas(videoFrame, multipleBbox(CurrentROI, :), minArea);
    fprintf('Number of subAreas for Current ROI #%d \n', numSubAreas + 1);

    AreabboxRegister=zeros(numSubAreas+1, endingFrame);

    errorLoopNum=NaN;
    for k = 1:numSubAreas + 1
        try
            fprintf('Processing subArea #%d \n', k);
            videoReader = vision.VideoFileReader(filename);

            % PREPROCESS FRAME
            frameCount=1;
            while frameCount<startingFrame
                videoFrame=videoReader();
                frameCount = frameCount + 1;
            end

            videoFrame = videoReader();

            videoFrame=equalizeIllumination(videoFrame, sigma);
            videoFrame = imadjust(videoFrame, stretchlim(videoFrame));   % enhance contrast

            % FEATURES TRACKING
            % Detect features
            bboxPoints = bbox2points(bboxSet(k, :));
            points = detectMinEigenFeatures(rgb2gray(videoFrame), 'ROI', ...
                bboxSet(k,:));

            % Track points in video using Kanade-Lucas-Tomasi (KLT) algorithm
            pointTracker = vision.PointTracker('MaxBidirectionalError', ...
                bidirectErr, 'NumPyramidLevels', pyrLev);

            % Initialize all the trackers with the initial point locations and the initial video frame.
            points = points.Location;
            initialize(pointTracker, points, videoFrame);

            % Track the points
            oldPoints = points;

            while frameCount<endingFrame

                % Pre-process
                videoFrame=equalizeIllumination(videoFrame, sigma);
                videoFrame = imadjust(videoFrame, stretchlim(videoFrame));

                % Track the points. Note that some features may be lost.
                [points, isFound] = step(pointTracker, videoFrame);
                visiblePoints = points(isFound, :);
                oldInliers = oldPoints(isFound, :);

                if size(visiblePoints, 1) >= minVisFeatures % need at least 2 points

                    % Estimate the geometric transformation 
                    [xform, oldInliers, visiblePoints] = estimateGeometricTransform(...
                        oldInliers, visiblePoints, 'affine', 'MaxDistance', maxDistTransform);

                    % Apply the transformation to the bounding box points
                    bboxPoints = transformPointsForward(xform, bboxPoints);
                    AreabboxRegister(k, frameCount) = abs(bboxPoints(1,1)- ...
                        bboxPoints(2,1))*abs(bboxPoints(1,2)-bboxPoints(4,2));

                    % Reset the points
                    oldPoints = visiblePoints;
                    setPoints(pointTracker, oldPoints);

                end

                frameCount = frameCount + 1;

                % Read the following frame
                videoFrame = videoReader();

            end

            % Clean up
            release(videoReader);
            release(depVideoPlayer);
            release(pointTracker);


        catch
            errorLoopNum=k;
            fprintf('\nLoop number %d failed\n',k)
            break
        end

    end

    if ~isnan(errorLoopNum)
        plotNum= errorLoopNum - 1;
    else
        plotNum= numSubAreas + 1;
    end
    
    %% 5.b ANALYZE CONTRACTILE BEHAVIOR 
    factorMinProminence = 0.8; % factor used to compute minima prominence
    FrameRate = round(FrameRate);
    plotNum= size(AreabboxRegister, 1); % number of subareas
    confirm = 0;
    evaluate = 0;
    skip = 0;
    
    contractionRate = zeros(plotNum,1);
    contractionVelocity = zeros(plotNum,1);
    contractionAmplitude = zeros(plotNum,1);
    
    % DISPLAY ANALYZED ROI
    figure; imshow(videoFramePlot); title('Current ROI');
    
    % COMPUTE CONTRACTION RATE, MEAN AMPLITUDE, MEAN VELOCITY
    while confirm == 0
        plotDone=0;
        plotWrong=0;
        skipPlotSubArea = 0;
        
        fig = figure;
        while plotDone<plotNum % scan all subareas
            plotDone=plotDone + 1;           
            [plotDone, plotWrong, skipPlotSubArea, minima, contractionRate, contractionVelocityVect, contractionAmplitudeVect] = ...
                analysisArea(filename, AreabboxRegister, plotNum, startingFrame, endingFrame, FrameRate, plotDone, factorMinProminence, ...
                plotDone, plotWrong, skipPlotSubArea)
            
            contractionRate(plotDone) = contractionRate;
            contractionVelocity(plotDone) = mean(contractionVelocityVect);
            contractionAmplitude(plotDone) = mean(contractionAmplitudeVect);
            autoArrangeFigures()
            
        end
        
        if plotWrong == plotNum
            evaluate = 1;
            skip = 1;
            close(fig)
        end
      
        if evaluate ~= 1
            fprintf('\nThe current prominence value for minima identification is %d * sdtBoxArea. \n \ny', factorMinProminence);
            yesno = string(input('\nPress [y] to confirm the current factor or any other key to change it \n\n', 's'));
            if isequal(yesno, "y")
                confirm = 1;
            else
                factorMinProminence = input('\nEnter the factor multiplied for standard deviation of box area to define minima prominence  \n\n');
                if isnumeric(factorMinProminence)== 0
                    fprintf('\nPlease insert a numeric value.\n');
                    continue
                end
            end
        else
            confirm = 1;
        end
        
        
    end
    
    
    %% RETURN CONTRACTION BEHAVIOR
    if skip ~= 1
        
        yesno = string(input('Press [y] to display the contractile behavior info for this ROI. \n\n', 's'));
        
        if isequal(yesno, "y")
            
            selected = 0;
        
            while selected ~= 1
                select = input('\n Enter the number of SubArea which estimates properly cell contraction.\n\n');
                if isnumeric(select) == 0
                    fprintf('\n Please insert a numeric value.\n');
                    continue
                elseif select ~= round(select)
                    fprintf('\n Please insert an integer value.\n');
                    continue
                elseif select > plotNum
                    fprintf('\n Please insert an value between 1 and %d.\n', plotNum);
                    continue
                else
                    selected = 1;
                end
            end

            fprintf('\n Contraction rate: %d contractions per sec.\n', contractionRate(select));
            fprintf('\n Contraction velocity: %d a.u.\n', contractionVelocity(select));
            fprintf('\n Contraction amplitude: %d a.u.\n', contractionAmplitude(select));
        end
    end

    close all;
end
    
