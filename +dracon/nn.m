classdef (Abstract) nn < dracon.util.option & dracon.util.hasoptions
    %NN Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        name = 'Net';
    end
    
    properties (Constant, Transient)
        OPT = 'Network Type';
    end
    
    properties
        weights;
        biases;
    end
    
    properties (Abstract)
        combgroup;	% Nets that can be trained together share this value.
        
        in;     % Size of the input layer.
        out;    % Size of the output layer.
        layers; % Number of layers, excluding the input layer.
    end
    
    methods (Abstract)        
        out = run(nn, x, batch);
		% Test speed benefits, if none, remove
        out = runSimple(nn, x, batch);
        
        out = train(nn, x, y, rate, batch, all);
        out = trainComb(nn, nets, len, x, y, rate, batch, all, inter);
        out = err(nn, y, a, all);
		
		inf = getInfluence(nn, x, nods);
        
        cl = clone(nn);
        addLayers(nn, after, nnode, nlay);
		insertLayers(nn, after, biases, weights);
        delNet = rmLayer(nn, layer);
        addNodes(nn, layer, nnode);
		insertNodes(nn, layer, after, biases);
        delNet = rmNode(nn, layer, node);
        
        randomizeWeights(ffn, min, max);
		randomizeBiases(ffn, min, max);
		
		code = getCode(ffn);
    end
    
    methods
        function n = nn(opts)
            n@dracon.util.hasoptions(opts);
        end
    end
end

