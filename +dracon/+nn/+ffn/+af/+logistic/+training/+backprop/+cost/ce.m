classdef ce < dracon.nn.ffn.af.logistic.training.backprop.cost
    %Cross-Entropy Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant, Transient)
        NAME	= 'Cross-Entropy';
        DESC	= 'TODO';
        DEFAULT = 1;
        INIT	= [];
		
		MAX		= log(realmax('double'));
    end
    
    methods
        function cl = clone(~)
            cl = dracon.nn.ffn.af.logistic.training.backprop.cost.ce();
        end 
    end
    
    methods (Static)
        function out = err(y, a)
			import dracon.nn.ffn.af.logistic.training.backprop.cost.ce
			ma = (a >= 1);
			mi = (a <= 0);
			la = log(a);
			la(mi) = -ce.MAX;
			l1a = log(1-a);
			l1a(ma) = -ce.MAX;
            out = sum(-y .* la + (y-1) .* l1a);
        end
        
        function out = deltaL(y, a)
           out = a - y;
        end
    end
end

