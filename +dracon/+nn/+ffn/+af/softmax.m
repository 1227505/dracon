classdef softmax < dracon.nn.ffn.af
	%SOFTMAX Summary of this class goes here
	%   Detailed explanation goes here

	properties (Constant, Transient)
		NAME = 'Softmax Function';
		DESC = 'TODO';
		DEFAULT = 0;
		INIT = [];
	end

	properties (Dependent)
		combgroup;
	end

	methods
		function s = softmax(opts)
			s@dracon.nn.ffn.af(opts);
		end

		function comb = get.combgroup(s)
			comb = s.options.training.COMBGROUP;
		end

		function out = train(s, ffn, x, y, rate, batch, all)
			out = s.options.training.train(ffn, x, y, rate, batch, all);
		end

		function out = err(s, ffn, y, a, all)
			out = s.options.training.err(ffn, y, a, all);
		end

		function out = trainComb(s, nets, len, x, y, rate, ...
									batch, all, inter)
			out = s.options.training. ...
				trainComb(nets,len,x,y,rate,batch,all,inter);
		end

		function cl = clone(s)
			cl = dracon.nn.ffn.af.softmax({});
			cl.options.training = s.options.training.clone();
		end
	end

	methods (Static)
		function a = run(ffn, x, num)
			a = ffn.biases;
			a{1} = exp(ffn.weights{1}*x+repmat(ffn.biases{1},1,num));
			a{1} = a{1}./(ones(numel(ffn.biases{1}),1)*sum(a{1}, 1));
			for k = 2:size(ffn.weights,2)
				a{k} = exp(ffn.weights{k} * a{k-1} + ...
					repmat(ffn.biases{k}, 1, num));
				a{k} = a{k}./(ones(numel(ffn.biases{k}),1)*sum(a{k}, 1));
			end
			a = [{x}, a];
		end

		function a = getInfluence(ffn, x, nod)
			a = ffn.biases;
			pos = ~isnan(nod{1});
			x(pos) = nod{1}(pos);
			a{1} = exp(ffn.weights{1}*x + ffn.biases{1});
			a{1} = a{1}./(ones(numel(ffn.biases{1}),1) * sum(a{1}, 1));
			pos = ~isnan(nod{2});
			a{1}(pos) = nod{2}(pos);
			for k = 2:size(ffn.weights,2)
				a{k} = exp(ffn.weights{k} * a{k-1} + ffn.biases{k});
				a{k} = a{k}./(ones(numel(ffn.biases{k}),1)*sum(a{k}, 1));
				pos = ~isnan(nod{k+1});
				a{k}(pos) = nod{k+1}(pos);
			end
			a = [{x}, a];
		end

		function out = runSimple(ffn, x, num)
			out = exp(ffn.weights{1}*x+repmat(ffn.biases{1},1,num));
			out = out ./ (ones(numel(ffn.biases{1}),1) * sum(out, 1));
			for i = 2:size(ffn.weights,2)
				out = exp(ffn.weights{i}*out+repmat(ffn.biases{i},1,num));
				out = out./(ones(numel(ffn.biases{i}),1) * sum(out, 1));
			end
		end
		
		function code = getCode(ffn, lay)
			bias = mat2str(ffn.biases{lay});
			weights = mat2str(ffn.weights{lay});
			one = mat2str(ones(numel(ffn.biases{lay}), 1));
			code = ['x = exp(', weights, ' * x + ', ...
					'repmat(', bias, ', 1, num));\n\t'];
			code = [code, 'x = x ./ (', one, ' * sum(x, 1));'];
		end
	end
end

