function videoFrame=equalizeIllumination(videoFrame, sigma)
    % Equalize illunination to imrpove features tracking
    
    if nargin<2
        sigma=30;
    end

    hsvimage = rgb2hsv(videoFrame);
    new_hsv(:,:,1) = hsvimage(:,:,1); % same h
    new_hsv(:,:,2) = hsvimage(:,:,2); % same s

    % Apply a gaussian blur to the V channel image with a very large value for sigma. 
    blurredV = imgaussfilt(hsvimage(:,:,3),sigma); % This gives you a local average for the illumination. 

    % Compute the global average V value for this image. 
    globalAv=mean(blurredV);

    % Then Subtract the local average value from the actual V value for each pixel 
    % and add the global average. This process can be considered a basic illumination equalization. 

    new_hsv(:,:,3)= hsvimage(:,:,3) - blurredV(:,:) + globalAv;

    videoFrame = hsv2rgb(new_hsv);

end
