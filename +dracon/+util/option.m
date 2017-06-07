classdef (Abstract) option < handle    
    properties (Abstract, Constant, Transient)
        OPT;
        NAME;
        DESC;
        DEFAULT;
        INIT;
    end
    
    properties
        version = 1;
    end
    
    methods
        cl = clone(op);
    end
end

