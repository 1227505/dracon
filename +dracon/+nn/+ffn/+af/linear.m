classdef linear < dracon.nn.ffn.af
    %LINEAR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant, Transient)
        NAME = 'Linear Function';
        DESC = 'TODO';
        DEFAULT = 0;
        INIT = [];
	end
    
    properties (Dependent)
        combgroup;
	end
    
    methods
        function l = linear(opts)
            l@dracon.nn.ffn.af(opts);
		end
		
        function comb = get.combgroup(l)
            comb = l.options.training.COMBGROUP;
		end
        
        function out = train(l, ffn, a, y, rate, batch, all)
            out = l.options.training.train(ffn, a, y, rate, batch, all);
        end
        
        function out = err(l, ffn, y, a, all)
            out = l.options.training.err(ffn, y, a, all);
		end
        
        function out = trainComb(l, nets, len, a, y, rate, ...
												batch, all, inter)
            out = l.options.training.trainComb(nets, len, a, y, rate, ...
												batch, all, inter);
        end
        
        function cl = clone(l)
            cl = dracon.nn.ffn.af.linear({});
            cl.options.training = l.options.training.clone();
		end
    end
    
    methods (Static)
        function a = run(ffn, x, num)
            a = ffn.biases;
            a{1} = ffn.weights{1} * x + repmat(ffn.biases{1},1,num);
            for k = 2:size(ffn.weights, 2)
                a{k} = ffn.weights{k} * a{k-1} + ...
					repmat(ffn.biases{k}, 1, num);
            end
            a = [{x}, a];
		end
		
        function a = getInfluence(ffn, x, nod)
            a = ffn.biases;
			pos = ~isnan(nod{1});
			x(pos) = nod{1}(pos);
            a{1} = ffn.weights{1} * x + ffn.biases{1};
			pos = ~isnan(nod{2});
			a{1}(pos) = nod{2}(pos);
            for k = 2:size(ffn.weights, 2)
                a{k} = ffn.weights{k} * a{k-1} + ffn.biases{k};
				pos = ~isnan(nod{k+1});
				a{k}(pos) = nod{k+1}(pos);
            end
            a = [{x}, a];
        end
        
        function out = runSimple(ffn, in, num)
            out = ffn.weights{1}*in+repmat(ffn.biases{1},1,num);
            for k = 2:size(ffn.weights,2)
                out = ffn.weights{k}*out+repmat(ffn.biases{k},1,num);
            end
        end
		
		function code = getCode(ffn, lay)
			bias = mat2str(ffn.biases{lay});
			weights = mat2str(ffn.weights{lay});
			code = ['x = ', weights, ' * x + ', ...
					'repmat(', bias, ', 1, num);'];
		end
    end
end

