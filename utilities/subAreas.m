function [numSubAreas,bboxSet, videoFramePlot]= subAreas(videoFrame, bbox, minArea)
    % Define ROI subAreas within user-defined ROI 

    if nargin <3
        minArea=400;
    end

    area=bbox(1,3)*bbox(1,4);
    centerCoordinates=[round(bbox(1,1)+bbox(1,3)/2) , round(bbox(1,2)+bbox(1,4)/2)];
    numSubAreas=round(sqrt(area/minArea) -1); % compute the number of sub areas. minimum area 400, then add each time 20 in length and in height
    bboxSet=zeros(numSubAreas + 1, 4); % initialize a matrix where each row is a 4-element vector of the form [xmin ymin width height]
    videoFramePlot=videoFrame;

    bboxSet(1,:) = bbox;
    % Draw the returned bounding box around
    for i=1:numSubAreas
        if area > 0
        %   bboxSet(i,:)=[centerCoordinates(1) - bbox(1,3)/2 + 10 , centerCoordinates(2) - bbox(1,4)/2 + 10 , (bbox(1,3)-i*20) , (bbox(1,4)-i*20)];
        bboxSet(i+1,:)=[(bbox(1,1) + i*10) , (bbox(1,2) + i*10), (bbox(1,3)-i*20) , (bbox(1,4)-i*20)];
        videoFramePlot = insertShape(videoFramePlot, 'Rectangle', bboxSet(i,:));
        area=(bbox(1,3)-(i+1)*20)*(bbox(1,4)-(i+1)*20); %compute the area for the next cycle to verify if it is larger than 200 
        fprintf('SubArea value: %f pixels \n', area);
        end
    end

end