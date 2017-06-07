classdef relu < dracon.nn.ffn.af
    %RELU Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant, Transient)
        NAME = 'Rectified Linear Function';
        DESC = 'TODO';
        DEFAULT = 0;
        INIT = [];
	end
    
    properties (Dependent)
        combgroup;
	end
    
    methods
        function r = relu(opts)
            r@dracon.nn.ffn.af(opts);
		end
		
        function comb = get.combgroup(r)
            comb = r.options.training.COMBGROUP;
		end
        
        function out = train(r, ffn, a, y, rate, batch, all)
            out = r.options.training.train(ffn, a, y, rate, batch, all);
        end
        
        function out = err(r, ffn, y, a, all)
            out = r.options.training.err(ffn, y, a, all);
		end
        
        function out = trainComb(r, nets, len, a, y, rate, ...
												batch, all, inter)
            out = r.options.training.trainComb(nets, len, a, y, rate, ...
												batch, all, inter);
        end
        
        function cl = clone(r)
            cl = dracon.nn.ffn.af.relu({});
            cl.options.training = r.options.training.clone();
		end
    end
    
    methods (Static)
        function a = run(ffn, x, num)
            a = ffn.biases;
            a{1} = max(ffn.weights{1} * x + ...
				repmat(ffn.biases{1},1,num), 0);
            for k = 2:size(ffn.weights, 2)
                a{k} = max(ffn.weights{k} * a{k-1} + ...
					repmat(ffn.biases{k}, 1, num), 0);
            end
            a = [{x}, a];
		end
		
        function a = getInfluence(ffn, x, nod)
            a = ffn.biases;
			pos = ~isnan(nod{1});
			x(pos) = nod{1}(pos);
            a{1} = max(ffn.weights{1} * x + ffn.biases{1}, 0);
			pos = ~isnan(nod{2});
			a{1}(pos) = nod{2}(pos);
            for k = 2:size(ffn.weights, 2)
                a{k} = max(ffn.weights{k} * a{k-1} + ffn.biases{k}, 0);
				pos = ~isnan(nod{k+1});
				a{k}(pos) = nod{k+1}(pos);
            end
            a = [{x}, a];
        end
        
        function out = runSimple(ffn, in, num)
            out = max(ffn.weights{1} * in + ...
				repmat(ffn.biases{1},1,num), 0);
            for k = 2:size(ffn.weights,2)
                out = max(ffn.weights{k} * out + ...
					repmat(ffn.biases{k},1,num), 0);
            end
        end
		
		function code = getCode(ffn, lay)
			bias = mat2str(ffn.biases{lay});
			weights = mat2str(ffn.weights{lay});
			code = ['x = max(', weights, ' * x + ', ...
					'repmat(', bias, ', 1, num), 0);'];
		end
    end
end

