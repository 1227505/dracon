classdef (Abstract) input < handle
	%INPUT Summary of this class goes here
	%   Detailed explanation goes here
	
	properties (SetAccess = protected)
		dataNum;
		dataSize;
		source;
	end
	
	properties (SetAccess = protected, Hidden)
		data = [];
		text = [];
	end
	
	properties (Abstract, Hidden, Transient, Constant)
		INIT;
		NAME;
		DESC;
	end
	
	methods (Abstract)
		select(i, pan, which);
		deselect(i, pan, which);
	end
	
    methods
		function data = getData(i, which)
			if(nargin < 2)
				data = i.data;
			else
				data = i.data(:, which);
			end
		end
		
		function text = getText(i, which)
			if(nargin < 2)
				text = i.text;
			else
				text = i.text(:, which);
			end
		end
	end
end

