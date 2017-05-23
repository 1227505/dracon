classdef (Abstract) training < dracon.util.option & dracon.util.hasoptions
    %METHOD Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant, Transient)
        OPT = 'Training method'
    end
    
    methods (Abstract)
        out = train(t, ffn, x, y, rate, batch, all);
        out = err(t, ffn, y, a);
    end
       
    methods (Abstract, Static);
        out = trainComb(nets, len, x, y, rate, batch, all, inter);
    end
    
    methods
        function tr = training(opts)
            tr@dracon.util.hasoptions(opts);
        end
    end
end

