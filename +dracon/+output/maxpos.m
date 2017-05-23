classdef maxpos < dracon.output
	%MAXPOS Summary of this class goes here
	%   Detailed explanation goes here
	
	properties (Hidden, Constant, Transient)
		INIT		= {{'Subtract', 'Z', ...
					'Integer value to be substracted from the position.'}};
		
		NAME		= 'Max Position';
		DESC		= 'Displays the position of the highest value.';
		
		EXT			= {'*.mat', 'MAT-file'; '*.txt', 'Text file'};
		PARAM		= {{}, {'-ascii', '-double'}};
	end
	
	properties (Hidden)
		sub = 0;
	end
	
	methods
		function m = maxpos(drcn, sub)
			m.drcn = drcn;
			m.sub = sub;
			m.name = 'Max Position';
		end
		
		function refresh(m)
			m.data = m.drcn.getLastOutput();
			
			if(isempty(m.data))
				m.dataSize = 0;
				m.dataNum = 0;
				m.text = '';
				return
			end
			
			[~, m.data] = max(m.data, [], 1);
			m.data = m.data - m.sub;
			
			m.dataSize = 1;
			m.dataNum = size(m.data, 2);
			
			m.text = cell(m.dataNum, 1);
			for k = 1:m.dataNum
				m.text{k, 1} = sprintf('%d | %d', k, m.data(k));
			end
		end
		
		function select(~, ~, ~)
		end
		
		function deselect(~, ~, ~)
		end
	end
end

