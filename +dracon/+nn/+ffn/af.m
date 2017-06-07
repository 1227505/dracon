classdef (Abstract) af < dracon.util.option & dracon.util.hasoptions
    
    properties (Constant, Transient)
        OPT = 'Activation Function';
	end
    
    properties (Abstract)
        combgroup;
	end
    
    methods (Abstract)		
        out = train(af, ffn, a, y, rate, batch, all);
        out = trainComb(af, nets, len, a, y, rate, batch, all, inter);
        out = err(af, ffn, y, a);
		
		cl = clone(af);
    end
    
    methods (Abstract, Static)
        out = run(ffn, x, num);
        out = runSimple(ffn, x, num);
		
		inf = getInfluence(ffn, x, nods);
		
		% Variable "x" contains the input for the current layer
		% and should contain the output afterwards
		% Variable "num" contains the number of input elements.
		code = getCode(ffn, lay);
    end
    
    methods        
        function a = af(opts)
            a@dracon.util.hasoptions(opts);
		end
    end
end

