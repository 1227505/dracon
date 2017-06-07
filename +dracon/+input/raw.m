classdef raw < dracon.input
	%RAW Summary of this class goes here
	%   Detailed explanation goes here
	
	properties (Hidden, Constant, Transient)
		INIT = {{'Expression', 'S', 'Enter base workspace expression.'}};
		
		NAME = 'Base Workspace (Raw)';
		DESC = 'Select data from base workspace expression unchanged.';
		
		MAX_SIZE = 6;
		FORMAT = '%.3g; ';
	end
	
	methods
		function r = raw(var)
			r.data = evalin('base', var);
			
			r.dataSize = size(r.data, 1);
			r.dataNum = size(r.data, 2);
			
			r.text = cell(r.dataNum, 1);
			if(r.dataSize > r.MAX_SIZE)
				v = num2str(r.data(1:r.MAX_SIZE,:).', r.FORMAT);
				for k = 1:r.dataNum
					r.text{k,1} = sprintf(['%d (%s) | ', ...
										'[%s ...] (Length %d)'],...
										k, var, v(k, :), r.dataSize);
				end
			else
				v = num2str(r.data.', r.FORMAT);
				for k = 1:r.dataNum
					r.text{k,1} = sprintf(['%d (%s) | ', ...
										'[%s] (Length %d)'],...
										k, var, v(k, :), r.dataSize);
				end
			end
			
			r.source = ['Base Workspace Expression: ', var];
		end
		
		function select(r, pan, which)
			u = uicontrol(pan, 'Style', 'text');
			u.String = sprintf('%g\n', r.data(:, which));
			u.Position(1:2) = 1;
			u.Position(3:4) = u.Extent(3:4);
			pan.Position(3:4) = u.Extent(3:4);
		end
		
		function deselect(~, pan, ~)
			delete(pan.Children);
		end
	end
end

