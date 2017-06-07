classdef net < dracon.gui.view.network.selectable
%NET Summary of this class goes here
%   Detailed explanation goes here


	properties (Dependent, SetAccess = immutable)
		xy;

		width;
		height;
		numLayers;
	end

	properties (SetAccess = private)
		px;
		py;
	end

	properties (Hidden, Constant, Transient)
		% Layer options
		MARGT    = 8;		% Margin to net, top
		MARGB    = 8;		% Margin to net, bottom
		MARGL    = 8;		% Margin to net, left
		MARGR    = 8;		% Margin to net, right
		LAYMARGH = 8;		% Margin to other layers, horizontal

		% Net options
		FACECO		= 'none';		% Face colour
		BORDERW		= .1;			% Border width
		BORDERCO	= [.4 .4 .4];	% Border colour
		BORDERS		= '-';			% Border style
		BORDERCU	= [0 0];		% Border curvature

		FACESELCO	= [.95 .95 1.];	% Face colour when selected
		BORDERSELW	= 1.5;			% Border width when selected
		BORDERSELCO	= [.3 .3 1];	% Border colour when selected
		BORDERSELS	= '-';			% Border style when selected

		FACEOLCO	= 'none';		% Face colour of outline
		BORDEROLW	= 1.5;			% Border width of outline
		BORDEROLCO	= [.3 .3 1];	% Border colour of outline
		BORDEROLS	= ':';			% Border style of outline

		CLICKABLE	= 'visible';	% Clickable parts. all, visible or none
	end

	properties (Hidden)
		v;
		rect;

		linelayers = dracon.gui.view.network.linelayer.empty();;
		layers = dracon.gui.view.network.layer.empty();
		maxLay = 0;
	end

	methods
		function n = net(v, px, py)
			n.v = v;
			n.px = px;
			n.py = py;
			n.rect = v.dp.rect([px, py, 0, 0], ...
							   'LineWidth', n.BORDERW, ...
							   'LineStyle', n.BORDERS, ...
							   'EdgeColor', n.BORDERCO, ...
							   'Curvature', n.BORDERCU, ...
							   'FaceColor', n.FACECO, ...
							   'PickableParts', n.CLICKABLE);

			n.rect.UIContextMenu = v.cMenuNets;
			n.rect.ButtonDownFcn = @(~,~)n.v.onNetClick(n);
		end

		function move(n, dx, dy)
			n.px = n.px + dx;
			n.py = n.py + dy;
			for k = 1:n.numLayers
				n.layers(k).move(dx, dy);
			end
			n.v.dp.rectMove(n.rect, [dx, dy]);
		end

		function xy = get.xy(n)
			for x = 1:length(n.v.nets)
				y = find([n.v.nets{x}{:}] == n);
				if(~isempty(y))
					break;
				end
			end
			xy = [x, y];
		end

		function w = get.width(n)
			l = n.numLayers;
			if(l == 0)
				w = 0;
			else
				lw = n.layers(1).WIDTH;
				w = n.MARGL + l * lw + (l - 1) * n.LAYMARGH + n.MARGR;
			end
		end

		function h = get.height(n)
			h = n.maxLay + n.MARGT + n.MARGB;
		end

		function l = get.numLayers(n)
			l = length(n.layers);
		end

		function addLayers(n, lp, nn, nl)
			import dracon.gui.view.network.layer
			import dracon.util.netdata

			w = layer.WIDTH;
			if(lp == 1)
				nx = n.px + n.MARGL;
				ny = n.py + n.MARGT;
			else
				nx = n.layers(lp - 1).px + w + n.LAYMARGH;
				ny = n.layers(1).py;
			end

			l = layer(n, nx, ny, nn);

			data = netdata(netdata.ADDLAYERS);
			data.net = l;
			if(n.v.drcn.multiEdit)
				n.v.notifyLayers = [n.v.notifyLayers, data];
			else
				n.v.notify('LayerDrawn', data);
			end

			for k = 2:nl
				nx = nx + w + n.LAYMARGH;
				l(k) = layer(n, nx, ny, nn);

				data = netdata(netdata.ADDLAYERS);
				data.net = l;
				n.v.notifyLayers = [n.v.notifyLayers, data];
			end
			n.layers = [n.layers(1:lp-1), l, n.layers(lp:end)];

			w = nl * (w + n.LAYMARGH);
			for k = lp+nl:n.numLayers
				n.layers(k).move(w, 0);
			end
			h = l(1).height;
			if(h > n.maxLay)
				n.maxLay = h;
			end
			n.v.dp.rectResize(n.rect, [n.width, n.height]);

		end
		
		function layersAdded(n, lp, nl)
			w = nl * (n.layers(1).width + n.LAYMARGH);
			for k = lp+nl:n.numLayers
				n.layers(k).move(w, 0);
			end
			
			for k = lp:lp+nl-1
				h = n.layers(k).height;
				if(h > n.maxLay)
					n.maxLay = h;
				end
			end
			n.v.dp.rectResize(n.rect, [n.width, n.height]);
			uistack(n.rect, 'bottom');
		end

		function delNet = rmLayer(n, lp)
			if(n.numLayers < 3)
				delNet = 1;
				delete(n);
			else
				delNet = 0;
				h = n.layers(lp).height;
				delete(n.layers(lp));
				n.layers = [n.layers(1:lp-1), n.layers(lp+1:end)];
				w = n.layers(1).WIDTH + n.LAYMARGH;
				for k = lp:n.numLayers
					n.layers(k).move(-w, 0);
				end
				if(h == n.maxLay)
					n.getMaxLay();
				end
				n.v.dp.rectResize(n.rect, [n.width, n.height]);
			end
		end

		function layersRemoved(n, lp, nl)
			w = (n.layers(1).WIDTH + n.LAYMARGH) * nl;
			for k = lp:n.numLayers
				n.layers(k).move(-w, 0);
			end
			n.getMaxLay();
			n.v.dp.rectResize(n.rect, [n.width, n.height]);
		end
		
		function addNodes(n, lp, nn)
			n.layers(lp).addNodes(nn);
			h = n.layers(lp).height;
			if(h > n.maxLay)
				n.maxLay = h;
			end
			n.v.dp.rectResize(n.rect, [n.width, n.height]);
		end
		
		function nodesAdded(n, lp, np, nn)
			n.layers(lp).nodesAdded(np, nn);
			h = n.layers(lp).height;
			if(h > n.maxLay)
				n.maxLay = h;
			end
			n.v.dp.rectResize(n.rect, [n.width, n.height]);
		end

		function delNet = rmNode(n, lp, np)
			if(n.layers(lp).numNodes == 1)
				delNet = n.rmLayer(lp);
			else
				delNet = 0;
				h = n.layers(lp).height;
				n.layers(lp).rmNode(np);
				if(h == n.maxLay)
					n.getMaxLay();
				end
				n.v.dp.rectResize(n.rect, [n.width, n.height]);
			end
		end
		
		function nodesRemoved(n, lp, np, nn)
			n.layers(lp).nodesRemoved(np, nn);
			n.getMaxLay();
			n.v.dp.rectResize(n.rect, [n.width, n.height]);
		end

		function select(n, sel)
			if(sel == 0)
				n.selected = 0;
				n.rect.FaceColor = n.FACECO;
				n.rect.EdgeColor = n.BORDERCO;
				n.rect.LineWidth = n.BORDERW;
				n.rect.LineStyle = n.BORDERS;
			else
				n.selected = 1;
				n.rect.FaceColor = n.FACESELCO;
				n.rect.EdgeColor = n.BORDERSELCO;
				n.rect.LineWidth = n.BORDERSELW;
				n.rect.LineStyle = n.BORDERSELS;
			end
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

		function lp = getNextLayer(n, x)
			lp = ceil((x - n.px - n.MARGL) / ...
						(n.layers(1).WIDTH + n.LAYMARGH));
		end

		function delete(n)
			if(n.selected && n.v.isvalid())
				list = n.v.getList(0);
				n.v.(list) = n.v.(list)(n.v.(list) ~= n);
			end
			delete(n.layers);
			delete(n.rect);
		end
	end

	methods (Hidden)
		function getMaxLay(n)
			n.maxLay = 0;
			for k = 1:n.numLayers
				h = n.layers(k).height;
				if(h > n.maxLay)
					n.maxLay = h;
				end
			end
		end
	end
end

