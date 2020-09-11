clc;clear;close all;

%%%%NOTES:%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  REQUIRED FILES:
%  1. BandwidthCompression.m
%  2. DynamicSampleElemination.m
%  3. Audio File
%
% 1-) When using dynamic scaling, smaller frames perform better as they "hide" the periodicty which appears from removing samples
% 2-) A frameLength of 0.01 seconds can handle a scaling factor of up to 7.5% (0.075) before removal frequencies become too overwhelming
% 3-) A frameLength of 0.01 can handle scaling of 5% before losing quality
% 4-) A higher cast factor can handle higher scaling factor, additive.
% 5-) A scaling factor of 0.025 (2.5%) is best suitable for frameLength of 0.01 and cast factor of 2
%
% 6-) Spectrogram shows the frequency of the sample removal, this can't be filtered out using normal filters
% 7-) Audio losses quality when there are more than 3 removal frequencies.
%
% 8-) Using scaling factor to reduce is additive  compression
% 9-) Using casting/bandwidth reduction is multplicative compression
% 10-) voice is better at being compressed than music, therefore can handle lower scaling factor
% 11-) BACompression in bandwidth deafens the sharpness in deep voices
%
% FUTURE TO-DO:
% 12-) Implement a better smoothing method in dynamic sample removal
% 13-) Filter out removed sample periodicity using stopband filters
% 14-) Implementing functional psychoustics filtering at hearing thresholds per frame basis
% 15-) missing data interpolation to recover compressed signal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
SCALING_FACTOR = 0.10;  %DSE Factor
CAST_FACTOR = 2;        %DCTC Factor
FRAME_LENGTH_SECONDS = 0.005;
OVERLAP_RATIO = 0.5;


[rec, fs] = audioread('odev.wav');
rec = highpass(rec,100,fs); %remove DC and 60 Hz hum  

%Convert to mono (rastarize channels)
channelCount = length(rec(1,:));
if(channelCount ~=1 )
   rec = sum(rec,2)/channelCount;   
end


%Set frame parameters
chunkSizeSeconds = FRAME_LENGTH_SECONDS;   %Window Length in seconds D:0.025
frameShiftSeconds = chunkSizeSeconds * OVERLAP_RATIO;   % 75% overlap

frameLength = ceil(chunkSizeSeconds*fs);
recordingLength = length(rec);
frameShiftLength = frameShiftSeconds*fs;
frameShiftCount = ceil(frameShiftLength);

%Number of frames; (recording length / amount of shift) = number of frames,
%-(frameLength/frameShiftCount) ; number of frames to discard to prevent indexing non-existant samples
frameCount = floor(recordingLength/(frameShiftCount/3)) - floor(frameLength/frameShiftCount);   


%Frames are scaled with hamming window!!
%Split audio into frames
frames = [];
for  frame=1:frameCount

    frameStart = (frame - 1)* frameLength+1 - ( (frame-1)*frameShiftCount); % Select start and end of the frame 
    frameEnd = frameStart + frameLength-1;
    
    if(frameEnd > recordingLength)  %Sanity check (no outbounding frames)
       break; 
    end
    
    frames(frame,:) = (rec(frameStart:frameEnd).*hamming(frameLength)); %Add the new frame to the list
    
    clc;
    f = sprintf('Building frames: %d / %d', frame, frameCount);
    disp(f);
    
end


 
%dynamic compression
reducedFrames = []; %Process frames list
for frame = 1:length(frames(:,1))

    [reducedFrame, newFrameLength] = DynamicSampleElemination(frames(frame,:), SCALING_FACTOR); %Apply dynamic compression
    
    reducedFrames(frame,:) = reducedFrame;  %Save reduced frame to list
    
    clc;
    f = sprintf('Reducing Frames: %d / %d', frame, length(frames(:,1)));
    disp(f);
    
end
newSamplingFreq = fs*(1 - SCALING_FACTOR);
newRecordingLength = floor(recordingLength*(1 - SCALING_FACTOR));
frameLength = newFrameLength;
frames = reducedFrames;


%rebuild from frames
%Uses overlap and add method
skipCount = floor((frameLength - frameShiftCount) * (1-SCALING_FACTOR)); %set frame shift to be 75% (uncomment and Check alignment in memory )
rebuiltSignal = [];%zeros(1, (newRecordingLength));
%frameAlignment = zeros(1, (recordingLength));
rebuiltSignal( 1, (skipCount*(1-1) + 1 ):(skipCount*(1-1) + length(frames(1,:)))) =  frames(1,:);
for i = 2:length(frames(:,1))

    rebuiltSignal( 2, (skipCount*(i-1) + 1 ):(skipCount*(i-1) + length(frames(i,:)))) =  frames(i,:);
    rebuiltSignal = sum(rebuiltSignal);

    clc;
    f = sprintf('Processing frames: %d / %d', i, length(frames(:,1)));
    disp(f);
end

rebuiltSignal = rebuiltSignal';
fs = ((length(rebuiltSignal)/length(rec)) * fs);


[downsamplescompressed, compressed] = BandwidthCompression(rebuiltSignal, frameLength, CAST_FACTOR);
    

figure(3)
subplot(2,1,1)
plot(rec);
subplot(2,1,2)
plot(compressed);
figure(4)
subplot(2,1,1)
specgram(rec);
subplot(2,1,2)
specgram(compressed);



audiowrite('Sounds\new.wav',downsamplescompressed, ceil(fs/CAST_FACTOR))
'done'

%soundsc(rec,fs);