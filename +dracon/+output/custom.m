classdef custom < dracon.output
	%CUSTOM Summary of this class goes here
	%   Detailed explanation goes here
	
	properties (Hidden, Constant, Transient)
		INIT		= {{'Function', 'S', ...
						'Enter a function or function handle'}};
		
		NAME		= 'Custom Function';
		DESC		= 'Any simple function.';
		
		MAX_SIZE	= 6;
		FORMAT		= '%.3g; ';
		
		ERR_DLG_TITLE	= 'Custom Function ERROR';
		
		EXT			= {'*.mat', 'MAT-file'; '*.txt', 'Text file'};
		PARAM		= {{}, {'-ascii', '-double'}};
	end
	
	properties (Hidden)
		fcn;
	end
	
	methods
		function c = custom(drcn, fcn)
			c.drcn = drcn;
			c.name = [c.NAME, ': ', fcn];
			c.fcn = str2func(fcn);
		end
		
		function refresh(c)
			c.data = c.drcn.getLastOutput();
			
			try
				c.data = c.fcn(c.data);
			catch ex
				c.drcn.error('', c.ERR_DLG_TITLE, ex.message);
				c.data = [];
			end
			
			if(isempty(c.data))
				c.dataSize = 0;
				c.dataNum = 0;
				c.text = '';
				return
			end
			
			c.dataSize = size(c.data, 1);
			c.dataNum = size(c.data, 2);
			
			c.text = cell(c.dataNum, 1);
			if(c.dataSize > c.MAX_SIZE)
				v = num2str(c.data(1:c.MAX_SIZE,:).', c.FORMAT);
				for k = 1:c.dataNum
					c.text{k,1} = sprintf('%d | [%s ...]', ...
										k, v(k, :));
				end
			else
				v = num2str(c.data.', c.FORMAT);
				for k = 1:c.dataNum
					c.text{k,1} = sprintf('%d | [%s]', k, v(k, :));
				end
			end
		end
		
		function select(c, pan, which)
			u = uicontrol(pan, 'Style', 'text');
			u.String = sprintf('%g\n', c.data(:, which));
			u.Position(1:2) = 1;
			u.Position(3:4) = u.Extent(3:4);
			pan.Position(3:4) = u.Extent(3:4);
		end
		
		function deselect(~, pan, ~)
			delete(pan.Children);
		end
	end
end

