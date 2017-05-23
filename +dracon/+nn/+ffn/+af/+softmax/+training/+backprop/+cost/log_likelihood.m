classdef log_likelihood < dracon.nn.ffn.af.softmax.training.backprop.cost
	%Log-Likelihood Summary of this class goes here
	%   Detailed explanation goes here

	properties (Constant, Transient)
		NAME	= 'Log-Likelihood';
		DESC	= 'TODO';
		DEFAULT = 1;
		INIT	= [];

		MAX		= log(realmax('double'));
	end

	methods
		function cl = clone(~)
			cl = dracon.nn.ffn.af.softmax.training.backprop.cost. ...
														log_likelihood();
		end 
	end

	methods (Static)
		function out = err(y, a)
			la = log(a);
			la(a <= 0) = -dracon.nn.ffn.af.softmax.training.backprop. ...
						cost.log_likelihood.MAX;
			out = sum(-y .* la);
		end

		function out = deltaL(y,a)
		   out = a - y;
		end
	end
end

