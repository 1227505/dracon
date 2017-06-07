classdef node < dracon.gui.view.network.selectable
    %NODE Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant, Transient)
        SIZE    = [15 15];   % Node size
	end
	
	properties (Constant, Transient, Hidden)
		width	= dracon.gui.view.network.node.SIZE(1);
		height	= dracon.gui.view.network.node.SIZE(2);
	end
    
    properties (Dependent, SetAccess = immutable)
        np;
    end
    
    properties (SetAccess = private)
        px
        py
    end
    
    properties (Hidden, Constant, Transient)
        FACECO      = [.8 .8 .8];	% Face colour
        BORDERW     = .1;			% Border width
        BORDERCO    = [.8 .8 .8];	% Border colour
        BORDERS     = 'none';		% Border style
        BORDERCU    = [.3 .3];		% Border curvature
		
        BORDERSELW  = 1.5;			% Border width when selected
        BORDERSELCO = [.3 .3 1];	% Border colour when selected
        BORDERSELS  = '-';			% Border style when selected
		
        FACEINCO	= [1. 1. 1.];	% Face colour (input layer)
        BORDERINW	= .1;			% Border width (input layer)
        BORDERINCO	= [.5 .5 .5];	% Border colour (input layer)
        BORDERINS	= '-';			% Border style (input layer)
        BORDERINCU   = [.9 .9];		% Border curvature (input layer)
		
        FACEOLCO	= 'none';		% Face colour of outline
        BORDEROLW	= 1.5;			% Border width of outline
        BORDEROLCO	= [.3 .3 1.];	% Border colour of outline
        BORDEROLS	= ':';			% Border style of outline
    end
    
    properties (Hidden)
        layer;
        rect;
    end
    
    methods
        function n = node(l, px, py)
            n.layer = l;
            n.px = px;
            n.py = py;
            n.rect = l.net.v.dp.rect([px, py, n.SIZE], ...
                                     'LineWidth', n.BORDERW, ...
                                     'LineStyle', n.BORDERS, ...
                                     'EdgeColor', n.BORDERCO, ...
                                     'Curvature', n.BORDERCU, ...
                                     'FaceColor', n.FACECO, ...
                                     'PickableParts', 'all');
                           
            n.rect.UIContextMenu = l.net.v.cMenuNodes;
            
            n.rect.ButtonDownFcn = @(~,~)n.layer.net.v.onNodeClick(n);
        end
        
        function move(n, dx, dy)
            n.px = n.px + dx;
            n.py = n.py + dy;
            n.layer.net.v.dp.rectMove(n.rect, [dx, dy]);
        end
        
        function select(n, sel)
            if(sel == 0)
                n.selected = 0;
                n.resetStyle();
            else
                n.selected = 1;
                n.rect.EdgeColor = n.BORDERSELCO;
                n.rect.LineWidth = n.BORDERSELW;
                n.rect.LineStyle = n.BORDERSELS;
            end
		end
		
		function setColor(n, col)
			n.rect.FaceColor = col;
		end
		
		function resetColor(n)
			if(n.layer.lp == 1)
				n.rect.FaceColor = n.FACEINCO;
			else
				n.rect.FaceColor = n.FACECO;
			end
		end
		
		function resetStyle(n)
			if(n.layer.lp == 1)
                n.rect.EdgeColor = n.BORDERINCO;
                n.rect.LineWidth = n.BORDERINW;
                n.rect.LineStyle = n.BORDERINS;
				n.rect.Curvature = n.BORDERINCU;
			else
                n.rect.EdgeColor = n.BORDERCO;
                n.rect.LineWidth = n.BORDERW;
                n.rect.LineStyle = n.BORDERS;
				n.rect.Curvature = n.BORDERCU;
			end
		end
        
        function np = get.np(n)
            np = find(n.layer.nodes == n);
        end
		
		function ol = getOutline(n, hg)
			if(nargin < 2)
				hg = n.rect.Parent;
			end
			ol = copyobj(n.rect, hg);
			ol.FaceColor = n.FACEOLCO;
			ol.EdgeColor = n.BORDEROLCO;
			ol.LineStyle = n.BORDEROLS;
			ol.LineWidth = n.BORDEROLW;
		end
        
        function delete(n)
            if(n.selected && n.layer.net.v.isvalid())
				v = n.layer.net.v;
				list = v.getList(2);
				v.(list) = v.(list)(v.(list) ~= n);
            end
            delete(n.rect);
        end
    end
    
end

