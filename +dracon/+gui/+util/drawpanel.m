classdef drawpanel < handle
%DRAWPANEL Axes of simulated infinite size, may be navigated with mouse.

	properties (Hidden, Constant, Transient)
		ZOOM_SCROLL = 1.2;
		ZOOM_CTRL   = 1.2;
		ZOOM_MAX    = 5e3;
		ZOOM_MIN    = 5e-5;

		ARROW_SPEED = 5e-3;
		
		% Selection Rectangle options
        SELRECT_BORDERW		= 1.2;			% Border width
        SELRECT_BORDERCO	= [.5 .7 .9];	% Border colour
        SELRECT_BORDERCU	= [0. 0.];		% Border curvature
        SELRECT_BORDERS		= '-.';			% Border style
        SELRECT_FACECO		= 'none';		% Face colour
	end

	properties
		zoomReset = [0 1];  % Reset values for XLim and YLim
	end

	properties (SetAccess = private)
		axes;
	end

	properties (Hidden, SetAccess = private)
		pan;
		
		sRect;
		sRectStart = [];
		sRectLast;
		sRectCb = @dracon.util.NOP;

		zoomVal = 1;
		aSize = 512;
		moveData = [];
	end

	events
		AxesClicked;       % Notified when the axes themselves are clicked
	end

	methods
		function dp = drawpanel(varargin)
			dp.pan = uipanel(varargin{:}, 'BorderType', 'none');
			un = dp.pan.Units;
			dp.pan.Units = 'Pixels';
			pos2 = dp.pan.Position(4) + 1 - dp.aSize;
			dp.pan.Units = un;
			dp.axes = axes('Parent', dp.pan, ...
						   'Units','pixels', ...
						   'XColor','none', ...
						   'YColor','none', ...
						   'XLimMode','manual', ...
						   'YLimMode','manual', ...
						   'ZLimMode','manual', ...
						   'YDir','reverse', ...
						   'Position', ...
						   [1 pos2 dp.aSize dp.aSize]);
			colormap(dp.axes, 'gray');	
			dp.pan.SizeChangedFcn = @(~,~)dp.onPanResize();
			dp.axes.ButtonDownFcn = @(~,~)dp.axClick();
		end

		function moveX(dp, dist)
			dp.moveXNorm(dp.dis2norm(dist));
		end

		function moveXNorm(dp, dist)
			dp.axes.XLim = dp.axes.XLim + dist;
			dp.onMoved();
		end

		function moveY(dp, dist)
			dp.moveYNorm(dp.dis2norm(dist));
		end

		function moveYNorm(dp, dist)
			dp.axes.YLim = dp.axes.YLim + dist;
			dp.onMoved();
		end

		function zoom(dp, fac, posX, posY)
			if(dp.zoomVal * fac >= dp.ZOOM_MIN && ...
			   dp.zoomVal * fac <= dp.ZOOM_MAX)
				d = posX * (1 - fac);
				dp.axes.XLim(1) = d + dp.axes.XLim(1)*fac;
				dp.axes.XLim(2) = d + dp.axes.XLim(2)*fac;

				d = posY * (1 - fac);
				dp.axes.YLim(1) = d + dp.axes.YLim(1)*fac;
				dp.axes.YLim(2) = d + dp.axes.YLim(2)*fac;

				dp.zoomVal = dp.zoomVal * fac;
			end
		end
		
		function resetZoom(dp)
			dp.axes.XLim = dp.zoomReset;
			dp.axes.YLim = dp.zoomReset;
			dp.zoomVal = 1;
			dp.onMoved();
		end

		function r = rect(dp, pos, varargin)
			pos = [dp.pos2norm(pos(1:2)), dp.dis2norm(pos(3:4))];
			r = dp.rectNorm(pos, varargin{:});
		end

		function r = rectNorm(dp, pos, varargin)
			r = rectangle('Parent', dp.axes, ...
						'Position', pos, ...
						'UserData', pos(1:2), ...
						varargin{:});
		end

		function rectMove(dp, r, dm)
			dp.rectMoveNorm(r, dp.dis2norm(dm));
		end
		
		function rectSetPos(dp, r, pos)
			dp.rectSetPosNorm(r, dp.pos2norm(pos));
		end

		function rectResize(dp, r, ns)
			dp.rectResizeNorm(r, dp.dis2norm(ns));
		end

		function pos = rectGetPos(dp, r)
			pos = dp.pos2pixel(r.Position(1:2));
		end

		function s = rectGetSize(dp, r)
			s = dp.dis2pixel(r.Position(3:4));
		end

		function l = line(dp, x, y, varargin)
			x = dp.pos2norm(x);
			y = dp.pos2norm(y);
			l = line(x, y, 'Parent', dp.axes, varargin{:});
		end

		function lineMove(dp, l, dx, dy)
			dp.lineMoveNorm(l, dp.pos2norm(dx), dp.pos2norm(dy));
		end

		function lineSetLeft(dp, l, x, y)
			dp.lineSetLeftNorm(l, dp.pos2norm(x), dp.pos2norm(y));
		end

		function lineSetRight(dp, l, x, y)
			dp.lineSetRightNorm(l, dp.pos2norm(x), dp.pos2norm(y));
		end

		function n = pos2norm(dp, p)
			n = (p - 1) / dp.aSize;
		end

		function p = pos2pixel(dp, n)
			p = n * dp.aSize + 1;
		end

		function n = dis2norm(dp, p)
			n = p / dp.aSize;
		end

		function p = dis2pixel(dp, n)
			p = n * dp.aSize;
		end

		function clear(dp)
			if(~isempty(dp.axes.Children))
				delete(dp.axes.Children);
			end
		end
		
		function done = rectSelection(dp, start)
			done = 0;
			
			if(start == 0 && ~isempty(dp.sRectStart))
				dp.sRectStart = [];
				delete(dp.sRect);
				done = 1;
				
			elseif(start ~= 0 && isempty(dp.sRectStart))
				dp.sRectStart = dp.axes.CurrentPoint([1, 3]);
				dp.sRectLast = dp.sRectStart;
				
				dp.sRect = dp.rectNorm([dp.sRectStart, 0, 0], ...
									'LineWidth', dp.SELRECT_BORDERW, ...
									'LineStyle', dp.SELRECT_BORDERS, ...
									'EdgeColor', dp.SELRECT_BORDERCO, ...
									'Curvature', dp.SELRECT_BORDERCU, ...
									'FaceColor', dp.SELRECT_FACECO);
				uistack(dp.sRect, 'top');
				done = 1;
			end
		end
		
		function setRSCallback(dp, cb)
			dp.sRectCb = cb;
		end
		
		function p = getMousePosition(dp)
			p = dp.pos2pixel(dp.getMousePositionNorm());
		end
		
		function p = getMousePositionNorm(dp)
			p = dp.axes.CurrentPoint([1, 3]);
		end
	end
	
	methods (Static)
		function rectMoveNorm(r, dm)
			r.Position(1:2) = r.Position(1:2) + dm;
			r.UserData = r.UserData + dm;
		end
		
		function rectSetPosNorm(r, pos)
			r.Position(1:2) = pos;
			r.UserData = pos;
		end
		
		function rectResizeNorm(r, ns)
			neg = min([0, 0], ns);
			r.Position(1:2) = r.UserData + neg;
			r.Position(3:4) = abs(ns);
		end
		
		function lineMoveNorm(l, dx, dy)
			l.XData = l.XData + dx;
			l.YData = l.YData + dy;
		end
		
		function lineSetLeftNorm(l, x, y)
			l.XData(1) = x;
			l.YData(1) = y;
		end
		
		function lineSetRightNorm(l, x, y)
			l.XData(2) = x;
			l.YData(2) = y;
		end
	end

	% Call these in the Window event functions of the figure.
	methods (Hidden)
		function onButtonDown(dp, fig)
			switch fig.SelectionType
				case 'extend'
					dp.moveData = dp.axes.CurrentPoint([1 3]);
					fig.Pointer = 'fleur';
					
			end
		end

		function onButtonUp(dp, fig)
			if(~isempty(dp.moveData))
				dp.moveData = [];
				fig.Pointer = 'arrow';
			end
		end

		function onMove(dp)
			cp = dp.axes.CurrentPoint([1, 3]);
			if(~isempty(dp.moveData))
				dp.moveXNorm(dp.moveData(1) - cp(1));
				dp.moveYNorm(dp.moveData(2) - cp(2));
			end
			dp.onMoved();
		end
		
		function onMoved(dp)
			cp = dp.axes.CurrentPoint([1, 3]);
			if(~isempty(dp.sRectStart))
				dp.rectResizeNorm(dp.sRect, cp - dp.sRectStart);
				dp.sRectCb(cp, dp.sRectLast, dp.sRectStart);
				dp.sRectLast = cp;
			end
		end

		function onScroll(dp, ev)
			if(ev.VerticalScrollCount > 0)
				dp.zoom(dp.ZOOM_SCROLL, ...
						dp.axes.CurrentPoint(1), dp.axes.CurrentPoint(3));
			else
				dp.zoom(1/dp.ZOOM_SCROLL, ...
						dp.axes.CurrentPoint(1), dp.axes.CurrentPoint(3));
			end
		end

		function onKey(dp, ev)
			switch ev.Key
				case 'leftarrow'
					dp.moveXNorm(dp.ARROW_SPEED * dp.zoomVal);
				case 'rightarrow'
					dp.moveXNorm(-dp.ARROW_SPEED * dp.zoomVal);
				case 'uparrow'
					dp.moveYNorm(dp.ARROW_SPEED * dp.zoomVal);
				case 'downarrow'
					dp.moveYNorm(-dp.ARROW_SPEED * dp.zoomVal);
					
				case 'space'
					dp.resetZoom();
					
				otherwise
					if(length(ev.Modifier) == 1  && ...
					   strcmp(ev.Modifier, 'control'))
					   if(~isempty(ev.Character) && ...
						   (ev.Character == '+' || ev.Character == ''))
							un = dp.axes.Units;
							dp.axes.Units = 'Normalized';
							pos = dp.zoomVal./dp.axes.Position(3:4)/2;
							dp.axes.Units = un;
							pos = pos + [dp.axes.XLim(1), dp.axes.YLim(1)];
							dp.zoom(1/dp.ZOOM_CTRL, pos(1), pos(2));
					   elseif(strcmp(ev.Key, 'hyphen') || ...
								(~isempty(ev.Character) && ...
								 ev.Character == '-'))
							un = dp.axes.Units;
							dp.axes.Units = 'Normalized';
							pos = dp.zoomVal./dp.axes.Position(3:4)/2;
							dp.axes.Units = un;
							pos = pos + [dp.axes.XLim(1), dp.axes.YLim(1)];
							dp.zoom(dp.ZOOM_CTRL, pos(1), pos(2));
					   end
					end
			end
		end
	end

	methods (Access = private)
		function onPanResize(dp)
			un = dp.pan.Units;
			dp.pan.Units = 'Pixels';
			while(any(dp.pan.Position(3:4) > dp.aSize))
				dp.resizeAxes(2);
			end
			dp.axes.Position(2) = dp.pan.Position(4) + 1 - dp.aSize;
			dp.pan.Units = un;
		end

		function resizeAxes(dp, factor)
			dp.aSize = dp.aSize * factor;
			dp.axes.Position(3:4) = dp.aSize;
			if(~isempty(dp.axes.Children))
				set(dp.axes.Children,{'Position'}, ...
					transpose(cellfun(@(x)x / factor, ...
					{dp.axes.Children.Position}, 'UniformOutput', 0)));
			end
		end

		function axClick(dp)
			dp.notify('AxesClicked');
		end
	end
end

