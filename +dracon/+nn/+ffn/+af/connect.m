classdef connect < dracon.nn.ffn.af
    %CONNECT Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant, Transient)
        NAME = 'Connection';
        DESC = 'As the linear function, but doesn''t change when trained.';
        DEFAULT = 0;
        INIT = [];
    end
    
    properties (Dependent)
        combgroup;
	end
    
    methods
        function c = connect()
            c@dracon.nn.ffn.af({});
            c.options.training = c;
            c.options.cost = c;
        end
        
        function out = train(~, ~, a, ~, ~, ~, ~)
            out = a{end};
        end
        
        function out = err(~,~,~,~)
            out = 0;
        end
        
        function del = adjust(c,ffn,a,del,~,~,~)
            for l = numel(ffn.biases):-1:2
                del = c.delta(del, ffn.weights{l}, a{l});
            end
        end
        
        function cl = clone(~)
            cl = dracon.nn.ffn.af.connect();
            cl.options.training = cl;
            cl.options.cost = cl;
        end
    end
    
    methods (Static)
        function out = deltaL(~,a)
           out = a;
        end
        
        function out = delta(next, weights, ~)
            out = weights.' * next;
        end
    end
    
    methods (Static)
        function a = run(ffn, x, num)
            a = ffn.biases;
            a{1} = ffn.weights{1}*x + repmat(ffn.biases{1},1,num);
            for i = 2:ffn.layers
                a{i} = ffn.weights{i}*a{i-1}+repmat(ffn.biases{i},1,num);
            end
            a = [{x}, a];
		end
		
        function a = getInfluence(ffn, x, nod)
            a = ffn.biases;
			pos = ~isnan(nod{1});
			x(pos) = nod{1}(pos);
            a{1} = ffn.weights{1}*x + ffn.biases{1};
			pos = ~isnan(nod{2});
			a{1}(pos) = nod{2}(pos);
            for k = 2:ffn.layers
                a{k} = ffn.weights{k}*a{k-1}+ffn.biases{k};
				pos = ~isnan(nod{k+1});
				a{k}(pos) = nod{k+1}(pos);
            end
            a = [{x}, a];
        end
        
        function out = runSimple(ffn, x, num)
            out = ffn.weights{1}*x + repmat(ffn.biases{1},1,num);
            for i = 2:size(ffn.weights,2)
                out = ffn.weights{i}*out+repmat(ffn.biases{i},1,num);
            end
		end
        
        function out = trainComb(nets, len, a, y, rate, batch, all, inter)
            out = dracon.nn.ffn.af.logistic.training.backprop.trainComb...
                (nets,len,a,y,rate,batch,all,inter);
        end
		
		function code = getCode(~, ~)
			code = '';
		end
    end
end

