classdef layer < dracon.gui.view.network.selectable
    %LAYER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Constant, Transient)
        % Width of a layer
        WIDTH = dracon.gui.view.network.layer.MARGL + ...
                dracon.gui.view.network.node.SIZE(2) + ...
                dracon.gui.view.network.layer.MARGR;
        % Vertical distance from one node to the next
        VDIST = dracon.gui.view.network.node.SIZE(1) + ...
                dracon.gui.view.network.layer.NODMARGV;
	end
	
	properties (Constant, Transient, Hidden)
		width = dracon.gui.view.network.layer.WIDTH;
	end
    
    properties (Dependent, SetAccess = immutable)
        lp;
        
        height;
        numNodes;
        
        nodeXL;
        nodeXR;
        nodeYC;
    end
    
    properties (SetAccess = private)
        px;
        py;
    end
    
    properties (Hidden, Constant, Transient)
        % Node options        
        MARGT		= 8;			% Margin to layer, top
        MARGB		= 8;			% Margin to layer, bottom
        MARGL		= 8;			% Margin to layer, left
        MARGR		= 8;			% Margin to layer, right
        NODMARGV	= 8;			% Margin to other nodes, vertical
        
        % Layer options
        FACECO		= 'none';		% Face colour
        BORDERW		= .1;			% Border width
        BORDERCO	= [.7 .7 .7];	% Border colour
        BORDERS		= '-';			% Border style
        BORDERCU	= [0. 0.];		% Border curvature
		
        FACEINCO	= 'none';		% Face colour (input layer)
        BORDERINW	= .1;			% Border width (input layer)
        BORDERINCO	= [.8 .8 .8];	% Border colour (input layer)
        BORDERINS	= '-';			% Border style (input layer)
		
        BORDERSELW	= 1.5;			% Border width when selected
        BORDERSELCO	= [.3 .3 1];	% Border colour when selected
        BORDERSELS	= '-';			% Border style when selected
        FACESELCO	= [.92 .92 1.];	% Face colour when selected
		
        FACEOLCO	= 'none';		% Face colour of outline
        BORDEROLW	= 1.5;			% Border width of outline
        BORDEROLCO	= [.3 .3 1];	% Border colour of outline
        BORDEROLS	= ':';			% Border style of outline
		
		CLICKABLE	= 'visible';	% Clickable parts. all, visible or none
    end
    
    properties (Hidden)
        net;
        rect;
        
        nodes;
    end
    
    methods
        function l = layer(net, x, y, nn)
            import dracon.gui.view.network.node
            import dracon.util.netdata
            l.net = net;
            l.px = x;
            l.py = y;
            
            l.nodes = node.empty();
            y = y + l.MARGT;
            x = x + l.MARGL;
            
            for k = 1:nn
                n = node(l, x, y);
                l.nodes(k) = n;
                y = y + node.SIZE(2) + l.NODMARGV;
                
                data = netdata(netdata.ADDNODES);
                data.net = n;
                l.net.v.notifyNodes = [l.net.v.notifyNodes, data];
            end
            
            l.rect = net.v.dp.rect([l.px, l.py, l.width, l.height], ...
                                   'LineWidth', l.BORDERW, ...
                                   'LineStyle', l.BORDERS, ...
                                   'EdgeColor', l.BORDERCO, ...
                                   'Curvature', l.BORDERCU, ...
                                   'FaceColor', l.FACECO, ...
                                   'PickableParts', l.CLICKABLE);
            uistack(l.rect, 'bottom');
            uistack(l.net.rect, 'bottom');
                           
            l.rect.UIContextMenu = net.v.cMenuLayers;
            
            l.rect.ButtonDownFcn = @(~,~)l.net.v.onLayerClick(l);
        end
        
        function addNodes(l, nn)
            import dracon.gui.view.network.node
            import dracon.util.netdata
                
            nx = l.px + l.MARGL;
            ny = l.py + l.MARGT + l.numNodes * (node.SIZE(2) + l.NODMARGV);
            
			in = (l.lp == 1);
            for k = 1:nn
                n = node(l, nx, ny);
                l.nodes = [l.nodes, n];
                ny = ny + node.SIZE(2) + l.NODMARGV;
            
                data = netdata(netdata.ADDNODES);
                data.net = n;
                l.net.v.notifyNodes = [l.net.v.notifyNodes, data];
				if(in)
					n.resetStyle();
					n.resetColor();
				end
            end
            l.net.v.dp.rectResize(l.rect, [l.width, l.height]);
		end
		
		function nodesAdded(l, np, nn)
			h = (l.nodes(1).SIZE(2) + l.NODMARGV) * nn;
			for k = np+nn:l.numNodes
				l.nodes(k).move(0, h);
			end
            l.net.v.dp.rectResize(l.rect, [l.width, l.height]);
		end
        
        function rmNode(l, np)
            delete(l.nodes(np));
            l.nodes = [l.nodes(1:np-1), l.nodes(np+1:end)];
			l.nodesRemoved(np, 1);
		end
		
		function nodesRemoved(l, np, nn)
			h = -(dracon.gui.view.network.node.height + ...
					l.NODMARGV) * nn;
            for k = np:l.numNodes
                l.nodes(k).move(0, h);
            end
            l.net.v.dp.rectResize(l.rect, [l.width, l.height]);
		end
        
        function move(l, dx, dy)
            l.px = l.px + dx;
            l.py = l.py + dy;
            for k = 1:l.numNodes
                l.nodes(k).move(dx, dy);
            end
            l.net.v.dp.rectMove(l.rect, [dx, dy]);
        end
        
        function moveTo(l, x, y)
            l.px = x;
            l.py = y;
            l.move(x - l.px, y - l.py);
        end
        
        function h = get.height(l)
            import dracon.gui.view.network.node;
            n = l.numNodes;
            h = l.MARGT + n * node.SIZE(2) + ...
                (n - 1) * l.NODMARGV + l.MARGB;
        end
        
        function lp = get.lp(l)
            lp = find(l.net.layers == l);
        end
        
        function n = get.numNodes(l)
            n = length(l.nodes);
        end
        
        function nl = get.nodeXL(l)
            nl = l.px + l.MARGL;
        end
        
        function nr = get.nodeXR(l)
            nr = l.nodeXL + dracon.gui.view.network.node.SIZE(2);
        end
        
        function nc = get.nodeYC(l)
            nc = l.py + l.MARGT + dracon.gui.view.network.node.SIZE(1)/2;
        end
        
        function select(l, sel)
            if(sel == 0)
                l.selected = 0;
				l.resetStyle();
            else
                l.selected = 1;
                l.rect.FaceColor = l.FACESELCO;
                l.rect.EdgeColor = l.BORDERSELCO;
                l.rect.LineWidth = l.BORDERSELW;
                l.rect.LineStyle = l.BORDERSELS;
            end
		end
		
		function resetStyle(l)
			if(l.lp == 1)
                l.rect.FaceColor = l.FACEINCO;
                l.rect.EdgeColor = l.BORDERINCO;
                l.rect.LineWidth = l.BORDERINW;
                l.rect.LineStyle = l.BORDERINS;
			else
                l.rect.FaceColor = l.FACECO;
                l.rect.EdgeColor = l.BORDERCO;
                l.rect.LineWidth = l.BORDERW;
                l.rect.LineStyle = l.BORDERS;
			end
		end
		
		function ol = getOutline(l, hg)
			if(nargin < 2)
				hg = l.rect.Parent;
			end
			ol = copyobj(l.rect, hg);
			ol.FaceColor = l.FACEOLCO;
			ol.EdgeColor = l.BORDEROLCO;
			ol.LineStyle = l.BORDEROLS;
			ol.LineWidth = l.BORDEROLW;
		end
        
        function delete(l)
            if(l.selected && l.net.v.isvalid())
				list = l.net.v.getList(1);
				l.net.v.(list) = l.net.v.(list)(l.net.v.(list) ~= l);
            end
            delete(l.nodes);
            delete(l.rect);
        end
    end
    
end

