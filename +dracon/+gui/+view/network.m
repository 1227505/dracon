classdef network < dracon.gui.view
	%network Summary of this class goes here
	%   Detailed explanation goes here

	properties (Constant, Transient)
		NAME = 'Network';
	end

	events
		% Notified when a new/layer/node is drawn respectively.
		% If multi edit mode is on, the events will be notified when it's
		% deactivated.
		% All three use net data (dracon.util.netdata)
		NetDrawn;
		LayerDrawn;
		NodeDrawn;
	end
    
    properties (Constant, Hidden, Transient)
        DEFAULT_SHOW = 'on';
		SHORTKEY = '';
		POSITION = -1;

		% Contextmenu texts
		CMENU_INPUT_LAYER			=	'Input Layer';
		CMENU_AXES_ADD_NET			=	'New Network';
		
		CMENU_ADD					=	'Add...';
		
		CMENU_ADD_NET				=	'New Network below <NETNAME>';
		CMENU_ADD_LAYERS			=	['Layers after ', ...
										'<LAYERNAME> (<NETNAME>)'];
		CMENU_ADD_NODES				=	['Nodes to ', ...
										'<LAYERNAME> (<NETNAME>)'];
		
		CMENU_SELECTION				=	'Selection';
		CMENU_SELECT				=	'Select...';

		CMENU_SELECT_NETS			=	'All Nets';
		CMENU_SELECT_LAYERS			=	'All Layers';
		CMENU_SELECT_NODES			=	'All Nodes';

		CMENU_SELECT_NET			=	'<NETNAME>';
		CMENU_SELECT_NET_LAYERS		=	'<NETNAME>''s Layers';
		CMENU_SELECT_NET_NODES		=	'<NETNAME>''s Nodes';

		CMENU_SELECT_LAYER			=	'<LAYERNAME> of <NETNAME>';
		CMENU_SELECT_LAYER_NODES	=	'<LAYERNAME>''s Nodes'; 

		CMENU_SELECT_NODE			=	['<NODENAME> in ', ...
										'<LAYERNAME> of <NETNAME>'];
									
		CMENU_DESELECT				=	'Deselect...';

		CMENU_DESELECT_NETS			=	'All Nets';
		CMENU_DESELECT_LAYERS		=	'All Layers';
		CMENU_DESELECT_NODES		=	'All Nodes';

		CMENU_DESELECT_NET			=	'<NETNAME>';
		CMENU_DESELECT_NET_LAYERS	=	'<NETNAME>''s Layers';
		CMENU_DESELECT_NET_NODES	=	'<NETNAME>''s Nodes';

		CMENU_DESELECT_LAYER		=	'<LAYERNAME> of <NETNAME>';
		CMENU_DESELECT_LAYER_NODES	=	'<LAYERNAME>''s Nodes'; 

		CMENU_DESELECT_NODE			=	['<NODENAME> in ', ...
										'<LAYERNAME> of <NETNAME>'];
        
		% Dialog default position
		DLG_MARGL	= 80;		% Margin to screen, left
		DLG_MARGR	= 80;		% Margin to screen, right
		DLG_MARGB	= 100;		% Margin to screen, bottom
		DLG_MARGT	= 50;		% Margin to screen, top

		% Net panel options        
		MARGT		= 10;		% Margin to dialog, top
		MARGB		= 10;		% Margin to dialog, bottom
		MARGL		= 10;		% Margin to dialog, left
		MARGR		= 10;		% Margin to dialog, right
		NETMARGH	= 0;		% Margin to other nets, horizontal
		NETMARGV	= 0;		% Margin to other nets, vertical
        
        % Types of selection
		SELECT_TYPE_NONE	= 0;
		SELECT_TYPE_NORMAL	= 1;
		SELECT_TYPE_CTRL	= 2;
		SELECT_TYPE_RIGHT	= -1;
		SELECT_TYPE_DRAG	= -2;
		
		% Distances from net/layer/node border required to detect gap
		DRAG_GAP_NETS	= -5;
		DRAG_GAP_LAYERS	= 0;
		DRAG_GAP_NODES	= 0;
		
		% Distance from net/layer/node border to indicator
		DRAG_IND_GAP_NETS	= 4;
		DRAG_IND_GAP_LAYERS	= 4;
		DRAG_IND_GAP_NODES	= 4;
		
		% Appearance of insert position indicator
		DRAG_IND_COLOR		= [0 0 1];
		DRAG_IND_WIDTH		= 2;
		DRAG_IND_STYLE		= '-';
		
		DRAG_IND_NET_MARG	= 2;
		DRAG_IND_LAY_MARG	= 8;
		DRAG_IND_NOD_MARG	= 8;
    end
    
    properties (Hidden)
		dp;						% DrawPanel
		nets;					% Nets on DrawPanel
		maxW;					% Width of broadest network per column
		ctrl = 0;				% Control currently pressed

		selectedNets	= [];	% Currently selected nets/layers/nodes
		selectedLayers	= [];
		selectedNodes	= [];

		selectElem;				% Last element clicked
		selectTier;				% 0/1/2 for net/layer/node
		selectType = ...		% Which button was clicked
			dracon.gui.view.network.SELECT_TYPE_NONE;
		selectPoint;			% Where on the axis the click happened
		selectNetOf;			% Net of the selected element
		selectNextLayer = 0;	% Next layer after the clicked point (Int)
		
		dragStart;				% Start position of drag
		dragOutline;			% Dragged outline when moving elements
		dragIndicator;			% Line to indicate possible insert points
		dragInsert		= [];	% Possible insert point

		notifyNets		= [];	% Net data of nets, layers and nodes
		notifyLayers	= [];	% to be notified, when multi edit is
		notifyNodes		= [];	% deactivated

		cMenuAxes;				% Context menu appearing when right
		cMenuNets;				% clicking on the background/nets/layers/
		cMenuLayers;			% nodes
		cMenuNodes;
    end
    
    methods
		function n = network(drcn)
			n@dracon.gui.view(drcn);
			n.fig = figure('integerhandle', 'off', ...
				'userdata', drcn, ...
				'dockcontrols', 'off', ...
				'visible', 'off', ...
				'closerequestfcn', @(~,~)dracon.gui.util.onclose(drcn));
			n.fig.Position(1) = -1000;
			n.drcn = drcn;
			n.dp = dracon.gui.util.drawpanel(n.fig);
			n.dp.setRSCallback(@n.onSRectMove);

			% Context menu for background clicks
			n.cMenuAxes = uicontextmenu(n.fig);
			n.dp.axes.UIContextMenu = n.cMenuAxes;
			% New Net
			uimenu(n.cMenuAxes, 'Label', n.CMENU_AXES_ADD_NET, ...
					  'Callback', @(~,~)n.cAxesAddNet());
			% Selection
			m1 = uimenu(n.cMenuAxes, 'Label', n.CMENU_SELECTION);
			
			% Select...
			m = uimenu(m1, 'Label', n.CMENU_SELECT);
			uimenu(m, 'Label', n.CMENU_SELECT_NODES, ...
					  'Accel', 'A', ...
					  'Callback', @(~,~)n.selectNodes());
			uimenu(m, 'Label', n.CMENU_SELECT_LAYERS, ...
					  'Callback', @(~,~)n.selectLayers());
			uimenu(m, 'Label', n.CMENU_SELECT_NETS, ...
					  'Callback', @(~,~)n.selectNets());

			% Deselect...
			m = uimenu(m1, 'Label', n.CMENU_DESELECT);
			
			uimenu(m, 'Label', n.CMENU_DESELECT_NODES, ...
					  'Callback', @(~,~)n.deselectNodes());
			uimenu(m, 'Label', n.CMENU_DESELECT_LAYERS, ...
					  'Callback', @(~,~)n.deselectLayers());
			uimenu(m, 'Label', n.CMENU_DESELECT_NETS, ...
					  'Callback', @(~,~)n.deselectNets());
			
			% Context menu for net clicks
			n.cMenuNets = uicontextmenu(n.fig);
			% Add...
			m = uimenu(n.cMenuNets, 'UserData', n.CMENU_ADD);
			uimenu(m, 'UserData', n.CMENU_ADD_NET, ...
					  'Callback', @(~,~)n.cAddNet());
			uimenu(m, 'UserData', n.CMENU_ADD_LAYERS, ...
					  'Callback', @(~,~)n.cAddLayers());
				  
			% Selection
			m1 = uimenu(n.cMenuNets, 'UserData', n.CMENU_SELECTION);
			
			% Select...
			m = uimenu(m1, 'UserData', n.CMENU_SELECT);
			uimenu(m, 'UserData', n.CMENU_SELECT_NET, ...
					  'Callback', @(~,~)n.selectCurrent());
			uimenu(m, 'UserData', n.CMENU_SELECT_NET_LAYERS, ...
					  'Callback', @(~,~)n.selectLayersFromNet());
			uimenu(m, 'UserData', n.CMENU_SELECT_NET_NODES, ...
					  'Callback', @(~,~)n.selectNodesFromNet());
			uimenu(m, 'UserData', n.CMENU_SELECT_NODES, ...
					  'Accel', 'A', ...
					  'Callback', @(~,~)n.selectNodes());
			uimenu(m, 'UserData', n.CMENU_SELECT_LAYERS, ...
					  'Callback', @(~,~)n.selectLayers());
			uimenu(m, 'UserData', n.CMENU_SELECT_NETS, ...
					  'Callback', @(~,~)n.selectNets());
				  
			% Deselect...
			m = uimenu(m1, 'UserData', n.CMENU_DESELECT);
			uimenu(m, 'UserData', n.CMENU_DESELECT_NET, ...
					  'Callback', @(~,~)n.deselectCurrent());
			uimenu(m, 'UserData', n.CMENU_DESELECT_NET_LAYERS, ...
					  'Callback', @(~,~)n.deselectLayersFromNet);
			uimenu(m, 'UserData', n.CMENU_DESELECT_NET_NODES, ...
					  'Callback', @(~,~)n.deselectNodesFromNet);
			uimenu(m, 'UserData', n.CMENU_DESELECT_NODES, ...
					  'Callback', @(~,~)n.deselectNodes());
			uimenu(m, 'UserData', n.CMENU_DESELECT_LAYERS, ...
					  'Callback', @(~,~)n.deselectLayers());
			uimenu(m, 'UserData', n.CMENU_DESELECT_NETS, ...
					  'Callback', @(~,~)n.deselectNets());

			% Context menu for layer clicks
			n.cMenuLayers = uicontextmenu(n.fig);
			% Add...
			m = uimenu(n.cMenuLayers, 'UserData', n.CMENU_ADD);
			uimenu(m, 'UserData', n.CMENU_ADD_NET, ...
					  'Callback', @(~,~)n.cAddNet());
			uimenu(m, 'UserData', n.CMENU_ADD_LAYERS, ...
					  'Callback', @(~,~)n.cAddLayers());
			uimenu(m, 'UserData', n.CMENU_ADD_NODES, ...
					  'Callback', @(~,~)n.cAddNodes());
			% Selectiom
			m1 = uimenu(n.cMenuLayers, 'UserData', n.CMENU_SELECTION);
			
			% Select...
			m = uimenu(m1, 'UserData', n.CMENU_SELECT);
			uimenu(m, 'UserData', n.CMENU_SELECT_NET, ...
					  'Callback', @(~,~)n.selectCurrentNet());
			uimenu(m, 'UserData', n.CMENU_SELECT_LAYER, ...
					  'Callback', @(~,~)n.selectCurrent());
			uimenu(m, 'UserData', n.CMENU_SELECT_LAYER_NODES, ...
					  'Callback', @(~,~)n.selectNodesFromLayer);
			uimenu(m, 'UserData', n.CMENU_SELECT_NET_LAYERS, ...
					  'Callback', @(~,~)n.selectLayersFromNet);
			uimenu(m, 'UserData', n.CMENU_SELECT_NET_NODES, ...
					  'Callback', @(~,~)n.selectNodesFromNet);
			uimenu(m, 'UserData', n.CMENU_SELECT_NODES, ...
					  'Accel', 'A', ...
					  'Callback', @(~,~)n.selectNodes());
			uimenu(m, 'UserData', n.CMENU_SELECT_LAYERS, ...
					  'Callback', @(~,~)n.selectLayers());
			uimenu(m, 'UserData', n.CMENU_SELECT_NETS, ...
					  'Callback', @(~,~)n.selectNets());
			
			% Deselect...
			m = uimenu(m1, 'UserData', n.CMENU_DESELECT);
			uimenu(m, 'UserData', n.CMENU_DESELECT_NET, ...
					  'Callback', @(~,~)n.deselectCurrentNet());
			uimenu(m, 'UserData', n.CMENU_DESELECT_LAYER, ...
					  'Callback', @(~,~)n.deselectCurrent());
			uimenu(m, 'UserData', n.CMENU_DESELECT_LAYER_NODES, ...
					  'Callback', @(~,~)n.deselectNodesFromLayer);
			uimenu(m, 'UserData', n.CMENU_DESELECT_NET_LAYERS, ...
					  'Callback', @(~,~)n.deselectLayersFromNet);
			uimenu(m, 'UserData', n.CMENU_DESELECT_NET_NODES, ...
					  'Callback', @(~,~)n.deselectNodesFromNet);
			uimenu(m, 'UserData', n.CMENU_DESELECT_NODES, ...
					  'Callback', @(~,~)n.deselectNodes());
			uimenu(m, 'UserData', n.CMENU_DESELECT_LAYERS, ...
					  'Callback', @(~,~)n.deselectLayers());
			uimenu(m, 'UserData', n.CMENU_DESELECT_NETS, ...
					  'Callback', @(~,~)n.deselectNets());

			% Context menu for node clicks
			n.cMenuNodes = uicontextmenu(n.fig);
			% Add...
			m = uimenu(n.cMenuNodes, 'UserData', n.CMENU_ADD);
			uimenu(m, 'UserData', n.CMENU_ADD_NET, ...
					  'Callback', @(~,~)n.cAddNet());
			uimenu(m, 'UserData', n.CMENU_ADD_LAYERS, ...
					  'Callback', @(~,~)n.cAddLayers());
			uimenu(m, 'UserData', n.CMENU_ADD_NODES, ...
					  'Callback', @(~,~)n.cAddNodes());
				  
			% Selection
			m1 = uimenu(n.cMenuNodes, 'UserData', n.CMENU_SELECTION);
			
			% Select
			m = uimenu(m1, 'UserData', n.CMENU_SELECT);
			uimenu(m, 'UserData', n.CMENU_SELECT_NET, ...
					  'Callback', @(~,~)n.selectCurrentNet());
			uimenu(m, 'UserData', n.CMENU_SELECT_LAYER, ...
					  'Callback', @(~,~)n.selectCurrentLayer());
			uimenu(m, 'UserData', n.CMENU_SELECT_NODE, ...
					  'Callback', @(~,~)n.selectCurrent());
			uimenu(m, 'UserData', n.CMENU_SELECT_LAYER_NODES, ...
					  'Callback', @(~,~)n.selectNodesFromLayer);
			uimenu(m, 'UserData', n.CMENU_SELECT_NET_LAYERS, ...
					  'Callback', @(~,~)n.selectLayersFromNet);
			uimenu(m, 'UserData', n.CMENU_SELECT_NET_NODES, ...
					  'Callback', @(~,~)n.selectNodesFromNet);
			uimenu(m, 'UserData', n.CMENU_SELECT_NODES, ...
					  'Accel', 'A', ...
					  'Callback', @(~,~)n.selectNodes());
			uimenu(m, 'UserData', n.CMENU_SELECT_LAYERS, ...
					  'Callback', @(~,~)n.selectLayers());
			uimenu(m, 'UserData', n.CMENU_SELECT_NETS, ...
					  'Callback', @(~,~)n.selectNets());
				  
			% Deselect...
			m = uimenu(m1, 'UserData', n.CMENU_DESELECT);
			uimenu(m, 'UserData', n.CMENU_DESELECT_NET, ...
					  'Callback', @(~,~)n.deselectCurrentNet());
			uimenu(m, 'UserData', n.CMENU_DESELECT_LAYER, ...
					  'Callback', @(~,~)n.deselectCurrentLayer());
			uimenu(m, 'UserData', n.CMENU_DESELECT_NODE, ...
					  'Callback', @(~,~)n.deselectCurrent());
			uimenu(m, 'UserData', n.CMENU_DESELECT_LAYER_NODES, ...
					  'Callback', @(~,~)n.deselectNodesFromLayer);
			uimenu(m, 'UserData', n.CMENU_DESELECT_NET_LAYERS, ...
					  'Callback', @(~,~)n.deselectLayersFromNet);
			uimenu(m, 'UserData', n.CMENU_DESELECT_NET_NODES, ...
					  'Callback', @(~,~)n.deselectNodesFromNet);
			uimenu(m, 'UserData', n.CMENU_DESELECT_NODES, ...
					  'Callback', @(~,~)n.deselectNodes());
			uimenu(m, 'UserData', n.CMENU_DESELECT_LAYERS, ...
					  'Callback', @(~,~)n.deselectLayers());
			uimenu(m, 'UserData', n.CMENU_DESELECT_NETS, ...
					  'Callback', @(~,~)n.deselectNets());

			m = uimenu(n.fig, 'Label', n.CMENU_SELECTION);
			m1 = uimenu(m, 'Label', n.CMENU_SELECT);
			uimenu(m1, 'Label', n.CMENU_SELECT_NODES, ...
					   'Accel', 'A', ...
					   'Callback', @(~,~)n.selectNodes());
			uimenu(m1, 'Label', n.CMENU_SELECT_LAYERS, ...
					   'Callback', @(~,~)n.selectLayers());
			uimenu(m1, 'Label', n.CMENU_SELECT_NETS, ...
					   'Callback', @(~,~)n.selectNets());
				   
			m1 = uimenu(m, 'Label', n.CMENU_DESELECT);
			uimenu(m1, 'Label', n.CMENU_DESELECT_NODES, ...
					   'Callback', @(~,~)n.deselectNodes());
			uimenu(m1, 'Label', n.CMENU_DESELECT_LAYERS, ...
					   'Callback', @(~,~)n.deselectLayers());
			uimenu(m1, 'Label', n.CMENU_DESELECT_NETS, ...
					   'Callback', @(~,~)n.deselectNets());

				  
			n.fig.WindowScrollWheelFcn = @(~,ev)n.dp.onScroll(ev);
			n.fig.WindowKeyPressFcn = @(~,ev)n.onKey(ev);
			n.fig.WindowButtonDownFcn = @(~,~)n.dp.onButtonDown(n.fig);
			n.fig.WindowButtonUpFcn = @(~,~)n.onRelease();
			n.fig.WindowButtonMotionFcn = @(~,~)n.onMove();

			n.dp.addlistener('AxesClicked', @(~,~)n.onAxesClick());
			drcn.addlistener('NetAdded', ...
				@(~,nd)n.addNet(nd.netX, nd.netY, nd.net));
			drcn.addlistener('LayersAdded', ...
				@(~,nd)n.addLayers(nd.netX, nd.netY, nd.layPos + 1, ...
								   nd.nodePos, nd.num));
			drcn.addlistener('NodesAdded', ...
				@(~,nd)n.addNodes(nd.netX, nd.netY, ...
								  nd.layPos + 1, nd.num));
							  
			drcn.addlistener('NetRemoved', @(~,nd)n.rmNet(nd.netX, nd.netY));
			drcn.addlistener('LayerRemoved', ...
				@(~,nd)n.rmLayer(nd.netX, nd.netY, nd.layPos + 1));
			drcn.addlistener('NodeRemoved', ...
				@(~,nd)n.rmNode(nd.netX, nd.netY, ...
								 nd.layPos + 1, nd.nodePos));
							 
			drcn.addlistener('NetMoved', ...
				@(~,nd)n.mvNet(nd.netX(1), nd.netY(1), ...
							nd.netX(2), nd.netY(2)));
			drcn.addlistener('LayersMoved', ...
				@(~,nd)n.mvLayers(nd.netX(1), nd.netY(1), ...
							nd.netX(2), nd.netY(2), ...
							nd.layPos(1), nd.layPos(2), nd.layPos(3)));
			drcn.addlistener('NodesMoved', ...
				@(~,nd)n.mvNodes(nd.netX(1), nd.netY(1), ...
							nd.netX(2), nd.netY(2), ...
							nd.layPos(1), nd.layPos(2), ...
							nd.nodePos(1), nd.nodePos(2), nd.nodePos(3)));

			drcn.addlistener('NetsOpened', @(~,~)n.refresh());
			drcn.addlistener('NetsReset', @(~,~)n.clear());

			drcn.addlistener('MultiEditEnded', @(~,~)n.notifyDrawn());
			
			drcn.addlistener('NetsChanged', @(~,~)n.sRectStop());
			drcn.addlistener('NetsChanged', @(~,~)n.dragStop());
			
			n.refresh();
		end
		
		function clear(v)
			v.dp.clear();
			
			v.nets = {};
			v.maxW = [];
			
			v.selectType = dracon.gui.view.network.SELECT_TYPE_NONE;
			v.selectedNets = [];
			v.selectedLayers = [];
			v.selectedNodes = [];
			
			v.notifyNets = [];
			v.notifyLayers = [];
			v.notifyNodes = [];
			
			v.dragOutline = [];
			v.dragIndicator = [];
		end

		function refresh(v)
			v.clear();
			for x = 1:length(v.drcn.nets)
				for y = 1:length(v.drcn.nets{x})
					v.addNet(x, y);
				end
			end
		end

		function addNet(v, x, y, net)
			if(y == 0)
				y = 1;
				new = 1;
			else
				new = 0;
			end
			if(y == 1)
				if(x == 1)
					px = v.MARGL;
				else
					px = v.nets{x-1}{1}.px + v.maxW(x-1) + v.NETMARGH;
				end
				py = v.MARGT;
			else
				p = v.nets{x}{y-1};
				px = p.px;
				py = p.py + p.height + v.NETMARGV;
			end

			n = dracon.gui.view.network.net(v, px, py);
			if(new)
				v.nets = [v.nets(1:x-1), {{n}}, v.nets(x:end)];
				v.maxW = [v.maxW(1:x-1), -v.NETMARGH, v.maxW(x:end)];
			elseif(length(v.nets) < x)
				v.nets{x} = {n};
			else
				v.nets{x} = [v.nets{x}(1:y-1), {n}, v.nets{x}(y:end)];
			end

			if(nargin < 4 || isempty(net))
				net = v.drcn.nets{x}{y};
			end
			n.addLayers(1, net.in, 1);
			for k = 1:net.layers
				n.addLayers(k+1, numel(net.biases{k}), 1);
			end
			l = n.layers(1);
			l.resetStyle();
			for k = 1:l.numNodes
				l.nodes(k).resetColor();
				l.nodes(k).resetStyle();
			end

			w = n.width;
			if(length(v.maxW) < x)
				v.maxW(x) = w;
			elseif(v.maxW(x) < w)
				v.adjustRows(x + 1, w - v.maxW(x));
				v.maxW(x) = w;
			end

			v.adjustCol(x, y + 1, n.height + v.NETMARGV);

			import dracon.util.netdata
			data = netdata(netdata.ADDNET);
			data.net = n;
			v.notifyNets = [v.notifyNets, data];

			if(~v.drcn.multiEdit)
				v.notifyDrawn();
			end
		end

		function rmNet(v, x, y)
			ow = v.nets{x}{y}.width;
			oh = v.nets{x}{y}.height;
			delete(v.nets{x}{y});
			v.netRemoved(x, y, ow, oh);
		end
		
		function mvNet(v, x, y, nx, ny)
			n = v.nets{x}{y};
			w = n.width;
			h = n.height;
			if(length(v.nets{x}) == 1)
				v.nets = [v.nets(1:x-1), v.nets(x+1:end)];
				v.maxW = [v.maxW(1:x-1), v.maxW(x+1:end)];
				v.adjustRows(x, -(w + v.NETMARGH));
				
				if(nx > x)
					nx = nx - 1;
				end
			else
				v.nets{x} = [v.nets{x}(1:y-1), v.nets{x}(y+1:end)];
				v.adjustCol(x, y, -(h + v.NETMARGV));
				if(v.maxW(x) == w)
					v.getMaxW(x);
					dx = v.maxW(x) - w;
					if(dx < 0)
						v.adjustRows(x + 1, dx);
					end
				end
				
				if(nx == x && ny > y)
					ny = ny - 1;
				end
			end
			
			if(ny == 0)
				if(nx == 1)
					px = v.MARGL;
				else
					px = v.nets{nx-1}{1}.px + v.maxW(nx-1) + v.NETMARGH;
				end
				py = v.MARGT;
				v.nets = [v.nets(1:nx-1), {{n}}, v.nets(nx:end)];
				v.maxW = [v.maxW(1:nx-1), -v.NETMARGH, v.maxW(nx:end)];
				ny = 1;
			else
				px = v.nets{nx}{1}.px;
				if(ny > length(v.nets{nx}))
					py = v.nets{nx}{ny-1}.py + ...
						v.nets{nx}{ny-1}.height + v.NETMARGV;
				else
					py = v.nets{nx}{ny}.py;
				end
				v.nets{nx} = [v.nets{nx}(1:ny-1), {n}, v.nets{nx}(ny:end)];
			end
			n.move(px - n.px, py - n.py);
			if(v.maxW(nx) < w)
				v.adjustRows(nx + 1, w - v.maxW(nx));
				v.maxW(nx) = w;
			end
			v.adjustCol(nx, ny + 1, n.height + v.NETMARGV);
		end

		function addLayers(v, x, y, lp, nn, nl)
			if(nargin < 4)
				nl = 1;
			end
			ow = v.nets{x}{y}.width;
			oh = v.nets{x}{y}.height;
			v.nets{x}{y}.addLayers(lp, nn, nl);
			v.netChanged(x, y, ow, oh);

			if(~v.drcn.multiEdit)
				v.notifyDrawn();
			end
		end

		function rmLayer(v, x, y, nl)
			ow = v.nets{x}{y}.width;
			oh = v.nets{x}{y}.height;
			if(v.nets{x}{y}.rmLayer(nl))
				v.netRemoved(x, y, ow, oh);
			else
				v.netChanged(x, y, ow, oh);
			end
		end
		
		function mvLayers(v, x, y, nx, ny, l, r, nlp)
			n = v.nets{x}{y};
			nn = v.nets{nx}{ny};
			
			l = l + 1;
			r = r + 1;
			nlp = nlp + 1;
			lnum = r - l + 1;
			
			if(x ~= nx || y ~= ny)
				ow = n.width;
				oh = n.height;
				now = nn.width;
				noh = nn.height;
			elseif(nlp >= l)
				nlp = nlp - lnum;
			end
			
			dpx = nn.layers(nlp).px - n.layers(l).px + ...
					n.layers(1).WIDTH + n.LAYMARGH;
			dpy = nn.layers(nlp).py - n.layers(l).py;
			for k = l:r
				n.layers(k).move(dpx, dpy);
				n.layers(k).net = nn;
			end
					
			lays = n.layers(l:r);
			n.layers = [n.layers(1:l-1), n.layers(r+1:end)];
			n.layersRemoved(l, lnum);
			
			nn.layers = [nn.layers(1:nlp), ...
						lays, ...
						nn.layers(nlp+1:end)];
			nn.layersAdded(nlp + 1, lnum);
			
			if(x ~= nx || y ~= ny)
				v.netChanged(x, y, ow, oh);
				v.netChanged(nx, ny, now, noh);
			end
		end

		function addNodes(v, x, y, nl, nn)
			ow = v.nets{x}{y}.width;
			oh = v.nets{x}{y}.height;
			v.nets{x}{y}.addNodes(nl, nn);
			v.netChanged(x, y, ow, oh);

			if(~v.drcn.multiEdit)
				v.notifyDrawn();
			end
		end

		function rmNode(v, x, y, nl, nn)
			ow = v.nets{x}{y}.width;
			oh = v.nets{x}{y}.height;
			if(v.nets{x}{y}.rmNode(nl, nn))
				v.netRemoved(x, y, ow, oh);
			else
				v.netChanged(x, y, ow, oh);
			end
		end
		
		function mvNodes(v, x, y, nx, ny, lp, nlp, t, b, nnp)
			n = v.nets{x}{y};
			nn = v.nets{nx}{ny};
			
			lp = lp + 1;
			nlp = nlp + 1;
			nnum = b - t + 1;
			
			l = n.layers(lp);
			nl = nn.layers(nlp);
			
			if(x ~= nx || y ~= ny || lp ~= nlp)
				ow = n.width;
				oh = n.height;
				now = nn.width;
				noh = nn.height;
			elseif(nnp >= t)
				nnp = nnp - nnum;
			end
			
			dpx = nl.px + nl.MARGL - l.nodes(1).px;
			if(nl.numNodes < nnp)
				if(nl.numNodes == 0)
					dpy = nl.py + nl.MARGT - l.nodes(t).py;
				else
					dpy = nl.nodes(nnp-1).py - l.nodes(t).py + l.VDIST;
				end
			else
				dpy = nl.nodes(nnp).py - l.nodes(t).py;
			end
			for k = t:b
				l.nodes(k).move(dpx, dpy);
				l.nodes(k).layer = nl;
			end
					
			nods = l.nodes(t:b);
			l.nodes = [l.nodes(1:t-1), l.nodes(b+1:end)];
			n.nodesRemoved(lp, t, nnum);
			
			nl.nodes = [nl.nodes(1:nnp-1), ...
						nods, ...
						nl.nodes(nnp:end)];
			nn.nodesAdded(nlp, nnp, nnum);
			
			if(x ~= nx || y ~= ny || lp ~= nlp)
				v.netChanged(x, y, ow, oh);
				v.netChanged(nx, ny, now, noh);
			end
		end

		function selectNode(v, n)
			v.select(n, 2);
		end

		function selectLayer(v, l)
			v.select(l, 1);
		end

		function selectNet(v, n)
			v.select(n, 0);
		end
		
		function selectNets(v)
			for x = 1:length(v.nets)
				for y = 1:length(v.nets{x})
					v.select(v.nets{x}{y}, 0);
				end
			end
		end	

		function selectLayers(v)
			for x = 1:length(v.nets)
				for y = 1:length(v.nets{x})
					v.selectLayersFromNet(v.nets{x}{y});
				end
			end
		end

		function selectNodes(v)
			for x = 1:length(v.nets)
				for y = 1:length(v.nets{x})
					v.selectNodesFromNet(v.nets{x}{y});
				end
			end
		end
		
		function deselectNode(v, n)
			v.deselect(n, 2);
		end

		function deselectLayer(v, l)
			v.deselect(l, 1);
		end

		function deselectNet(v, n)
			v.deselect(n, 0);
		end

		function deselectNodes(v)
			v.deselectGroup(2);
		end

		function deselectLayers(v)
			v.deselectGroup(1);
		end

		function deselectNets(v)
			v.deselectGroup(0);
		end
		
		function setZoomReset(v)
			lx = length(v.nets);
			if(lx < 1)
				v.dp.zoomReset = [0, 1];
			else
				w = v.nets{end}{1}.px + v.maxW(end) + v.MARGR - 2;
				w = w / v.fig.Position(3);
				h = 0;
				for x = 1:lx
					th = v.nets{x}{end}.py + v.nets{x}{end}.height;
					if(th > h)
						h = th;
					end
				end
				h = (h + v.MARGB - 2) / v.fig.Position(4);
				v.dp.zoomReset = [0, max(w, h)];
			end
		end
		
		function setNodeColor(v, x, y, lp, np, col)
			v.nets{x}{y}.layers(lp + 1).nodes(np).setColor(col);
		end
		
		function resetNodeColor(v, x, y, lp, np)
			v.nets{x}{y}.layers(lp + 1).nodes(np).resetColor();
		end
		
		function nod = getSelectedNodes(v)
			nod = v.drcn.nets;
			for x = 1:numel(v.drcn.nets)
				for y = 1:numel(v.drcn.nets{x})
					n = nod{x}{y};
					nod{x}{y} = cell(1, n.layers + 1);
					nod{x}{y}{1} = NaN(n.in, 1);
					for l = 1:n.layers
						nod{x}{y}{l+1} = NaN(numel(n.biases{l}), 1);
					end
				end
			end
			for k = 1:numel(v.selectedNodes)
				xy = v.selectedNodes(k).layer.net.xy;
				l = v.selectedNodes(k).layer.lp;
				n = v.selectedNodes(k).np;
				nod{xy(1)}{xy(2)}{l}(n) = 1;
			end
		end
    end
    
	methods (Hidden)
		function setName(v, fname)
			v.fig.Name = [v.drcn.NAME, ' ', v.drcn.VERSION, ' - ', fname];
		end
		
		function netChanged(v, x, y, ow, oh)
			v.adjustCol(x, y + 1, v.nets{x}{y}.height - oh);

			w = v.nets{x}{y}.width;

			if(w > v.maxW(x))
				v.adjustRows(x + 1, w - v.maxW(x));
				v.maxW(x) = w;
			elseif(ow == v.maxW(x))
				v.getMaxW(x);
				v.adjustRows(x + 1, v.maxW(x) - ow);
			end
		end

		function netRemoved(v, x, y, ow, oh)
			if(length(v.nets{x}) == 1)
				v.nets = [v.nets(1:x-1), v.nets(x+1:end)];
				v.maxW = [v.maxW(1:x-1), v.maxW(x+1:end)];
				v.adjustRows(x, -(ow + v.NETMARGH));
			else
				v.nets{x} = [v.nets{x}(1:y-1), v.nets{x}(y+1:end)];
				v.adjustCol(x, y, -(oh + v.NETMARGV));
				if(v.maxW(x) == ow)
					v.getMaxW(x);
					dx = v.maxW(x) - ow;
					if(dx < 0)
						v.adjustRows(x + 1, dx);
					end
				end
			end
		end

		function adjustCol(v, x, y, dy)
			if(dy ~= 0)
				for k = y:length(v.nets{x})
					v.nets{x}{k}.move(0, dy);
				end
			end
		end

		function adjustRows(v, x, dx)
			if(dx ~= 0)
				for k = x:length(v.nets)
					for y = 1:length(v.nets{k})
						v.nets{k}{y}.move(dx, 0);
					end
				end
			end
		end

		function getMaxW(v, x)
			v.maxW(x) = 0;
			for k = 1:length(v.nets{x})
				h = v.nets{x}{k}.width;
				if(h > v.maxW(x))
					v.maxW(x) = h;
				end
			end
		end

		function onAxesClick(v)
			v.onClick();
		end

		function onNodeClick(v, n)
			v.onClick(n, 2);
			v.selectNetOf = n.layer.net;
			v.selectNextLayer = n.layer.lp - 1;
			switch v.fig.SelectionType
				case 'alt'
					xy = v.selectNetOf.xy;
					if(v.selectNextLayer == 0)
						lp = '0';
						lpn = v.CMENU_INPUT_LAYER;
					else
						lp = num2str(v.selectNextLayer);
						lpn = ['Layer ', lp];
					end
					np = num2str(n.np);
					v.cMenuSetLabels(v.cMenuNodes, { ...
						'<NETNAME>', v.drcn.nets{xy(1)}{xy(2)}.name; ...
						'<NETX>', num2str(xy(1)); ...
						'<NETY>', num2str(xy(2)); ...
						'<LAYERNUM>', lp; ...
						'<LAYERNAME>', lpn; ...
						'<NODENUM>', np;
						'<NODENAME>', ['Node ', np];
						});
			end
		end

		function onLayerClick(v, l)
			v.onClick(l, 1);
			v.selectNetOf = l.net;
			v.selectNextLayer = l.lp - 1;
			switch v.fig.SelectionType
				case 'alt'
					xy = v.selectNetOf.xy;
					if(v.selectNextLayer == 0)
						lp = '0';
						lpn = v.CMENU_INPUT_LAYER;
					else
						lp = num2str(v.selectNextLayer);
						lpn = ['Layer ', lp];
					end
					v.cMenuSetLabels(v.cMenuLayers, { ...
						'<NETNAME>', v.drcn.nets{xy(1)}{xy(2)}.name; ...
						'<NETX>', num2str(xy(1)); ...
						'<NETY>', num2str(xy(2)); ...
						'<LAYERNAME>', lpn; ...
						'<LAYERNUM>', lp; ...
						});
			end
		end

		function onNetClick(v, n)
			v.selectNetOf = n;
			v.onClick(n, 0);
			switch v.fig.SelectionType
				case 'alt'
					xy = n.xy;
					v.selectNextLayer = n.getNextLayer(v.selectPoint(1));
					if(v.selectNextLayer > 0)
						v.selectNextLayer = v.selectNextLayer - 1;
					end
					if(v.selectNextLayer == 0)
						lp = '0';
						lpn = v.CMENU_INPUT_LAYER;
					else
						lp = num2str(v.selectNextLayer);
						lpn = ['Layer ', lp];
					end
					v.cMenuSetLabels(v.cMenuNets, { ...
						'<NETNAME>', v.drcn.nets{xy(1)}{xy(2)}.name; ...
						'<NETX>', num2str(xy(1)); ...
						'<NETY>', num2str(xy(2)); ...
						'<LAYERNAME>', lpn;
						'<LAYERNUM>', lp;
						});
			end
		end

		function onClick(v, el, tier)
			if(v.selectType ~= v.SELECT_TYPE_DRAG)

				v.selectType = v.SELECT_TYPE_NONE;
				v.selectPoint = v.dp.getMousePosition();

				switch v.fig.SelectionType
					case 'normal'
						v.selectType = v.SELECT_TYPE_NORMAL;

					case 'alt'
						if(ismember('control', v.fig.CurrentModifier))
							v.selectType = v.SELECT_TYPE_CTRL;
						else
							v.selectType = v.SELECT_TYPE_RIGHT;
						end
				end

				if(nargin > 1)
					v.selectElem = el;
					v.selectTier = tier;
					if(v.selectType == v.SELECT_TYPE_NORMAL)
						if(~el.selected)
							v.deselectNodes();
							v.deselectLayers();
							v.deselectNets();
							v.selectCurrent();
						end
					end
				else
					% Normal or ctrl
					if(v.selectType > v.SELECT_TYPE_NONE)
						v.sRectStart();
						if(v.selectType == v.SELECT_TYPE_NORMAL)
							v.deselectNodes();
							v.deselectLayers();
							v.deselectNets();
						end
					end
					v.selectElem = [];
					v.selectType = v.SELECT_TYPE_NONE;
				end

			end
		end

		function onRelease(v)
			v.dp.onButtonUp(v.fig);
			v.sRectStop();
			
			switch v.selectType
				case v.SELECT_TYPE_NORMAL
					v.deselectNodes();
					v.deselectLayers();
					v.deselectNets();
					v.selectCurrent();
					
				case v.SELECT_TYPE_CTRL
					if(v.selectElem.selected)
						v.deselectCurrent();
					else
						v.selectCurrent();
					end
					
				case v.SELECT_TYPE_DRAG
					v.dragStop(1);
			end
			v.selectType = v.SELECT_TYPE_NONE;
		end
			
		function onKey(v, ev)
			switch ev.Key
				case 'space'
					v.setZoomReset();
					
				case 'delete'        
					v.drcn.editMultiple(1);

					ne = v.selectedNets;
					for k = 1:length(ne)
						n = ne(k);
						xy = n.xy;
						v.drcn.rmNet(xy(1), xy(2));
					end

					la = v.selectedLayers;
					for k = 1:length(la)
						l = la(k);
						if(l.isvalid())
							xy = l.net.xy;
							v.drcn.rmLayer(xy(1), xy(2), l.lp-1)
						end
					end

					no = v.selectedNodes;
					for k = 1:length(no)
						n = no(k);
						if(n.isvalid())
							xy = n.layer.net.xy;
							v.drcn.rmNode(xy(1), xy(2), ...
											  n.layer.lp-1, n.np);
						end
					end

					v.drcn.editMultiple(0);
					
				case 'return'
					v.sRectStop();
			end

			v.dp.onKey(ev);
		end
		
		function onMove(v)
			v.dp.onMove();
			if(v.selectType > v.SELECT_TYPE_NONE && ...
					~(v.selectTier > 0 && v.selectNextLayer == 0))
				v.selectCurrent();
				v.selectType = v.SELECT_TYPE_DRAG;
				
				v.dragOutline = hgtransform('Parent', v.dp.axes);
				switch v.selectTier
					case 0
						for k = 1:length(v.selectedNets)
							 v.selectedNets(k).getOutline(v.dragOutline);
						end
						
					case 1
						for k = 1:length(v.selectedLayers)
							l = v.selectedLayers(k);
							if(l.lp > 1)
								l.getOutline(v.dragOutline);
							end
						end
						
					case 2
						for k = 1:length(v.selectedNodes)
							n = v.selectedNodes(k);
							if(n.layer.lp > 1)
								n.getOutline(v.dragOutline);
							end
						end
				end
				v.dragStart = v.dp.getMousePositionNorm();
				v.dragIndicator = v.dp.line([0 0], [0 0], ...
											'Visible', 'off', ...
											'Color', v.DRAG_IND_COLOR, ...
											'LineW', v.DRAG_IND_WIDTH, ...
											'LineS', v.DRAG_IND_STYLE);
			end
			
			if(v.selectType == v.SELECT_TYPE_DRAG)
				cp = v.dp.getMousePositionNorm();
				dm = cp - v.dragStart;
				
				v.dragOutline.Matrix = [1, 0, 0, dm(1); ...
										0, 1, 0, dm(2); ...
										0, 0, 1, 0; ...
										0, 0, 0, 1];
				
				cp = v.dp.pos2pixel(cp);
				
				if(v.selectTier == 0)
					lvis = 0;
					if(cp(1) <= v.MARGL - v.DRAG_GAP_NETS)
						px = v.MARGL - v.DRAG_IND_GAP_NETS;
						
						v.dp.lineSetLeft(v.dragIndicator, px, v.MARGT + ...
									v.DRAG_IND_NET_MARG);
						v.dp.lineSetRight(v.dragIndicator, px, ...
									v.MARGT + v.nets{1}{1}.height - ...
									v.DRAG_IND_NET_MARG);
						lvis = 1;
						x = 1;
						y = 0;
					else
						f = 0;
						for x = 2:length(v.nets)
							n = v.nets{x}{1};

							if(cp(1) <= n.px - v.DRAG_GAP_NETS)
								f = 1;
								break;
							end
						end

						if(f)
							x = x - 1;
							n = v.nets{x}{1};
						elseif(isempty(x))
							x = 1;
							n = v.nets{1}{1};
						end
						w = n.px + v.maxW(x);
						if(cp(1) >= w + v.DRAG_GAP_NETS)
							px = w + v.DRAG_IND_GAP_NETS;
							v.dp.lineSetLeft(v.dragIndicator, ...
										px, v.MARGT + v.DRAG_IND_NET_MARG);
							v.dp.lineSetRight(v.dragIndicator, px, ...
										n.height + v.MARGT - ...
										v.DRAG_IND_NET_MARG);
							lvis = 1;
							x = x + 1;
							y = 0;
						else
							if(cp(2) <= v.MARGT - v.DRAG_GAP_NETS)
								py = n.py - v.DRAG_IND_GAP_NETS;
								v.dp.lineSetLeft(v.dragIndicator, ...
										n.px +  v.DRAG_IND_NET_MARG, py);
								v.dp.lineSetRight(v.dragIndicator, ...
										w - v.DRAG_IND_NET_MARG, py);
								lvis = 1;
								y = 1;
							else
								f = 0;
								for y = 2:length(v.nets{x})
									n = v.nets{x}{y};
									if(cp(2) <= n.py - v.DRAG_GAP_NETS)
										f = 1;
										break;
									end
								end

								if(f)
									y = y - 1;
									n = v.nets{x}{y};
								elseif(isempty(y))
									y = 1;
								end
								h = n.py + n.height;
								if(cp(2) >= h + v.DRAG_GAP_NETS)
									py = h + v.DRAG_IND_GAP_NETS;
									v.dp.lineSetLeft( ...
										v.dragIndicator, ...
										n.px + v.DRAG_IND_NET_MARG, py);
									v.dp.lineSetRight(v.dragIndicator, ...
										n.px + n.width - ...
										v.DRAG_IND_NET_MARG, py);
									lvis = 1;
									y = y + 1;
								end
							end
						end
					end
					if(lvis)
						v.dragIndicator.Visible = 'on';
						v.dragInsert = [x, y];
					else
						v.dragIndicator.Visible = 'off';
						v.dragInsert = [];
					end
						
				else
					f = 0;
					if(length(v.dragInsert) >= 2)
						x = v.dragInsert(1);
						y = v.dragInsert(2);
						if(x > 0 && x <= length(v.nets) && ...
								y > 0 && y <= length(v.nets{x}))
							n = v.nets{x}{y};
							if(v.isInNet(cp, n))
								f = 1;
							end
						end
					end
					if(~f)
						for x = 1:length(v.nets)
							if(v.nets{x}{1}.px >= cp(1))
								f = 1;
								break;
							end
						end
						if(f)
							x = x - 1;
						end
						f = 0;
						if(x > 0)
							for y = 1:length(v.nets{x})
								if(v.nets{x}{y}.py >= cp(2))
									f = 1;
									break;
								end
							end
							if(f)
								y = y - 1;
							end
							f = 0;
							if(y > 0)
								n = v.nets{x}{y};
								if(n.py + n.height >= cp(2) && ...
										n.px + n.width >= cp(1))
									f = 1;
								end
							end
						else
							x = 0;
						end
					end

					v.dragInsert = [x, y];
					if(f)
						f = 0;
						w = n.layers(1).WIDTH;
						l = (cp(1) - n.px - n.MARGL + ...
							v.DRAG_GAP_LAYERS) / (w + n.LAYMARGH);
						
						if(~((l - floor(l))*(w + n.LAYMARGH) < ...
								w + 2 * v.DRAG_GAP_LAYERS))
							
							if(v.selectTier == 1 && l > 0)
								l = ceil(l);
								v.dragInsert(3) = l;
								px = n.layers(l).px + ...
									w + v.DRAG_IND_GAP_LAYERS;
								v.dp.lineSetLeft(v.dragIndicator, ...
										px, n.py + v.DRAG_IND_LAY_MARG);
								v.dp.lineSetRight(v.dragIndicator, ...
										px, n.py + n.height - ...
										v.DRAG_IND_LAY_MARG);
								v.dragIndicator.Visible = 'on';
								f = 1;
							end
						elseif(v.selectTier == 2 && l > 1)
							l = ceil(l);
							lay = n.layers(l);
							nh = lay.nodes(1).height;
							
							no = (cp(2) - lay.py - lay.MARGT + ...
								v.DRAG_GAP_NODES) / (nh + lay.NODMARGV);
							if(no <= length(lay.nodes) && ...
									~(((no - floor(no))) * ...
									(nh + lay.NODMARGV) < ...
									nh + 2 * v.DRAG_GAP_NODES))
								no = ceil(no);
								if(no)
									py = lay.nodes(no).py + ...
										nh + v.DRAG_IND_GAP_NODES;
								else
									py = lay.py + v.DRAG_IND_GAP_NODES;
								end
								
								v.dp.lineSetLeft(v.dragIndicator, ...
										lay.px + v.DRAG_IND_NOD_MARG, py);
								v.dp.lineSetRight(v.dragIndicator, ...
										lay.px + w - ...
										v.DRAG_IND_NOD_MARG, py);
								v.dragIndicator.Visible = 'on';
								v.dragInsert(3:4) = [l - 1, no + 1];
								f = 1;
							end
						end
					end
					if(~f)
						v.dragIndicator.Visible = 'off';
					end
				end
			end
		end

		function dragStop(v, insert)
			if(v.selectType == v.SELECT_TYPE_DRAG)
				if(nargin < 2)
					insert = 0;
				end

				v.selectType = v.SELECT_TYPE_NONE;
				delete(v.dragOutline);
				delete(v.dragIndicator);

				if(insert)
					v.drcn.editMultiple(1);
					i = length(v.dragInsert);
					switch v.selectTier
						case 0
							if(i == 2)
								v.dragStopNets();
							end
							
						case 1
							if(i == 3)
								v.dragStopLayers();
							end
							
						case 2
							if(i == 4)
								v.dragStopNodes();
							end
					end
					v.drcn.editMultiple(0);
				end
			end
		end
		
		function dragStopNets(v)
			le = length(v.selectedNets);
			n = zeros(le, 2);
			for k = 1:le
				n(k, :) = v.selectedNets(k).xy;
			end
			[~, n] = sortrows(n);
			v.selectedNets = v.selectedNets(n);

			in = v.dragInsert;
			if(in(2) == 0)
				px = -1;
				for k = le:-1:1
					xy = v.selectedNets(k).xy;
					if(xy(1) == px)
						y = 1;
					else
						y = 0;
						if(in(1) < xy(1))
							px = xy(1) + 1;
						else
							px = xy(1);
						end
					end
					if(xy(1) < in(1) && ...
							length(v.nets{xy(1)}) < 2)
						ax = -1;
					else
						ax = 0;
					end
					v.drcn.moveNet(xy(1), xy(2), ...
									in(1), y);
					in(1) = in(1) + ax;
				end
			else
				for k = le:-1:1
					xy = v.selectedNets(k).xy;
					if(xy(1) < in(1) && ...
							length(v.nets{xy(1)}) < 2)
						ax = -1;
					else
						ax = 0;
					end
					v.drcn.moveNet(xy(1), xy(2), ...
									in(1), in(2));
					in(1) = in(1) + ax;
					if(xy(1) == in(1) && xy(2) < in(2))
						in(2) = in(2) - 1;
					end
				end
			end
		end
		
		function dragStopLayers(v)
			le = length(v.selectedLayers);
			l = zeros(le, 3);
			for k = 1:le
				l(k, 1:2) = v.selectedLayers(k).net.xy;
				l(k, 3) = v.selectedLayers(k).lp;
			end
			lays = v.selectedLayers(l(:,3) > 1);
			l = l(l(:, 3) > 1, :);
			[~, l] = sortrows(l);
			lays = lays(l);

			pxy = lays(1).net.xy;
			l = lays(1).lp - 1;
			plp = l - 1;
			in = v.dragInsert;
			in(3) = in(3) - 1;
			for k = 1:length(lays)
				xy = lays(k).net.xy;
				lp = lays(k).lp - 1;
				if(any(pxy ~= xy) || plp + 1 ~= lp)
					ax = 0;
					ay = 0;
					nl = plp - l + 1;
					if(length(v.nets{pxy(1)}{pxy(2)}...
							.layers) - 1 <= nl)
						if(pxy(1) == in(1))
							if(pxy(2) < in(2))
								ay = -1;
							end
						elseif(pxy(1) < in(1) && ...
								length( ...
								v.nets{pxy(1)}) < 2)
							ax = -1;
						end
					end
					v.drcn.moveLayers(...
						pxy(1), pxy(2), ...
						in(1), in(2), ...
						l, plp, in(3));
					if(all(pxy == in(1:2)))
						if(plp >= in(3))
							if(l <= in(3) + 1)
								in(3) = plp;
							else
								in(3) = in(3) + nl;
							end
						end
					else
						in(3) = in(3) + nl;
					end
					l = lays(k).lp - 1;
					lp = l;
					in(1:2) = in(1:2) + [ax, ay];
				end
				pxy = lays(k).net.xy;
				plp = lp;
			end		
			v.drcn.moveLayers(pxy(1), pxy(2), ...
				in(1), in(2), l, lp, in(3));
		end
		
		function dragStopNodes(v)
			ln = length(v.selectedNodes);
			n = zeros(ln, 3);
			for k = 1:ln
				n(k, 1:2) = v.selectedNodes(k).layer.net.xy;
				n(k, 3) = v.selectedNodes(k).layer.lp;
				n(k, 4) = v.selectedNodes(k).np;
			end
			nods = v.selectedNodes(n(:,3) > 1);
			n = n(n(:,3) > 1, :);
			[~, n] = sortrows(n);
			nods = nods(n);

			pxy = nods(1).layer.net.xy;
			plp = nods(1).layer.lp - 1;
			t = nods(1).np;
			pnp = t - 1;
			in = v.dragInsert;
			for k = 1:length(nods)
				xy = nods(k).layer.net.xy;
				lp = nods(k).layer.lp - 1;
				np = nods(k).np;
				
				if(any(pxy ~= xy) || plp ~= lp || pnp + 1 ~= np)
					ax = 0;
					ay = 0;
					al = 0;
					nn = pnp - t + 1;
					if(length(v.nets{pxy(1)}{pxy(2)}...
							.layers(plp+1).nodes) <= nn)
						if(length(v.nets{pxy(1)}{pxy(2)}.layers) < 3)
							if(pxy(1) == in(1))
								if(pxy(2) < in(2))
									ay = -1;
								end
							elseif(pxy(1) < in(1) && ...
									length(v.nets{pxy(1)}) < 2)
								ax = -1;
							end
						end
						if(all(pxy == in(1:2)) && plp < in(3))
							al = -1;
						end
					end
					
					v.drcn.moveNodes(...
						pxy(1), pxy(2), ...
						in(1), in(2), ...
						plp, in(3), ...
						t, pnp, in(4));
					
					if(all(pxy == in(1:2)) && plp == in(3))
						if(pnp >= in(4))
							if(t <= in(4) + 1)
								in(4) = pnp;
							else
								in(4) = in(4) + nn;
							end
						end
					else
						in(4) = in(4) + nn;
					end
					t = nods(k).np;
					np = t;
					in(1:3) = in(1:3) + [ax, ay, al];
				end
				pxy = nods(k).layer.net.xy;
				plp = nods(k).layer.lp - 1;
				pnp = np;
			end
			v.drcn.moveNodes(pxy(1), pxy(2), in(1), in(2), ...
								plp, in(3), t, np, in(4));
		end

		function select(v, el, tier)
			if(~el.selected)
				list = v.getList(tier);
				el.select(1);
				v.(list) = [v.(list), el];
			end
		end

		function selectLayersFromNet(v, n)
			if(nargin < 2)
				n = v.selectNetOf;
			end
			for l = 1:length(n.layers)
				v.select(n.layers(l), 1);
			end
		end

		function selectNodesFromNet(v, n)
			if(nargin < 2)
				n = v.selectNetOf;
			end
			for l = 1:length(n.layers)
				v.selectNodesFromLayer(n.layers(l));
			end
		end

		function selectNodesFromLayer(v, l)
			if(nargin < 2)
				l = v.selectNetOf.layers(v.selectNextLayer + 1);
			end
			for n = 1:length(l.nodes)
				v.select(l.nodes(n), 2);
			end
		end

		function selectCurrent(v)
			if(~isempty(v.selectElem))
				v.select(v.selectElem, v.selectTier);
			end
		end

		function selectCurrentNet(v)
			v.select(v.selectNetOf, 0);
		end

		function selectCurrentLayer(v)
			v.select(v.selectNetOf.layers(v.selectNextLayer + 1), 1);
		end

		function deselect(v, el, tier)
			if(el.selected)
				list = v.getList(tier);
				el.select(0);
				v.(list) = setdiff(v.(list), el);
			end
		end

		function deselectLayersFromNet(v, n)
			if(nargin < 2)
				n = v.selectNetOf;
			end
			for l = 1:length(n.layers)
				v.deselect(n.layers(l), 1);
			end
		end

		function deselectNodesFromNet(v, n)
			if(nargin < 2)
				n = v.selectNetOf;
			end
			for l = 1:length(n.layers)
				v.deselectNodesFromLayer(n.layers(l));
			end
		end

		function deselectNodesFromLayer(v, l)
			if(nargin < 2)
				l = v.selectNetOf.layers(v.selectNextLayer + 1);
			end
			for n = 1:length(l.nodes)
				v.deselect(l.nodes(n), 2);
			end
		end

		function deselectCurrent(v)
			v.deselect(v.selectElem, v.selectTier);
		end

		function deselectCurrentNet(v)
			v.deselect(v.selectNetOf, 0);
		end

		function deselectCurrentLayer(v)
			v.deselect(v.selectNetOf.layers(v.selectNextLayer + 1), 1);
		end

		function deselectGroup(v, tier)
			list = v.getList(tier);
			for k = 1:length(v.(list))
				v.(list)(k).select(0);
			end
			v.(list) = [];
		end

		function notifyDrawn(v)
			for k = 1:length(v.notifyNets)
				v.notify('NetDrawn', v.notifyNets(k));
			end
			v.notifyNets = [];

			for k = 1:length(v.notifyLayers)
				v.notify('LayerDrawn', v.notifyLayers(k));
			end
			v.notifyLayers = [];

			for k = 1:length(v.notifyNodes)
				v.notify('NodeDrawn', v.notifyNodes(k));
			end
			v.notifyNodes = [];
		end

		function cAxesAddNet(v)
			xl = length(v.nets);
			if(xl == 0)
				v.drcn.getDlg('addNet').show();
			else
				for x = 1:xl
					if(v.nets{x}{1}.px > v.selectPoint(1))
						break;
					end
				end
				if(x == xl && v.nets{x}{1}.px < v.selectPoint(1))
					if(v.nets{x}{1}.px + v.maxW(x) <= v.selectPoint(1))
						x = x + 1;
					end
				else
					x = x - 1;
				end
				if(x < 1)
					v.drcn.getDlg('addNet').show(0, 0);
				elseif(x > xl)
					v.drcn.getDlg('addNet').show(2 * xl, 0);
				elseif(v.nets{x}{1}.px + v.maxW(x) <= v.selectPoint(1))
					v.drcn.getDlg('addNet').show(2 * x, 0);
				else
					yl = length(v.nets{x});
					for y = 1:yl
						if(v.nets{x}{y}.py > v.selectPoint(2))
							break;
						end
					end
					if(y ~= yl || v.nets{x}{y}.py >= v.selectPoint(2))
						y = y - 1;
					end
					v.drcn.getDlg('addNet').show(2 * x - 1, y);
				end
			end
		end

		function cAddNet(v)
			xy = v.selectNetOf.xy;
			v.drcn.getDlg('addNet').show(xy(1) * 2 - 1, xy(2));
		end

		function cAddLayers(v)
			xy = v.selectNetOf.xy;
			v.drcn.getDlg('addLay').show(xy(1), xy(2), v.selectNextLayer);
		end
		
		function cAddNodes(v)
			xy = v.selectNetOf.xy;
			v.drcn.getDlg('addNod').show(xy(1), xy(2), v.selectNextLayer);
		end
		
		function cMenuSetLabels(v, cm, rep)
			for k = 1:length(cm.Children)
				v.cMenuSetLabels(cm.Children(k), rep)
			end
			
			if(isa(cm, 'matlab.ui.container.Menu'))
				t = cm.UserData;
				for k = 1:size(rep, 1)
					t = strrep(t, rep{k, 1}, rep{k, 2});
				end
				cm.Label = t;
			end
		end
		
		function onSRectMove(v, cp, lp, sp)
			cp = v.dp.pos2pixel(cp);
			lp = v.dp.pos2pixel(lp);
			sp = v.dp.pos2pixel(sp);
			
			if(cp(1) < lp(1))
				right = 0;
				xl = cp(1);
				xr = lp(1);
			else
				right = 1;
				xl = lp(1);
				xr = cp(1);
			end
			if(sp(2) <= lp(2))
				ybox = [sp(2), lp(2)];
			else
				ybox = [lp(2), sp(2)];
			end
			if(cp(2) < lp(2))
				down = 0;
				yt = cp(2);
				yb = lp(2);
			else
				down = 1;
				yt = lp(2);
				yb = cp(2);
			end
			if(sp(1) <= cp(1))
				xbox = [sp(1), cp(1)];
			else
				xbox = [cp(1), sp(1)];
			end
			
			w = v.nets{1}{1}.layers(1).WIDTH;
			
			for x = 1:length(v.nets)
				for y = 1:length(v.nets{x})
					n = v.nets{x}{y};
					px = n.px;
					pxw = n.px + n.width;
					py = n.py;
					pyh = py + n.height;
					
					nin = n.inSRectArea;
					ninNew = 0;
					
					% x-axis movement
					if(cp(1) ~= lp(1))
						% Movement to the right of the start position
						if(xr > sp(1) && ( ...
								(right && ~nin) || ...
								(~right && nin)))
							if(px >= max(sp(1), xl) && px <= xr)
								if((py  >= ybox(1) && py  <= ybox(2))||...
								   (pyh >= ybox(1) && pyh <= ybox(2))||...
								   (py  <= ybox(1) && pyh >= ybox(2)))
									if(n.selected)
										v.deselectNet(n);
									else
										v.selectNet(n);
									end
									if(nin)
										n.inSRectArea = 0;
									else
										n.inSRectArea = 1;
										ninNew = 1;
									end
								end
							end
						end
						
						% Movement to the left of the start position
						if(~ninNew && xl < sp(1) && ( ...
								(~right && ~nin) || ...
								(right && nin)))
							if(pxw <= min(sp(1), xr) && pxw >= xl)
								if((py  >= ybox(1) && py  <= ybox(2))||...
								   (pyh >= ybox(1) && pyh <= ybox(2))||...
								   (py  <= ybox(1) && pyh >= ybox(2)))
									if(n.selected)
										v.deselectNet(n);
									else
										v.selectNet(n);
									end
									if(nin)
										n.inSRectArea = 0;
									else
										n.inSRectArea = 1;
										ninNew = 1;
									end
								end
							end
						end
					end
					
					% y-axis mvement
					if(~ninNew && cp(2) ~= lp(2))
						% Movement above the start position
						if(yb > sp(2) && ( ...
								(down && ~nin) || ...
								(~down && nin)))
							if(py >= max(sp(2), yt) && py <= yb)
								if((px  >= xbox(1) && px  <= xbox(2))||...
								   (pxw >= xbox(1) && pxw <= xbox(2))||...
								   (px  <= xbox(1) && pxw >= xbox(2)))
									if(n.selected)
										v.deselectNet(n);
									else
										v.selectNet(n);
									end
									if(nin)
										n.inSRectArea = 0;
									else
										n.inSRectArea = 1;
										ninNew = 1;
									end
								end
							end
						end
						
						% Movement below the start position
						if(~ninNew && yt < sp(2) && ( ...
								(~down && ~nin) || ...
								(down && nin)))
							if(pyh <= min(sp(2), yb) && pyh >= yt)
								if((px  >= xbox(1) && px  <= xbox(2))||...
								   (pxw >= xbox(1) && pxw <= xbox(2))||...
								   (px  <= xbox(1) && pxw >= xbox(2)))
									if(n.selected)
										v.deselectNet(n);
									else
										v.selectNet(n);
									end
									if(nin)
										n.inSRectArea = 0;
									else
										n.inSRectArea = 1;
										ninNew = 1;
									end
								end
							end
						end
					end
					
					% Net is affected, check layers
					if(nin || ninNew)
						lin = [n.layers.inSRectArea];
						% x-axis movement
						if(cp(1) ~= lp(1))
							% Movement to the right of the start position
							if(xr > sp(1))
								mod = n.px + n.MARGL;
								l = ceil((max(xl, sp(1)) - mod) / ...
									(w + n.LAYMARGH));
								r = floor((xr - mod) / (w + n.LAYMARGH));
								l = max(l + 1, 1);
								r = min(r + 1, length(n.layers));
								py = n.layers(1).py;
								for k = l:r
									lay = n.layers(k);
									pyh = py + lay.height;
									if((py  >= ybox(1) && py  <= ybox(2))|| ...
									   (pyh >= ybox(1) && pyh <= ybox(2))|| ...
									   (py  <= ybox(1) && pyh >= ybox(2)))
										if(lay.selected)
											v.deselectLayer(lay);
										else
											v.selectLayer(lay);
										end
									
										lay.inSRectArea = ~lay.inSRectArea;
										lin(k) = 1;
									end
								end
							end

							% Movement to the left of the start position
							if(xl < sp(1))
								mod = n.px + n.MARGL + w;
								l = ceil((xl - mod) / (w + n.LAYMARGH));
								r = floor((min(xr, sp(1)) - mod) / ...
									(w + n.LAYMARGH));
								l = max(l + 1, 1);
								r = min(r + 1, length(n.layers));
								py = n.layers(1).py;
								for k = l:r
									lay = n.layers(k);
									pyh = py + lay.height;
									if((py  >= ybox(1) && py  <= ybox(2))|| ...
									   (pyh >= ybox(1) && pyh <= ybox(2))|| ...
									   (py  <= ybox(1) && pyh >= ybox(2)))
								   
										if(lay.selected)
											v.deselectLayer(lay);
										else
											v.selectLayer(lay);
										end
									
										lay.inSRectArea = ~lay.inSRectArea;
										lin(k) = 1;
									end
								end
							end
						end

						% y-axis movement
						if(cp(2) ~= lp(2))
							py = n.layers(1).py;
							% Movement above the start position
							if(yb > sp(2) && yb > py && ...
									max(yt, sp(2)) <= py)
								mod = n.px + n.MARGL;
								l = ceil((xbox(1) - mod - w) / ...
									(w + n.LAYMARGH));
								r = floor((xbox(2) - mod) / ...
									(w + n.LAYMARGH));
								l = max(l + 1, 1);
								r = min(r + 1, length(n.layers));
								for k = l:r
									lay = n.layers(k);
									if(lay.selected)
										v.deselectLayer(lay);
									else
										v.selectLayer(lay);
									end
									
									lay.inSRectArea = ~lay.inSRectArea;
									lin(k) = 1;
								end
							end
							
							% Movement below the start position
							if(yt < sp(2))
								mod = n.px + n.MARGL;
								l = ceil((xbox(1) - mod - w) / ...
									(w + n.LAYMARGH));
								r = floor((xbox(2) - mod) / ...
									(w + n.LAYMARGH));
								l = max(l + 1, 1);
								r = min(r + 1, length(n.layers));
								py = n.layers(1).py;
								for k = l:r
									lay = n.layers(k);
									pyh = py + lay.height;
									
									if(min(yb, sp(2)) > pyh && yt <= pyh)
										if(lay.selected)
											v.deselectLayer(lay);
										else
											v.selectLayer(lay);
										end
										
										lay.inSRectArea = ~lay.inSRectArea;
										lin(k) = 1;
									end
								end
							end
						end
						
						nw = n.layers(1).nodes(1).width;
						nh = n.layers(1).nodes(1).height;
						% Check nodes, if layer is affected
						for l = 1:length(n.layers)
							lay = n.layers(l);
							if(lin(l) || lay.inSRectArea)
								% x-axis movement
								if(cp(1) ~= lp(1))
									modx = lay.px + lay.MARGL;
									% Movement to the right of
									% the start position
									if(xr > sp(1))
										if(max(xl, sp(1)) < modx && ...
												xr >= modx)
											mod = lay.py + lay.MARGT;
											t = ceil((ybox(1) - mod - nh) ...
												/ (nh + lay.NODMARGV));
											b = floor((ybox(2) - mod) / ...
												(nh + lay.NODMARGV));
											
											t = max(t + 1, 1);
											b = min(b + 1, ...
												length(lay.nodes));
											for k = t:b
												no = lay.nodes(k);
												if(no.selected)
													v.deselectNode(no);
												else
													v.selectNode(no);
												end
											end
										end
									end

									% Movement to the left of
									% the start position
									modx = modx + nw;
									if(xl < sp(1))
										if(xl < modx && ...
												min(xr, sp(1)) >= modx)
											mod = lay.py + lay.MARGT;
											t = ceil((ybox(1) - mod - nh) ...
												/ (nh + lay.NODMARGV));
											b = floor((ybox(2) - mod) / ...
												(nh + lay.NODMARGV));
											
											t = max(t + 1, 1);
											b = min(b + 1, ...
												length(lay.nodes));
											for k = t:b
												no = lay.nodes(k);
												if(no.selected)
													v.deselectNode(no);
												else
													v.selectNode(no);
												end
											end
										end
									end
								end
								
								% y-axis movement
								if(cp(2) ~= lp(2))
									modx = lay.px + lay.MARGL;
									% Movement above the start position
									if(yb > sp(2))
										if((xbox(1) <= modx && ...
												xbox(2) >= modx + nw) ||...
												(xbox(1) >= modx && ...
												xbox(1) <= modx + nw) ||...
												(xbox(2) >= modx && ...
												xbox(2) <= modx + nw))
											
											mod = lay.py + lay.MARGT;
											t = ceil((max(yt, sp(2)) - mod) ...
												/ lay.VDIST);
											b = floor((yb - mod) ...
												/ lay.VDIST);
											
											t = max(t + 1, 1);
											b = min(b + 1, ...
												length(lay.nodes));
											for k = t:b
												no = lay.nodes(k);
												if(no.selected)
													v.deselectNode(no);
												else
													v.selectNode(no);
												end
											end
										end
									end

									% Movement below the start position
									if(yt < sp(2))
										if((xbox(1) <= modx && ...
												xbox(2) >= modx + nw) ||...
												(xbox(1) >= modx && ...
												xbox(1) <= modx + nw) ||...
												(xbox(2) >= modx && ...
												xbox(2) <= modx + nw))
											
											mod = lay.py + lay.MARGT + nh;
											t = ceil((yt - mod) / ...
												(nh + lay.NODMARGV));
											b = floor((min(yb,sp(2)) - mod) ...
												/ (nh + lay.NODMARGV));
											t = max(t + 1, 1);
											b = min(b + 1, ...
												length(lay.nodes));
											for k = t:b
												no = lay.nodes(k);
												if(no.selected)
													v.deselectNode(no);
												else
													v.selectNode(no);
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end
		
		function sRectStart(v)
			if(~isempty(v.nets) && v.dp.rectSelection(1))
				sp = v.dp.getMousePosition();
				f = 0;
				
				for x = 1:length(v.nets)
					for y = 1:length(v.nets{x})
						n = v.nets{x}{y};
						if(v.isInNet(sp, n))
							f = n;
						end
						n.inSRectArea = 0;
						for l = 1:length(n.layers)
							n.layers(l).inSRectArea = 0;
						end
					end
				end
				
				if(f ~= 0)
					f.inSRectArea = 1;
					w = f.layers(1).WIDTH;
					l = (sp(1) - f.px - f.MARGL) / (w + f.LAYMARGH);
					lf = floor(l);
					if(lf >= 0 && l - lf <= w)
						l = f.layers(lf + 1);
						if(sp(2) >= l.py && sp(2) <= l.py + l.height)
							l.inSRectArea = 1;
						end
					end
				end
			end
		end
		
		function sRectStop(v)
			v.dp.rectSelection(0);
		end
	end
	
	methods (Static)
		function pos = getDefaultPos()
			import dracon.gui.view.network;
			pos = get(groot, 'ScreenSize');
			% This makes Matlab think the Neural Network Toolbox
			% is required.		vvv
			pos(1) = pos(1) + network.DLG_MARGL;
			pos(2) = pos(2) + network.DLG_MARGB;
			pos(3) = pos(3) - network.DLG_MARGL - network.DLG_MARGR;
			pos(4) = pos(4) - network.DLG_MARGB - network.DLG_MARGT;
		end
		
		function list = getList(tier)
			switch tier
				case 0
					list = 'selectedNets';
				case 1
					list = 'selectedLayers';
				case 2
					list = 'selectedNodes';
				otherwise
					list = '';
			end
		end
		
		function in = isInNet(pos, n)
			if(n.px <= pos(1) && n.px + n.width >= pos(1) && ...
					n.py <= pos(2) && n.py + n.height >= pos(2))
				in = 1;
			else
				in = 0;
			end
		end
	end
end
