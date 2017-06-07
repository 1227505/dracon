classdef (Abstract) view < handle
    %VIEW Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Abstract, Constant)
        NAME;			% Name displayed in menu
        DEFAULT_SHOW;	% Shown when dracon is started ('on' or 'off')
		POSITION;		% Position in menu. Lower values are higher up.
						% Network has -1.
		SHORTKEY;		% Keyboard shortcut in the menu. Set '' if unused.
    end
    
    properties
        fig;			% Figure of the view
		drcn;			% Instance of dracon
	end
	
	methods
		function v = view(drcn)
			v.drcn = drcn;
		end
		
		function focus(v)
			figure(v.fig);
		end
		
		function setName(v, fname)
			v.fig.Name = [v.NAME, ' - ', fname];
		end
	end
    
    methods (Abstract, Static)
        pos = getDefaultPos();
    end
end

