classdef (Abstract) output < handle
	%OUTPUT Summary of this class goes here
	%   Detailed explanation goes here
	
	properties (SetAccess = protected)
		dataNum;
		dataSize;
		name;
	end
	
	properties (Hidden)
		lastPath = '';
	end
	
	properties (SetAccess = protected, Hidden)
		text = [];
		data = [];
		drcn;
	end
	
	properties (Abstract, Hidden, Transient, Constant)
		INIT;
		NAME;
		DESC;
	end
	
	methods (Abstract)
		select(o, pan, which);
		deselect(o, pan, which);
		refresh(o);
	end
	
    methods		
		function data = getData(o, which)
			if(nargin < 2)
				data = o.data;
			else
				data = o.data(:, which);
			end
		end
		
		function text = getText(o, which)
			if(nargin < 2)
				text = o.text;
			else
				text = o.text(which);
			end
		end
		
		function saveToFile(r, which) %#ok<INUSD>
			[file, path, in] = uiputfile(r.EXT, '', r.lastPath);
			if(path == 0)
				return;
			end
			r.lastPath = path;
			[~, vname] = fileparts(file);
			vname = matlab.lang.makeValidName(vname, 'Prefix', 'var_');
			eval([vname, '= r.data(:, which);']);
			save([path, file], vname, r.PARAM{in}{:});
		end
	end
end

