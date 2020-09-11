function [reducedFrame, removedSamples] = FrameEnergyBasedReduction(frame, fs, nfft, reductionPercentage)
%reduction percantge is between 0.01 and 0.2.
%This algorithm is a heavily modified and overly simplified version of
%temporal masking, This does not use any predictors.

    %Frame Preprocessing
    mag_frame = abs(fft(frame, nfft));
    pow_frame = ((1/nfft) * ((mag_frame).^2));
    pow_frame = pow_frame(1:length(pow_frame)/2 + 1);  %Crop the ffts to half coefficents
    filterbank = createMelFilterBankBased(fs, 10, fs, 40, nfft);
    filterpower = pow_frame * filterbank' ;
    filterbankEnergy = 20 * log10(filterpower);
    
    
    
    %Actual Reduction
    sampleRemoveCount = floor( numel(frame) * reductionPercentage );
    
    %Find the highest energy filter in the filter bank
    [highestEnergyFilter, index] = min(filterbankEnergy);
   
   

    
end

