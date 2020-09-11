function [outputArg1,outputArg2] = FrameReduction(frame, fs, nfft)
%FRAMEREDUCTION Summary of this function goes here
%   uses mel filterbank to downsample the frame, depending on the amount of
%   energy within certain mfcc features. 
%   This results in a lossy but hard-to-percieve compression



    mag_frame = abs(fft(frame, nfft));
    pow_frame = ((1/nfft) * ((mag_frame).^2));
    
 
    %plot(pow_frame);
    pow_frame = pow_frame(1:length(pow_frame)/2 + 1);  %Crop the ffts to half coefficents
    filterbank = createMelFilterBankBased(fs, 10, fs, 40, nfft);

  
    filterpower = pow_frame * filterbank' ;
   
    
    
    
    filterbankEnergy = 20 * log10(filterpower);
    %figure(1)
    %plot(filterbankEnergy(2:40))

    %figure(2)
    %spectrogram(frame, 1103, 0, nfft, fs, 'yaxis'); 
    
    
    coeffs = dct(filterbankEnergy);
    
   % plot(coeffs(3:13));

end

