classdef (Abstract) backprop < handle
%BACKPROP Summary of this class goes here
%   Detailed explanation goes here

	properties (Constant, Transient)
		NAME = 'Backpropagation';
		DESC = 'TODO';
		DEFAULT = 1;
		INIT = {{['L', char(8322), '-Regularization'],'R0+',...
			['<html>Makes the network favor smaller weights.<br>'...
			'Sometimes helps to ignore noise.<br><br>'...
			'Enter a value between 0 and 1.<br>'...
			'Set 0 to deactivate.</html>'], 0}};

		COMBGROUP = 'backprop';
	end

	properties
		lam;
	end

	methods (Abstract)
		out = delta(next,weights,a);
	end

	methods        
		function out = err(b, ffn, y, a, all)
			reg = 0;
			if(b.lam > 0)
				for i = 1:size(ffn.weights,2)
					reg = reg + sum(ffn.weights{i}(:).^2);
				end
				reg = reg*b.lam/2/all;
			end
			out = b.options.cost.err(y,a) + reg;
		end
	end

	methods
		function out = train(b, ffn, a, y, rate, batch, all)
			del = b.options.cost.deltaL(y, a{end});
			b.adjust(ffn, a, del, rate, batch, all);
			out = a{end};
		end

		function del = adjust(b, ffn, a, del, rate, batch, all)
			if(b.lam > 0)
				reg = 1 - b.lam * rate/all;
			end
			rate = rate/batch;
			L = numel(ffn.biases);
			dw = del * a{end-1}.' * rate;
			db = sum(del, 2) * rate;
			for l = L:-1:2
				del = b.delta(del, ffn.weights{l}, a{l});
				if(b.lam > 0)
					ffn.weights{l} = ffn.weights{l}*reg;
				end
				ffn.weights{l} = ffn.weights{l} - dw;
				ffn.biases{l} = ffn.biases{l} - db;
				dw = del * a{l-1}.' * rate;
				db = sum(del, 2) * rate;
			end
			if(b.lam > 0)
				ffn.weights{1} = ffn.weights{1}*reg;
			end
			ffn.weights{1} = ffn.weights{1} - dw;
			ffn.biases{1} = ffn.biases{1} - db;
		end
	end

	methods (Static)
		function out = trainComb(nets, len, a, y, rate, batch, all, inter)
			del = y;
			out = y;
			posdel = 0;
			posout = 0;
			netnum = numel(nets{end});
			for j = 1:netnum
				% This path should be valid in all
				% nets of the combgroup 'backprop'
				del(posdel+1:posdel+nets{end}{j}.out,:) = ...
					nets{end}{j}.options.af.options.training.options. ...
					cost.deltaL(y(posdel+1:posdel+nets{end}{j}.out,:), ...
					a{end}{j}{end});
				posdel = posdel+nets{end}{j}.out;
				out(posout+1:posout+nets{end}{j}.out,:) = a{end}{j}{end};
			end

			for i = len:-1:2
				ndel = nets{i};
				posdel = 0;
				for j = 1:netnum
					b = nets{i}{j}.options.af.options.training;
					ndel{j} = b.adjust(nets{i}{j},a{i}{j},...
						del(posdel+1:posdel+nets{i}{j}.out,:), ...
						rate,batch,all);
					posdel = posdel+nets{i}{j}.out;
					ndel{j} = b.delta(ndel{j}, nets{i}{j}.weights{1}, ...
						a{i}{j}{1});
				end
				del = inter{i-1};
				posdel = 0;
				for j = 1:netnum
					del(posdel+1:posdel+nets{i}{j}.in,:) = ndel{j};
					posdel = posdel+nets{i}{j}.in;
				end
				netnum = numel(nets{i-1});
			end

			posdel = 0;
			for j = 1:netnum
				nets{1}{j}.options.af.options.training.adjust( ...
					nets{1}{j},a{1}{j}, del(posdel+1: ...
					posdel+nets{1}{j}.out,:),rate,batch,all);
				posdel = posdel+nets{1}{j}.out;
			end
		end
	end
end
