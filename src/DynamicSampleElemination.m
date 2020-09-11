function [reducedFrame newFrameLength] = DynamicSampleElemination(frame, reductionPercent)
%Reduces number of samples in a frame depending on the amount of 
%"percieved information" of that sample. This is highly reliant on the Log
%Energy of the frame and the avarage energy in the frame


%Number of samples to remove
removeCount = floor(length(frame) * reductionPercent);
newFrameLength = length(frame) - removeCount;


%Calculate scaled log energy of the frames
frameLogEnergy = 10 * log10((frame.^2)) - max(10*log10(frame.^2)); %Pulls the first term to the 0 normal level

%find avarage energy
avrg = mean(frameLogEnergy);


%Find the samples within energy threshold of: A*.80 < E < A*1.35
%Sample threshold values
rangeHigh = 1.19;
rangeLow = 0.9;

%Make sure there are enough samples to remove with this while loop
boundedIndexes = [];
validIndexes = [];
validEnergies = [];
while (length(validIndexes) < removeCount) %length(boundedIndexes) < removeCount
lowerT = avrg * rangeHigh;
upperT = avrg * rangeLow;
boundedIndexes = find( (frameLogEnergy > lowerT) & (frameLogEnergy < upperT)); %Note that log energy is inverse (its represented in minus)
boundedEnergies = frameLogEnergy(boundedIndexes);


%Check validity of boundedIndexes
%check if the neighbouring samples are ?N TRANSITION
CHECK_RANGE = 3;
for ind = 1:length(boundedIndexes)
    if( (boundedIndexes(ind) > (1 + CHECK_RANGE*2)) && boundedIndexes(ind) < length(frame) - CHECK_RANGE*2) %not at the end or the start by 10 samples
        %Check the energy of previous samples (previous 5)
        previousEnergies = frameLogEnergy((boundedIndexes(ind) - CHECK_RANGE):(boundedIndexes(ind) - 1));
        nextEnergies = frameLogEnergy( (boundedIndexes(ind) + 1) : (boundedIndexes(ind) + CHECK_RANGE));
        
        %If the avarage of previous Energies is lower/higher than current energy
        %and the avarage of next energies    is higher/lower than current energy
        %In other terms, energy must not be a peak, must be an intermediate
        %value between two possible peaks
        if(mean(previousEnergies) < boundedEnergies(ind) && mean(nextEnergies) > boundedEnergies(ind))
            %'increasing'
            validIndexes  = [validIndexes boundedIndexes(ind)];
            validEnergies  = [validEnergies boundedEnergies(ind)];
        elseif (mean(previousEnergies) > boundedEnergies(ind) && mean(nextEnergies) < boundedEnergies(ind))
            %'decreasing'
            validIndexes  = [validIndexes boundedIndexes(ind)];
            validEnergies  = [validEnergies boundedEnergies(ind)];
        else
            %Bounded value is a peak, dont add, don't do anything
        end
        
           
    end
end

%If there arent "valid" samples to remove, increase thresholds
if (length(validIndexes) < removeCount)
    rangeHigh = rangeHigh + (rangeHigh * 0.06);
    rangeLow = rangeLow - (rangeLow * 0.06);
end
end

%Find and remove <removeCount> samples
%Remove the smallest value first, then find the next smallest value, repeat
reducedFrame = frame;
for rc = 1:removeCount
    
    %switch between max and mix equally
    if (mod(rc, 2) == 0)
        [M, I] = max(validEnergies); %Find the minimum energy sample in the current frame
    else
        [M, I] = min(validEnergies); %Find the maximum energy sample in the current frame
    end
        
    %THIS VALUE SHOULD NOT BE ABOVE 0.1 FOR BEST RESULTS
    SmoothedSamplePercent = 0.03; % framelength's x% of samples are smoothed out by a margin of the removed sample 
    SmoothHardness = 0.3;   %maximum additive from the sample that is going to be removed
    
    numberOfSamplesToSmooth = floor(newFrameLength * SmoothedSamplePercent);
    
    
    for Lrft = 1:numberOfSamplesToSmooth
        
        %Smooth out the neighbouring samples
        if(~(I - Lrft < 1))  %Previous samples
            reducedFrame(I - Lrft) = reducedFrame(I - Lrft) - (reducedFrame(I) * (SmoothHardness - SmoothHardness*((1/Lrft))));  %Reduce previous sample magnitude by a margin of the removed ssample
        end

        if(~(I + Lrft > newFrameLength))%Next samples
            reducedFrame(I + Lrft) =  reducedFrame(I + Lrft) + (reducedFrame(I)  *  (SmoothHardness - SmoothHardness*((1/Lrft)))); %increase next sample magnitude by a margin of the removed ssample
        end
    end


    reducedFrame(I) = [];   %Remove sample

end




%Uncomment the following code to draw plots of reduced and normal frames

% figure(1000)
% plot((-frameLogEnergy));
% 
% figure(1001);
% subplot(2,1,1)
% plot((frame));
% subplot(2,1,2)
% plot((reducedFrame));


end

