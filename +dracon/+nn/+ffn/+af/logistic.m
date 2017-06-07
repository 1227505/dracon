classdef logistic < dracon.nn.ffn.af
	%LOGISTIC Summary of this class goes here
	%   Detailed explanation goes here

	properties (Constant, Transient)
		NAME = 'Sigmoid Function (Logistic)';
		DESC = 'TODO';
		DEFAULT = 1;
		INIT = [];
	end
    
    properties (Dependent)
        combgroup;
	end

	methods
		function l = logistic(opts)
			l@dracon.nn.ffn.af(opts);
		end

		function comb = get.combgroup(l)
			comb = l.options.training.COMBGROUP;
		end
		
		function out = train(l, ffn, a, y, rate, batch, all)
			out = l.options.training.train(ffn, a, y, rate, batch, all);
		end

		function out = trainComb(l, nets, len, a, y, ...
				rate, batch, all, inter)
			out = l.options.training.trainComb(nets, len, a, y, ...
				rate, batch, all, inter);
		end

		function out = err(l, ffn, y, a, all)
			out = l.options.training.err(ffn, y, a, all);
		end

		function cl = clone(l)
			cl = dracon.nn.ffn.af.logistic({});
			cl.options.training = l.options.training.clone();
		end
	end

	methods (Static)
		function a = run(ffn, x, num)
			a = ffn.biases;
			a{1} = 1./(1+exp(-ffn.weights{1}*x - ...
				repmat(ffn.biases{1},1,num)));
			for k = 2:size(ffn.weights,2)
				a{k} = 1./(1+exp(-ffn.weights{k}*a{k-1} - ...
					repmat(ffn.biases{k},1,num)));
			end
			a = [{x}, a];
		end

		function a = getInfluence(ffn, x, nod)
			a = ffn.biases;
			pos = ~isnan(nod{1});
			x(pos) = nod{1}(pos);
			a{1} = 1./(1+exp(-ffn.weights{1}*x - ffn.biases{1}));
			pos = ~isnan(nod{2});
			a{1}(pos) = nod{2}(pos);
			for k = 2:size(ffn.weights,2)
				a{k} = 1./(1+exp(-ffn.weights{k}*a{k-1} - ffn.biases{k}));
				pos = ~isnan(nod{k+1});
				a{k}(pos) = nod{k+1}(pos);
			end
			a = [{x}, a];
		end

		function out = runSimple(ffn, x, num)
			out = 1./(1+exp(-ffn.weights{1}*x - ...
				repmat(ffn.biases{1}, 1, num)));
			for k = 2:size(ffn.weights,2)
				out = 1./(1+exp(-ffn.weights{k}*out - ...
					repmat(ffn.biases{k}, 1, num)));
			end
		end
		
		function code = getCode(ffn, lay)
			bias = mat2str(ffn.biases{lay});
			weights = mat2str(ffn.weights{lay});
			code = ['x = 1 ./ (1+exp(-', weights, ' * x - ', ...
					'repmat(', bias, ', 1, num)));'];
		end
	end
end

