classdef backprop < dracon.nn.ffn.af.linear.training & ...
		dracon.general.backprop;
    %BACKPROP Summary of this class goes here
    %   Detailed explanation goes here
    
    methods
        function b = backprop(lam,opts)
            b@dracon.nn.ffn.af.linear.training(opts);
            b.lam = lam;
        end
        
        function cl = clone(b)
            cl = dracon.nn.ffn.af.linear.training.backprop(b.lam,{});
            cl.options.cost = b.options.cost.clone();
        end
    end
    
    methods (Static)
        function out = delta(next, weights, ~)
            out = weights.' * next;
        end
    end
end

