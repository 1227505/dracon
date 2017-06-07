classdef ffn < dracon.nn
%FFN Summary of this class goes here
%   Detailed explanation goes here

	properties (Constant, Transient, Hidden)
		NAME = 'Feed Forward Neural Network';
		DESC = 'TODO';
		DEFAULT = 1;
		INIT = {{'Number of input nodes', 'N', '', 1},...
				{'Number of output nodes', 'N', '', 1}};
	end

	properties (Dependent)
		combgroup;
	end

	properties 
		in;
		out;
		layers;
	end

	methods
		function ffn = ffn(in, out, opts)
			ffn@dracon.nn(opts);
			ffn.weights = {ones(out, in)};
			ffn.biases = {zeros(out, 1)};
			ffn.in = in;
			ffn.out = out;
			ffn.layers = 1;
		end

		function out = run(ffn, x, batch)
			out = ffn.options.af.run(ffn, x, batch);
		end

		function out = runSimple(ffn, x, batch)
			if(nargin == 2)
				batch = size(x, 2);
			end
			out = ffn.options.af.runSimple(ffn,x,batch);
		end
		
		function a = getInfluence(ffn, x, nod)
			a = ffn.options.af.getInfluence(ffn, x, nod);
		end

		function out = train(ffn, a, y, rate, batch, all)
			out = ffn.options.af.train(ffn, a, y, rate, batch, all);
		end

		function out = trainComb(ffn, nets, len, a, y, ...
				rate, batch, all, inter)
			out = ffn.options.af.trainComb(nets, len, a, y, rate, ...
											batch, all, inter);
		end

		function out = err(ffn, y, a, all)
			if(nargin == 3)
				all = size(y, 2);
			end
			out = ffn.options.af.err(ffn, y, a, all);
		end
		
		function cl = clone(ffn)
			cl = dracon.nn.ffn(0, 0, {});
			cl.name = ffn.name;
			cl.weights = ffn.weights;
			cl.biases = ffn.biases;

			cl.options.af = ffn.options.af.clone();

			cl.in = ffn.in;
			cl.out = ffn.out;
			cl.layers = ffn.layers;
		end

		function addLayers(ffn, after, nnodes, nlay)
			if(after == 0)				% After the input layer
				ffn.weights = [{ones(nnodes, ffn.in)}, ...
					repmat({ones(nnodes)}, 1, nlay-1), ...
					{ones(size(ffn.weights{1}, 1),nnodes)}, ...
					ffn.weights(2:end)];
			
			elseif(after < length(ffn.biases))
										% After any layer in the middle
				ffn.weights = [ffn.weights(1:after), ...
					{ones(nnodes,size(ffn.weights{after}, 1))}, ...
					repmat({ones(nnodes)},1,nlay-1), ...
					{ones(size(ffn.weights{after+1}, 2), nnodes)}, ...
					ffn.weights(after+2:end)];
				
			else						% After the last layer
				ffn.weights = [ffn.weights(1:after), ...
					{ones(nnodes, size(ffn.weights{after}, 1))}, ...
					repmat({ones(nnodes)}, 1, nlay-1)];
				ffn.out = nnodes;
				
			end
			ffn.biases = [ffn.biases(1:after), ...
				repmat({zeros(nnodes, 1)}, 1, nlay), ...
				ffn.biases(after+1:end)];
			
			ffn.layers = ffn.layers + nlay;
		end

		function insertLayers(ffn, after, biases, weights)
			if(after == 0)					% After the input layer
				ffn.weights = [{ones(length(biases{1}), ffn.in)}, ...
					weights, ...
					{ones(length(ffn.biases{1}), length(biases{end}))}, ...
					ffn.weights(2:end)];
				
			elseif(after < length(ffn.biases))% After any layer in the middle
				ffn.weights = [ffn.weights(1:after), ...
					{ones(length(biases{1}), ...
					length(ffn.biases{after}))}, weights, ...
					{ones(length(ffn.biases{after+1}), ...
					length(biases{end}))}, ffn.weights(after+2:end)];
				
			else							% After the last layer
				ffn.weights = [ffn.weights(1:after), ...
					{ones(length(biases{1}), ...
					length(ffn.biases{after}))}, weights];
				ffn.out = length(biases{end});
				
			end
			ffn.biases = [ffn.biases(1:after), ...
							biases, ffn.biases(after+1:end)];
			
			ffn.layers = ffn.layers + length(biases);
		end

		function delNet = rmLayer(ffn, layer)
			if(length(ffn.biases) < 2)
				delNet = 1;
				ffn.out = ffn.in;
				ffn.biases = {};
				ffn.weights = {};
				ffn.layers = 0;
			else
				delNet = 0;
				if(layer < 1)
					ffn.biases = ffn.biases(2:end);
					ffn.weights = ffn.weights(2:end);
					ffn.in = size(ffn.weights{1},2);
				elseif(layer >= length(ffn.biases))
					ffn.biases = ffn.biases(1:end-1);
					ffn.weights = ffn.weights(1:end-1);
					ffn.out = length(ffn.biases{end});
				else
					ffn.biases = [ffn.biases(1:layer-1), ...
								ffn.biases(layer+1:end)];
					ffn.weights = [ffn.weights(1:layer-1), ...
								{ones(size(ffn.weights{layer+1},1), ...
									size(ffn.weights{layer},2))}, ...
								ffn.weights(layer+2:end)];
				end
				ffn.layers = ffn.layers - 1;
			end
		end

		function addNodes(ffn, layer, nnodes)
			if(layer > 0)
				ffn.biases{layer} = [ffn.biases{layer}; zeros(nnodes,1)];
				ffn.weights{layer} = [ffn.weights{layer};...
					ones(nnodes,size(ffn.weights{layer},2))];
				ffn.out = length(ffn.biases{end});
			end
			if(layer < numel(ffn.biases))
				ffn.weights{layer+1} = [ffn.weights{layer+1},...
					ones(size(ffn.weights{layer+1},1),nnodes)];
				ffn.in = size(ffn.weights{1},2);
			end
		end
		
		function insertNodes(ffn, layer, after, biases)
			ffn.biases{layer} = [ffn.biases{layer}(1:after); ...
							biases; ...
							ffn.biases{layer}(after+1:end)];
			nnodes = numel(biases);
			ffn.weights{layer} = [ffn.weights{layer}(1:after,:);...
							ones(nnodes, size(ffn.weights{layer},2)); ...
							ffn.weights{layer}(after+1:end,:)];
			
			if(layer < numel(ffn.biases))
				ffn.weights{layer+1} = [ffn.weights{layer+1}(:,1:after),...
							ones(size(ffn.weights{layer+1},1),nnodes), ...
							ffn.weights{layer+1}(:,after+1:end)];
				ffn.in = size(ffn.weights{1},2);
			end
			ffn.out = numel(ffn.biases{end});
		end

		function delNet = rmNode(ffn, layer, node)
			if((layer < 1 && size(ffn.weights{1},2) < 2) ||...
					(layer > 0 && length(ffn.biases{layer}) < 2))
				delNet = ffn.rmLayer(layer);
			else
				delNet = 0;
				if(layer > 0)
					ffn.biases{layer} = [ffn.biases{layer}(1:node-1); ...
						ffn.biases{layer}(node+1:end)];
					ffn.weights{layer} = ...
						[ffn.weights{layer}(1:node-1,:); ...
						ffn.weights{layer}(node+1:end,:)];
					ffn.out = length(ffn.biases{end});
				end
				if(layer < length(ffn.biases))
					ffn.weights{layer+1} = ...
						[ffn.weights{layer+1}(:,1:node-1), ...
						ffn.weights{layer+1}(:,node+1:end)];
					ffn.in = size(ffn.weights{1},2);
				end
			end
		end
		
		function randomizeWeights(ffn, mu, sigma)
			for k = 1:length(ffn.biases)
				ffn.weights{k} = randn(size(ffn.weights{k})) * sigma + mu;
			end
		end

		function randomizeBiases(ffn, mu, sigma)
			for k = 1:length(ffn.biases)
				ffn.biases{k} = randn(size(ffn.biases{k})) * sigma + mu;
			end
		end
		
		function code = getCode(ffn)
			code = '';
			for k = 1:ffn.layers
				code = [code, '\t', ...
					ffn.options.af.getCode(ffn, k), '\n'];...
					%#ok<AGROW>
			end
		end
		
		function comb = get.combgroup(ffn)
			comb = ffn.options.af.combgroup;
		end
	end
end
