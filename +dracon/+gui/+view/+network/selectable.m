classdef (Abstract) selectable < handle
    %SELECTABLE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Hidden)
        selected = 0;
		
		inSRectArea = 0;
    end
    
    methods (Abstract)
        select(s, sel);
		
		ol = getOutline(s, hg);
    end
end

