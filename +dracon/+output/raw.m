classdef raw < dracon.output
	%RAW Summary of this class goes here
	%   Detailed explanation goes here
	
	properties (Hidden, Constant, Transient)
		INIT		= {};
		
		NAME		= 'Raw';
		DESC		= 'Displays and saves data unchanged.';
		
		MAX_SIZE	= 6;
		FORMAT		= '%.3g; ';
		
		EXT			= {'*.mat', 'MAT-file'; '*.txt', 'Text file'};
		PARAM		= {{}, {'-ascii', '-double'}};
	end
	
	methods
		function r = raw(drcn)
			r.drcn = drcn;
		end
		
		function refresh(r)
			r.data = r.drcn.getLastOutput();
			
			if(isempty(r.data))
				r.dataSize = 0;
				r.dataNum = 0;
				r.text = '';
				r.name = 'Raw data (Empty)';
				return
			end
			
			r.dataSize = size(r.data, 1);
			r.dataNum = size(r.data, 2);
			
			r.text = cell(r.dataNum, 1);
			if(r.dataSize > r.MAX_SIZE)
				v = num2str(r.data(1:r.MAX_SIZE,:).', r.FORMAT);
				for k = 1:r.dataNum
					r.text{k,1} = sprintf('%d | [%s ...]', ...
										k, v(k, :));
				end
			else
				v = num2str(r.data.', r.FORMAT);
				for k = 1:r.dataNum
					r.text{k,1} = sprintf('%d | [%s]', k, v(k, :));
				end
			end
			
			r.name = sprintf('Raw data (Length %d)', r.dataSize);
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

