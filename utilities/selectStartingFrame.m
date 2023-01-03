function selectStartingFrame(startingFrame, filename)
    % Swipe frames till the startingFrame

    videoReader=vision.VideoFileReader(filename); 
    frameCount=1;
    while frameCount<startingFrame
        videoFrame=videoReader();
        frameCount = frameCount + 1;
    end

end
