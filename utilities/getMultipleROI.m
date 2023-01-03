function multipleBbox = getMultipleROI(videoFrame, n)
    % Select MULTIPLE regions ROI using a mouse. 
    if nargin<2
        n=1;
    end

    multipleBbox=zeros(n, 4); % 4-element vector of the form [xmin ymin width height] repeated 3 times (3 rows)

    for currentROI =1:n

        figure;

        imshow(videoFrame); title('Draw with the mouse the selected object');
        multipleBbox(currentROI, :)=round(getPosition(imrect)) % 4-element vector of the form [xmin ymin width height]
        close

    end

end
