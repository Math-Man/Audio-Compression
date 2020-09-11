function [downsamplescompressed, compressed] = BandwidthCompression(rec, frameLength, sampleCast)


    compressed = [];
    sampleFactor = ceil(frameLength / sampleCast);

    for i=1:frameLength:length(rec)-frameLength
        frameDCT = dct(rec(i:i+frameLength-1));
        compressed(i:i+frameLength-1) = idct(frameDCT(1:sampleFactor), frameLength);
    end
    
    
    downsamplescompressed = downsample(compressed, sampleCast);

end

