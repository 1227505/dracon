classdef (Abstract) hasoptions < handle        
    properties
        options;
    end
    
    methods
        function ho = hasoptions(opts)
            if(nargin > 0 && size(opts, 2) == 2)
                for i = 1:size(opts, 1)
                    ho.options.(opts{i, 1}) = opts{i, 2};
                end
            end
        end
    end
end

