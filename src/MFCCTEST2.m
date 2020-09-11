[recording, fs] = audioread('odev.wav');
recording_new = highpass(recording,100,fs); %remove DC and 60 Hz hum  
recording=recording_new;

chunkSizeSeconds = 0.03;   %Window Length in seconds 
frameShiftSeconds = chunkSizeSeconds/4;   


frameLength = chunkSizeSeconds*fs;
recordingLength = length(recording);
frameShiftLength = frameShiftSeconds*fs;
frameShiftCount = ceil(frameShiftLength);

frameCount = floor((floor(recordingLength/frameShiftCount) - floor(frameLength/frameShiftCount)));   

frames = [];

for  frame=1:frameCount

    frameStart = (frame - 1)* frameLength+1 - ( 3*(frame-1)*frameShiftCount);
    frameEnd = frameStart + frameLength-1;
    
    frames(frame,:) = (recording(frameStart:frameEnd).*hamming(frameLength)); 
end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %  % % % 
% http://practicalcryptography.com/miscellaneous/machine-learning/%guide-mel-frequency-cepstral-coefficients-mfccs/
% 

%fft of frames preiodgram


mag_frames = abs(fft(frames', 1024));
pow_frames = ((1/1024) * ((mag_frames).^2));
plot(pow_frames);
pow_frames = pow_frames(1:length(pow_frames)/2 + 1,:);  %Crop the ffts to half coefficents
filterbank = createMelFilterBankBased(frames, fs, 10, fs, 26, 1024);

%plot(pow_frames);

% frameFFT = [];
% for frame = 1:length(frames)
%     frameFFT(frame,:)= (1/512) * abs((fft(frames(frame),512))).^2;
% end
% 
% plot(frameFFT);

%filterpowers = dot(frameFFT, filterbank');
filterpowers = filterbank * pow_frames;
%filterpowers = 20 * log10(filterpowers);
figure(1233)
plot(filterpowers)

% filterbankEnergy = [];
% for i = 1:length(filterbank(:,1))
%     filterbankEnergy(i) = sum(filterpowers(i,:));   %total energy in filterbanks
% end
% plot(filterbankEnergy)

filterbankEnergy = 20 * log10(filterpowers);
%plot(filterbankEnergy)

FoundCoeffs = dct(filterbankEnergy);
figure(3)
hold on
for i = 1:13
    plot(FoundCoeffs(i,:))
end
hold off


%real
[coeffs delta deltadelta loc] = mfcc(recording, fs, 'WindowLength', 480, 'OverlapLength', 360, 'NumCoeffs', 13, 'FFTLength', 1024);
figure(4)
hold on
for i = 2:13
    plot(coeffs(:,i))
end
hold off




