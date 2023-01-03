function [plotDone, plotWrong, skipPlotSubArea, minima, ...
    contractionRate, contractionVelocity, contractionAmplitude] = ...
    analysisArea(filename, AreabboxRegister, plotNum, startingFrame, endingFrame, FrameRate, k, factorMinProminence, ...
    plotDone, plotWrong, skipPlotSubArea)

        area = AreabboxRegister(k,startingFrame:endingFrame);
        area = area(area ~= 0);
        numFrames = size(area, 2);
        
        % statistics box area
        meanArea = mean(area);
        sdArea = std(area);
        
        % time in sec
        FrameInterval = 1/FrameRate;
        duration=numFrames/FrameRate;
        time=FrameInterval:FrameInterval:duration;
               
                
        if isnan(meanArea) || isnan(sdArea)
            fprintf('\nSubArea # %d not available\n', k)
            plotDone= plotDone + 1;
            plotWrong = plotWrong + 1;
            minima = NaN;
            skipPlotSubArea = 1;
            return
        end
        
        
        %% CONTRACTION (MINIMA)
         % identify contractions (local minima) and pre/post conditions
        minima = islocalmin(area, 'MinProminence' , sdArea*factorMinProminence);
        
        subplot(plotNum*2, 1, (k-1)*2 + 1)
        plot(time,area);
        title(['#', num2str(k),' subArea - ', extractAfter(filename,"\")]);
        xlabel('Time [sec]')
        ylabel('Box Area [a.u.]')
        ylim([meanArea-5*sdArea meanArea+5*sdArea])
        set(gca, 'FontSize', 16)
        hold on
        plot(time(minima), area(minima), '*', "MarkerSize", 10);
        hold off 
        
        %% CONTRACTION RATE
        ROW=(endingFrame-startingFrame)/(FrameRate); %running observation window. 
        contractionRate = sum(minima)/ROW;
         
        
        %% CONTRACTION AMPLITUDE & VELOCITY
        
        contractionLocation = find(minima);
        
        % discard minima where you cannot access the area pre contraction
        if length(contractionLocation)>1
            temp = find(contractionLocation - 15 < 1);
            if temp >= 1
                contractionLocation = contractionLocation(temp(end)+1:end);
            end
        end
        % discard minima where you cannot access the area post contraction
        if length(contractionLocation)>1
            temp = find(contractionLocation + 15 > length(area));
            if temp >= 1
                contractionLocation = contractionLocation(1:temp(1)-1);
            end
        end
           
        preContractionLocation = [];
        postContractionLocation = [];
        
        for l = 1:length(contractionLocation)  
           preContractionLocation = [preContractionLocation, contractionLocation(l) - 15 +  find(area(contractionLocation(l)-15:contractionLocation(l)) == max(area(contractionLocation(l)-15:contractionLocation(l))))];
           postContractionLocation = [postContractionLocation, contractionLocation(l) + find(area(contractionLocation(l):contractionLocation(l)+15) == max(area(contractionLocation(l):contractionLocation(l)+15)))];
        end
        
        
        % "finite difference" derivative
        areaDerivative = diff(area)./diff(time);
        velocityContraction = areaDerivative;
        
        contractionAmplitude = [];
        contractionVelocity = [];   
        
        for i = 1:length(contractionLocation)
            areaBeforeContraction = area(preContractionLocation(i));
            areaAtContraction = area(contractionLocation(i));
            percentageReduction = (areaBeforeContraction-areaAtContraction)/areaBeforeContraction;
            contractionAmplitude = [contractionAmplitude, percentageReduction];
            
            meanVelocity = mean(velocityContraction(preContractionLocation(i): contractionLocation(i)));
            contractionVelocity = [contractionVelocity, meanVelocity];

        end
        
        
        subplot(plotNum*2, 1, k*2)
        title(['#', num2str(k),' subArea - ', extractAfter(filename,"\")]);
        yyaxis left
        ylabel('Box Area [a.u.]')
        plot(time,area, '-b');
        hold on
        plot(time(preContractionLocation), area(preContractionLocation), 'b*')
        plot(time(contractionLocation), area(contractionLocation), 'g*')
        plot(time(postContractionLocation), area(postContractionLocation), 'm*')
        ylim([meanArea-5*sdArea meanArea+5*sdArea])
        
        yyaxis right
        ylabel('Derivative Box Area [a.u.]')
        plot(time(2:end), areaDerivative, '-r');
        ylim([mean(areaDerivative)-5*std(areaDerivative), mean(areaDerivative)+5*std(areaDerivative)])
        xlabel('Time [sec]')
       
        legend('','area @ pre Contraction', 'area @ Contraction', 'area @ post Contraction', 'velocity')
        set(gca, 'FontSize', 16)
        

        
end
        