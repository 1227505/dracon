classdef quadratic < dracon.nn.ffn.af.relu.training.backprop.cost
    %QUADRATIC Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant, Transient)
        NAME = 'Quadratic'
        DESC = 'TODO';
        DEFAULT = 1;
        INIT = [];
    end
    
    methods
        function cl = clone(~)
            cl = dracon.nn.ffn.af.linear.training.backprop.cost.quadratic();
        end 
    end
    
    methods (Static)
        function out = err(y,a)
            out = sum((y-a).^2)/2;
        end
        
        function out = deltaL(y,a)
           out = a-y;
        end
    end    
end

