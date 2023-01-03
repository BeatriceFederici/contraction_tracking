function frameCount = displayVideo(videoReader, depVideoPlayer)
    % Display video
    cont = ~isDone(videoReader);
    frameCount=1;
    while cont

        videoFrame = videoReader();
        frameBlobTxt = sprintf('Frame %d', frameCount);
        videoFrame = insertText(videoFrame, [1 1], frameBlobTxt, ...
            'FontSize', 16, 'BoxOpacity', 0, 'TextColor', 'white');
        depVideoPlayer(videoFrame);
        frameCount = frameCount + 1;
        cont = ~isDone(videoReader) && isOpen(depVideoPlayer);
    end
  
end
