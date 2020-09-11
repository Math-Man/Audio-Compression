function [filterBank] = createMelFilterBankBased(sampleRate, lowerBound, upperBound, filterCount, nfft)


lowFreqMel = (2595 * log10(1 + (lowerBound / 2) / 700));
highFreqMel = (2595 * log10(1 + (upperBound / 2) / 700));

melPoints = linspace(lowFreqMel, highFreqMel, filterCount+2);

hertzPoints = (700 * (10.^(melPoints/2595) - 1));

%Round down the values to fit within the resolution band width
melScaledBins = floor( (nfft + 1) * hertzPoints / sampleRate)+1;

%melscaledbinshz = sampleRate * melScaledBins / (nfft+1);
%melScaledBins = floor(melscaledbinshz);

fBank = zeros(filterCount, floor(nfft/2 + 1));

% figure(888)
% hold on
for m = (1:(filterCount))
    
    fprev = melScaledBins(m);
    fcurrent = melScaledBins(m+1);
    fnext = melScaledBins(m+2);
    
  
    
    for k = fprev:fcurrent
        fBank(m, k) = (k - melScaledBins(m)) / (melScaledBins(m+1) -  melScaledBins(m));
    end
    
    for k = fcurrent:fnext
        fBank(m, k) = (melScaledBins(m+2) - k) / (melScaledBins(m+2) -  melScaledBins(m+1));
    end
%     plot(fBank(m,:));
end
% hold off


filterBank = fBank;

end