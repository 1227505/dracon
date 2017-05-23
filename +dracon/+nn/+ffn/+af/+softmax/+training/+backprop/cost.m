classdef (Abstract) cost < dracon.util.option
    %COST Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant, Transient)
        OPT = 'Cost Function';
    end
    
    methods (Abstract, Static)
        out = err(y,a);
        out = deltaL(y,a);
    end
end

