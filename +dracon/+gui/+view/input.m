classdef input < dracon.gui.view
	%INPUT Summary of this class goes here
	%   Detailed explanation goes here
	
	properties (Constant, Transient)
		NAME = 'Input Manager';
	end
	
	properties (Constant, Transient, Hidden)
		DEFAULT_SHOW = 'off';
		SHORTKEY = 'I';
		POSITION = 1;

		ERR_DLG_TITLE	= 'Input ERROR';
		DATA_UNSUITABLE	= ['Data size doesn''t match ', ...
							'number of input nodes.'];
		DATA_INCOHERENT	= 'Data size incoherent.';
		NETS_MISMATCHING= 'Nets mismatching.';

        
		% Dialog default position
		DLG_MARGL		= 100;	% Margin to screen, left
		DLG_MARGT		= 100;	% Margin to screen, top
		DLG_WIDTH		= 500;	% Width
		DLG_HEIGHT		= 799;	% Height
		
		% Listboxes
		INBOX_DEFAULT_WIDTH = 200;
		SI_MARGT		= 10;
		SI_MARGL		= 10;
		SI_MARGR		= 10;
		SI_SEP_WIDTH	= 10;	% Width of the divider between the boxes
		SI_SEP_DEFAULT_X= 301;	% Default position of the seperator
		SI_SEP_COLOR	= [.85 .85 .85]; % Color of the seperator
		SI_CONT_DEFAULT_HEIGHT = 350; % Default height of the upper area
		% Source add button
		BUT_MARGT		= 5;
		S_BUT_MARGL		= 10;
		BUT_MARGB		= 5;
		S_BUT_WIDTH		= 80;
		R_BUT_WIDTH		= 40;
		BUT_HEIGHT		= 22;
		S_BUT_TEXT		= 'Add Source';
		R_BUT_TEXT		= 'Run';
		SR_BUT_MARG		= 10;
		
		% Display window
		DISP_MARGL		= 10;
		DISP_MARGT		= 10;
		DISP_MARGB		= 10;
		DISP_MARGR		= 10;
		
		DSI_SEP_HEIGHT	= 10;
		DSI_SEP_DEFAULT_Y = 400;
		DSI_SEP_COLOR = [.85 .85 .85];
	end
	
	properties (Hidden)
		sourceBox;			% Listbox for sources
		inputBox;			% Listbox for input
		siSplit;			% Split between the listboxes
		siPanel;			% Panel containing the listboxes
		sAddButton;			% Add Source button
		runButton;			% Run button
		siContainer;		% Panel containing the above
		
		dispSP;				% Scrollpanel to display selected input
		dispContainer;		% Panel containing dispSP (adding margin)
		dsiSplit;			% Split between display & listboxes
		
		sources;			% dracon.input.* instances
		selSources;			% Selected sources
		
		selInput	= 0;	% Topmost selected input
		
		runData		= {};	% Data used for last run
	end
	
	methods
		function in = input(drcn)
			in@dracon.gui.view(drcn);
			import dracon.gui.util.split
			
			in.fig = figure('integerhandle', 'off', ...
						'Menubar', 'none', ...
						'Userdata', drcn, ...
						'Dockcontrols', 'off', ...
						'Visible', 'off', ...
						'Color', in.DSI_SEP_COLOR, ...
						'closeRequestFcn', @(~,~)dracon.gui.util. ...
										toggleView(drcn, 'input'), ...
						'sizeChangedFcn', @(~,~)in.figSizeChanged());
			in.fig.OuterPosition(4) = in.DLG_HEIGHT;
			
			in.siContainer = uipanel(in.fig, ...
						'BorderType', 'none', ...
						'Units', 'pixel', ...
						'sizeChangedFcn', @(~,~)in.siContSizeChanged());
			in.siContainer.Position(2) = in.DSI_SEP_DEFAULT_Y + ...
											in.DSI_SEP_HEIGHT + 1;
			in.siContainer.Position(4) = in.SI_CONT_DEFAULT_HEIGHT;
			
			in.siPanel = uipanel(in.siContainer, ...
						'BorderType', 'none', ...
						'Units', 'pixel', ...
						'BackgroundColor', in.SI_SEP_COLOR);
			in.siPanel.Position(1) = in.SI_MARGL;
			in.siPanel.Position(2) = in.BUT_MARGB + in.BUT_HEIGHT + ...
									in.BUT_MARGT + 1;
			
			in.sourceBox = uicontrol(in.siPanel, ...
						'Style', 'ListBox', ...
						'Callback', @(~,~)in.sourceClick(), ...
						'Max', 2, ...
						'Value', []);
			in.sourceBox.Position(1:2) = 1;
			in.sourceBox.Position(3) = in.SI_SEP_DEFAULT_X - 1;
										
			in.inputBox = uicontrol(in.siPanel, ...
						'Style', 'ListBox', ...
						'Callback', @(~,~)in.inputClick(), ...
						'Max', 2, ...
						'Value', []);
			in.inputBox.Position(1) = in.SI_SEP_DEFAULT_X + ...
										in.SI_SEP_WIDTH;
			in.inputBox.Position(2) = 1;
			in.inputBox.Position(3) = in.siPanel.Position(3) + 1 - ...
										in.inputBox.Position(1);
			in.sAddButton = uicontrol(in.siContainer, ...
						'Style', 'pushbutton', ...
						'String', in.S_BUT_TEXT , ...
						'Position', [in.S_BUT_MARGL + 1, ...
									in.BUT_MARGB + 1, ...
									in.S_BUT_WIDTH, ...
									in.BUT_HEIGHT], ...
						'TooltipString', 'Ctrl+N', ...
						'Callback', @(~,~)in.addSource());
			in.runButton = uicontrol(in.siContainer, ...
						'Style', 'pushbutton', ...
						'String', in.R_BUT_TEXT , ...
						'Position', [0, ...
									in.BUT_MARGB + 1, ...
									in.R_BUT_WIDTH, ...
									in.BUT_HEIGHT], ...
						'Enable', 'off', ...
						'TooltipString', 'Ctrl+R', ...
						'Callback', @(~,~)in.runAll());
			in.runButton.Position(1) = in.sAddButton.Position(1) + ...
										in.sAddButton.Position(3) + ...
										in.SR_BUT_MARG;
							   
			in.siSplit = split(in.sourceBox, in.inputBox, in.fig);
			
			
			in.dispContainer = uipanel(in.fig, ...
						'BorderType', 'none', ...
						'Units', 'pixel', ...
						'sizeChangedFcn', @(~,~)in.dContSizeChanged());
			in.dispContainer.Position(4) = in.DSI_SEP_DEFAULT_Y;
			in.dispSP = dracon.gui.util.scrollpanel(in.dispContainer, ...
						'Units', 'pixel');
			in.dispSP.window.Position(1) = in.DISP_MARGL + 1;
			in.dispSP.window.Position(2) = in.DISP_MARGB + 1;
			in.dispSP.panel.Position(3:4) = 0;
			in.dispSP.stickUp = 0;
			in.dispSP.stickLeft = 0;
			in.dsiSplit = split(in.dispContainer, ...
								in.siContainer, ...
								in.fig, ...
								split.HORIZONTAL);
			
			in.fig.WindowButtonUpFcn = @(~,~)in.onButtonUp();
			in.fig.WindowButtonMotionFcn = @(~,~)in.onMove();
			in.fig.WindowKeyPressFcn = @(~,ev)in.onKey(ev);
			in.fig.WindowScrollWheelFcn = @(~, ev)in.onScroll(ev);
		end
		
		function [data, rdata] = getSelectedData(in)
			data = [];
			sel = in.inputBox.Value;
			rdata = cell(numel(in.selSources), 1);
			try
				for k = 1:numel(in.selSources)
					s = in.sources{in.selSources(k)};
					rk = in.selSources(k);
					rdata{rk} = sel(sel <= s.dataNum);
					if(~isempty(rdata{rk}))
						data = [data, s.getData(rdata{rk})]; ...
																%#ok<AGROW>
					end
					sel = sel(sel > s.dataNum) - s.dataNum;
				end
			catch ex
				switch ex.identifier
					case 'MATLAB:catenate:dimensionMismatch'
						throw(MException( ...
							'dracon:getSelectedData:dataIncoherent', ...
							in.DATA_INCOHERENT));
						
					otherwise
						rethrow(ex);
				end
			end
		end
		
		function data = getTopSelectedData(in)
			if(in.selInput > 0)
				[snum, num] = in.getSourceFromInput(in.selInput);
				data = in.sources{snum}.getData(num);
			else
				data = [];
			end
		end
		
		function selectRunData(in, which)
			selIn = [];
			selS = [];
			add = 0;
			sub = 0;
			for k = 1:numel(in.runData)
				rd = in.runData{k};
				if(~isempty(rd))
					if(rd(1) > 0)
						rl = numel(rd);
						nsel = rd(which(which <= rl)) + add;
						selIn = [selIn, nsel];	%#ok<AGROW>
						selS = [selS, k - sub];%#ok<AGROW>
						rd = -rl;
						add = add + in.sources{k - sub}.dataNum;
					else
						sub = sub + 1;
					end
					which = which + rd(1);
					which = which(which > 0);
				end
			end
			
			in.sourceBox.Value = selS;
			in.sourceClick();
			in.inputBox.Value = selIn;
			in.inputClick();
		end
	end
	
	methods (Hidden)
		function figSizeChanged(in)
			in.siContainer.Position(3) = in.fig.Position(3);
			in.dispContainer.Position(3) = in.fig.Position(3);
			
			if(in.fig.Position(4) >= in.DSI_SEP_HEIGHT)
				dy = in.fig.Position(4) - in.siContainer.Position(2) - ...
					in.siContainer.Position(4) + 1;

				if(in.dispContainer.Position(4) < -dy)
					if(in.dispContainer.Position(4) > 0)
						in.siContainer.Position(2) =  ...
							in.siContainer.Position(2) - ...
							in.dispContainer.Position(4);
						dy = dy + in.dispContainer.Position(4);
						in.dispContainer.Position(4) = 0;
					end
					in.siContainer.Position(4) = dy + ...
						in.siContainer.Position(4);
				else
					if(dy > 0 && in.siContainer.Position(4) < ...
							in.SI_CONT_DEFAULT_HEIGHT)
						in.siContainer.Position(4) = dy + ...
							in.siContainer.Position(4);
					else
						in.dispContainer.Position(4) = dy + ...
							in.dispContainer.Position(4);
						in.siContainer.Position(2) = dy + ...
							in.siContainer.Position(2);
					end
				end
			end
		end
		
		function siContSizeChanged(in)
			ns(1) = in.siContainer.Position(3) - ...
				in.SI_MARGL - in.SI_MARGR;
			ns(2) = in.siContainer.Position(4) - ...
				in.SI_MARGT - in.siPanel.Position(2) + 1;
			dx = ns(1) - in.siPanel.Position(3);
			ns = max(ns, 0);
			in.siPanel.Position(3:4) = ns;
			
			in.siSplit.parMarg(1) = in.siPanel.Position(1) - 1;
			in.siSplit.parMarg(2) = in.siContainer.Position(2) - 1 + ...
									in.siPanel.Position(2) - 1;
			
			in.sourceBox.Position(4) = ns(2);
			in.inputBox.Position(4) = ns(2);

			if(in.sourceBox.Position(3) < -dx)
				if(in.sourceBox.Position(3) > 0)
					in.inputBox.Position(1) =  ...
						in.inputBox.Position(1) - ...
						in.sourceBox.Position(3);
					dx = dx + in.sourceBox.Position(3);
					in.sourceBox.Position(3) = 0;
				end
				in.inputBox.Position(3) = dx + ...
					in.inputBox.Position(3);
			else
				if(dx > 0 && in.inputBox.Position(3) < ...
						in.INBOX_DEFAULT_WIDTH)
					in.inputBox.Position(3) = dx + ...
						in.inputBox.Position(3);
				else
					in.sourceBox.Position(3) = dx + ...
						in.sourceBox.Position(3);
					in.inputBox.Position(1) = dx + ...
						in.inputBox.Position(1);
				end
			end
		end
		
		function dContSizeChanged(in)
			ns(1) = in.dispContainer.Position(3) - ...
				in.DISP_MARGL - in.DISP_MARGR;
			ns(2) = in.dispContainer.Position(4) - ...
				in.DISP_MARGB - in.DISP_MARGT;
			in.dispSP.window.Position(3:4) = max(0, ns);
		end
		
		function onButtonUp(in)
			in.siSplit.onButtonUp();
			in.dsiSplit.onButtonUp();
		end
		
		function onMove(in)
			in.siSplit.onMove();
			in.dsiSplit.onMove();
		end
		
		function onKey(in, ev)
			switch ev.Key
				case 'escape'
					dracon.gui.util.toggleView(in.drcn, 'input')
					
				case 'delete'
					if(in.fig.CurrentObject == in.sourceBox && ...
							~isempty(in.sourceBox.Value))
						val = in.sourceBox.Value;
						in.sourceBox.Value = [];
						in.sourceClick();
						pos = 1;
						for k = 1:min(numel(in.runData), max(val))
							num = numel(in.runData{k});
							if((num <= 0 || in.runData{k}(1) > 0) && ...
									k == val(pos))
								pos = pos + 1;
								in.runData{k} = -num;
							end
						end
						delete(in.sources{val});
						in.sources(val) = [];
						in.sourceBox.String(val) = [];
					end
			end
			
			if(ismember('control', ev.Modifier))
				switch ev.Key
					case 'r'
						if(~isempty(in.inputBox.Value))
							in.runAll();
						end
						
					case 'n'
						in.addSource();
				end
			end
			
			if(isempty(in.fig.CurrentObject) || ...
					(in.fig.CurrentObject ~= in.inputBox && ...
					in.fig.CurrentObject ~= in.sourceBox))
				in.dispSP.onKey(ev);
			end
		end
		
		function onScroll(in, ev)
			if(isempty(in.fig.CurrentObject) || ...
					(in.fig.CurrentObject ~= in.inputBox && ...
					in.fig.CurrentObject ~= in.sourceBox))
				in.dispSP.onScroll(ev, in.fig.CurrentModifier);
			end
		end
		
		function addSource(in)
			as = in.drcn.getDlg('addsource');
			if(as.show())
				ns = as.newSource;
				in.sources = [in.sources, {ns}];
				in.sourceBox.String = [in.sourceBox.String; {ns.source}];
			end
		end
		
		function sourceClick(in)
			add = [setdiff(in.sourceBox.Value, in.selSources), 0];
			rm = [setdiff(in.selSources, in.sourceBox.Value), 0];
			
			text = in.inputBox.String;
			val = in.inputBox.Value;
			pr = 1;
			ps = 0;
			for k = 1:numel(in.selSources)
				num = in.sources{in.selSources(k)}.dataNum;
				if(in.selSources(k) == rm(pr))
					text(ps+1:ps+num) = [];
					val(val > ps & val <= ps+num) = [];
					val(val > ps+num) = val(val > ps+num) - num;
					if(in.selInput > ps+num)
						in.selInput = in.selInput - num;
					elseif(in.selInput > ps)
						in.selInput = 0;
					end
					pr = pr + 1;
				else
					ps = ps + num;
				end
			end
			
			pa = 1;
			ps = 0;
			for k = 1:numel(in.sourceBox.Value)
				num = in.sources{in.sourceBox.Value(k)}.dataNum;
				if(in.sourceBox.Value(k) == add(pa))
					text = [text(1:ps); ...
							in.sources{add(pa)}.text; ...
							text(ps+1:end)];
					pa = pa + 1;
					val(val > ps) = val(val > ps) + num;
					if(in.selInput > ps)
						in.selInput = in.selInput + num;
					end
				end
				ps = ps + num;
			end
			
			if(~isempty(in.inputBox.Value))
				dn = in.inputBox.Value(1);
				[dsn, dn] = in.getSourceFromInput(dn);
				if(ismember(dsn, rm))
					in.sources{dsn}.deselect(in.dispSP.panel, dn);
					if(~isempty(val))
						[dsn, dn] = in.getSourceFromInput(val(1));
						in.sources{dsn}.select(in.dispSP.panel, dn);
					end
				end
			end
			
			in.inputBox.Value = val;
			in.inputBox.String = text;
			
			in.selSources = in.sourceBox.Value;
			
			if(isempty(val))
				in.runButton.Enable = 'off';
				in.dispSP.panel.Position(3:4) = 0;
				in.dispSP.onResize();
			else
				in.runButton.Enable = 'on';
			end
		end
		
		function inputClick(in)
			if(isempty(in.inputBox.Value))
				if(in.selInput > 0)
					[dsn, dn] = in.getSourceFromInput(in.selInput);
					in.sources{dsn}.deselect(in.dispSP.panel, dn);
					in.dispSP.panel.Position(3:4) = 0;
					in.dispSP.onResize();
					in.selInput = 0;
				end
				in.runButton.Enable = 'off';
				
			elseif(in.selInput == 0)
				in.selInput = in.inputBox.Value(1);
				[dsn, dn] =in.getSourceFromInput(in.selInput);
				in.sources{dsn}.select(in.dispSP.panel, dn);
				in.runButton.Enable = 'on';
				
			elseif(in.selInput ~= in.inputBox.Value(1))
				[dsn, dn] =in.getSourceFromInput(in.selInput);
				in.sources{dsn}.deselect(in.dispSP.panel, dn);
				in.dispSP.panel.Position(3:4) = 0;
				in.dispSP.onResize();
				
				in.selInput = in.inputBox.Value(1);
				
				[dsn, dn] =in.getSourceFromInput(in.selInput);
				in.sources{dsn}.select(in.dispSP.panel, dn);
				in.runButton.Enable = 'on';
			end
		end
		
		function runAll(in)
			try
				[data, rdata] = in.getSelectedData();
				in.drcn.run(data);
				in.runData = rdata;
			catch ex
				switch ex.identifier
					case 'MATLAB:runSingle:incorrectNumrows'
						msg = in.DATA_UNSUITABLE;
						
					case 'MATLAB:run:incorrectNumrows'
						if(strcmp(ex.message(22:24), ' 1,'))
							msg = in.DATA_UNSUITABLE;
						else
							msg = in.NETS_MISMATCHING;
						end
						
					otherwise
						msg = ex.message;
				end
				in.drcn.error('', in.ERR_DLG_TITLE, msg);
			end
		end
		
		function [snum, num] = getSourceFromInput(in, num)
			snum = [];
			for k = 1:numel(in.selSources)
				snum = in.selSources(k);
				if(num <= in.sources{snum}.dataNum)
					return;
				end
				num = num - in.sources{snum}.dataNum;
			end
		end
	end
	
	methods (Static)
		function pos = getDefaultPos()
			import dracon.gui.view.input;
			pos = get(groot, 'ScreenSize');
			pos(1) = pos(1) + input.DLG_MARGL;
			pos(2) = max(pos(2), pos(2) + pos(4) ...
				- input.DLG_MARGT - input.DLG_HEIGHT);
			pos(3) = min(input.DLG_WIDTH, pos(3) - pos(1));
			pos(4) = input.DLG_HEIGHT;
			pos = max(pos, 1);
		end
	end
end

