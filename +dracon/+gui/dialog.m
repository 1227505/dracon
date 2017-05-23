classdef (Abstract) dialog < handle
	%SCROLLDIALOG Scrollable dialog.

	properties (Constant, Transient, Abstract, Hidden)
		NAME;
		OKTEXT;
		CANCTEXT;
	end

	properties (Constant, Transient, Hidden)
		NOTSCROLL = {'edit', 'listbox', 'popupmenu'};
	end

	properties (Transient, Hidden)
		minW = 560;
		maxW = 560;
		dMaxW = 575;

		bSpace = 34;
		bMargT = -2;
		bSize = [80 22];
		bMargX = 90;
		bMargY = 6;
	end

	properties (Hidden)
		dlg;
		scroll;
		bpan;
		ok;
		debOk;  % Debounce OK button

		drcn;
	end

	methods        
		function sd = dialog(drcn)
			sd.drcn = drcn;
			sd.init();

			sd.dlg = dialog('Visible','off', ...
							 'Name',sd.NAME, ...
							 'Resize', 'on', ...
							 'CloseRequestFcn', @(~,~)sd.onClose(), ...
							 'WindowScrollWheelFcn', @(~,ev)sd.onScroll(ev), ...
							 'WindowKeyPressFcn', @(~,ev)sd.onKey(ev), ...
							 'WindowButtonDownFcn', @(~,~)sd.focusOk());
			sd.dlg.Position(3) = sd.minW;
			sd.scroll = dracon.gui.util.scrollpanel(sd.dlg, ...
													'Units', 'pixel');
			sd.scroll.panel.ButtonDownFcn = @(~,~)sd.focusOk();

			sd.bpan = uipanel(sd.dlg, 'Units', 'pixel');
			sd.bpan.Position(4) = sd.bSpace;
			sd.bSpace = sd.bSpace + sd.bMargT;
			b = uicontrol(sd.bpan, 'String', sd.OKTEXT, ...
								   'Callback', @(~,~)sd.checkOk());
			b.Position(2) = sd.bMargY;
			b.Position(3:4) = sd.bSize;
			b = uicontrol(sd.bpan, 'String', sd.CANCTEXT, ...
								   'Callback', @(~,~)close(sd.dlg));
			b.Position(2) = sd.bMargY;
			b.Position(3:4) = sd.bSize;

			sd.scroll.updateOnResize(0);
			sd.createContent();
			sd.scroll.updateOnResize(1);

			if(sd.dlg.Position(4) > sd.scroll.panel.Position(4) + sd.bSpace)
				sd.dlg.Position(2) = sd.dlg.Position(2) + sd.dlg.Position(4);
				sd.dlg.Position(4) = sd.scroll.panel.Position(4) + sd.bSpace;
				sd.dlg.Position(2) = sd.dlg.Position(2) - sd.dlg.Position(4);
			end

			sd.onResize();
			sd.scroll.onResize();
			if(strcmp(sd.scroll.ySlider.Visible, 'on'))
				sd.dlg.Position(3) = min(sd.dMaxW, ...
										  sd.scroll.window.Position(3) + ...
										  sd.scroll.ySlider.Position(3));
			end
			sd.dlg.SizeChangedFcn = @(~,~)sd.onResize();
		end

		function ok = show(sd)
			sd.focusOk();
			sd.dlg.Visible = 'on';
			sd.scroll.setPosX(0);
			sd.scroll.setPosY(1);
			sd.debOk = 1;

			sd.ok = 0;
			waitfor(sd.dlg, 'Visible');
			ok = sd.ok;
		end

		function updateOnResize(sd, yes)
			if(yes)
				sd.dlg.SizeChangedFcn = @(~,~)sd.onResize();
				sd.onResize();
			else
				sd.dlg.SizeChangedFcn = '';
			end
		end
	end

	methods (Hidden)
		% ==========================================================%
		% The following methods may be overwritten by subclasses,
		% but are not abstract, to allow for being disregarded.
		function init(~); end
		function createContent(~); end
		function onOk(sd, done)
			if(nargin < 2 || done == 1)
				sd.ok = 1;
				close(sd.dlg);
			else
				sd.debOk = 1;
			end
		end
		% ==========================================================%
	end

	methods (Hidden)
		function onResize(sd)
			% The loop is necessary because of the interaction with
			% scrollpanel. There are better solutions, but it
			% works and this isn't that time sensitive.
			% (Nor is it a common situation.)
			sd.scroll.window.Position(3) = sd.dlg.Position(3);
			sd.bpan.Position(3) = sd.dlg.Position(3);
			sd.bpan.Children(1).Position(1) = sd.bpan.Position(3) - sd.bMargX;
			sd.bpan.Children(2).Position(1) = sd.bpan.Children(1).Position(1) - sd.bMargX;
			if(sd.dlg.Position(4) > sd.bSpace)
				if(sd.dlg.Position(4) >= sd.scroll.panel.Position(4) + sd.bSpace)
					loop = 1;
					while(loop)
						sl = sd.scroll.xSlider.Visible;
						if(strcmp(sl,'on'))
							sbar = min(sd.scroll.xSlider.Position(4), ...
								   sd.dlg.Position(4) - sd.scroll.panel.Position(4) - sd.bSpace);
						else
							sbar = 0;
						end
						winH = sd.scroll.panel.Position(4) + sbar;
						sd.scroll.window.Position(2) = sd.dlg.Position(4) - winH + 1;
						sd.scroll.window.Position(4) = winH;
						loop = ~strcmp(sd.scroll.xSlider.Visible,sl);
					end
				else
					sd.scroll.window.Position(2) = sd.bSpace+1;
					sd.scroll.window.Position(4) = sd.dlg.Position(4) - sd.bSpace;
				end
			else
				sd.scroll.window.Position([2,4]) = 1;
			end
			if(sd.minW < sd.maxW)
				loop = 1;
				while(loop)
					sl = sd.scroll.ySlider.Visible;
					if(strcmp(sl,'on'))
						width = sd.dlg.Position(3) - sd.scroll.ySlider.Position(3);
					else
						width = sd.dlg.Position(3);
					end
					sd.scroll.panel.Position(3) = min(max(width, sd.minW), sd.maxW);
					loop = ~strcmp(sd.scroll.ySlider.Visible,sl);
				end
			end
		end

		function onClose(sd)
			sd.dlg.Visible = 'off';
		end

		function onKey(sd, ev)
			switch ev.Key
				case 'return'
					if(~(strcmp(sd.dlg.CurrentObject.Type, 'uicontrol') ...
							&& strcmp(sd.dlg.CurrentObject.Style, ...
															'edit')) ...
							|| ~(ismember('control',ev.Modifier) ...
							|| ismember('shift',ev.Modifier)))
						sd.checkOk();
					end
					
				case 'escape'
					close(sd.dlg);
					
				otherwise
					if(~(strcmp(sd.dlg.CurrentObject.Type, 'uicontrol') ...
							&& ismember(sd.dlg.CurrentObject.Style, ...
							sd.NOTSCROLL)))
						sd.scroll.onKey(ev);
					end
			end
		end

		function onScroll(sd, ev)
			if(~(strcmp(sd.dlg.CurrentObject.Type, 'uicontrol') && ...
			   ismember(sd.dlg.CurrentObject.Style, sd.NOTSCROLL)))
				sd.scroll.onScroll(ev, sd.dlg.CurrentModifier);
			end
		end

		function focusOk(sd)
			uicontrol(sd.bpan.Children(1));
		end

		function checkOk(sd)
			if(sd.debOk)
				sd.debOk = 0;
				sd.onOk();
			end
		end
	end
end