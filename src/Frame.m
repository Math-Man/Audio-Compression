classdef Frame

    properties
        indexStart
        indexEnd
        Data = []
        DataWindowed = [];
    end
    
    methods
        function obj = Frame(Data, start, endi)
            %Frame, Construct an instance of this class
            obj.indexStart = start;
            obj.indexEnd = endi;
            obj.Data = Data;
        end
        
        function out = applyWindow(obj, window)
            %Multiply data with window
            obj.DataWindowed = obj.Data .* window;
            out = obj.DataWindowed;
        end
    end
end

