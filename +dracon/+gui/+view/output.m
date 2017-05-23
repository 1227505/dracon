classdef output < dracon.gui.view
	%OUTPUT Summary of this class goes here
	%   Detailed explanation goes here
	
	properties (Constant, Transient)
		NAME = 'Output Manager';
	end
	
	properties (Constant, Transient, Hidden)
		DEFAULT_SHOW = 'off';
		SHORTKEY = 'U';
		POSITION = 2;

		ERR_DLG_TITLE	= 'Output ERROR';
		DATA_UNSUITABLE	= ['Data size doesn''t match ', ...
							'number of input nodes.'];
		DATA_INCOHERENT	= 'Data size incoherent.';
		NETS_MISMATCHING= 'Nets mismatching.';

        
		% Dialog default position
		DLG_MARGL		= 600;	% Margin to screen, left
		DLG_MARGT		= 100;	% Margin to screen, top
		DLG_WIDTH		= 400;	% Width
		DLG_HEIGHT		= 799;	% Height
		
		% Listbox
		OUT_MARGT		= 10;
		OUT_MARGL		= 10;
		OUT_MARGR		= 10;
		OUT_CONT_DEFAULT_HEIGHT = 350; % Default height of the upper area
		% Buttons
		SET_BUT_MARGT	= 5;
		SV_BUT_MARGT	= 5;
		BUT_MARGL		= 10;
		SET_BUT_MARGB	= 5;
		SV_BUT_MARGB	= 5;
		SET_BUT_WIDTH	= 80;
		SVF_BUT_WIDTH	= 80;
		SVB_BUT_WIDTH	= 150;
		BUT_HEIGHT		= 22;
		SET_BUT_TEXT	= 'Set Interpreter';
		SVF_BUT_TEXT	= 'Save to File';
		SVB_BUT_TEXT	= 'Save to Base Workspace';
		SV_BUT_MARG		= 10;
		
		SYNC_MARGL		= 10;
		SYNC_WIDTH		= 120;
		SYNC_TEXT		= 'Synchronise Input';
		SYNC_TOOLTIP	= 'Select origin data in the Input Manager.';
		
		INTER_TEXT_MARGL= 5;
		TEXT_HEIGHT		= 18;
		
		% Display window
		DISP_MARGL		= 10;
		DISP_MARGT		= 10;
		DISP_MARGB		= 10;
		DISP_MARGR		= 10;
		
		DO_SEP_HEIGHT	= 10;
		DO_SEP_DEFAULT_Y= 400;
		DO_SEP_COLOR	= [.85 .85 .85];
		
		% Sync
		SYNC_PERIOD		= 1/40;
	end
	
	properties (Hidden)
		outBox;				% Listbox for output
		setIntButton;		% Set interpreter button
		intText;			% Text displaying current interpreter
		saveFButton;		% Save to file button
		saveBButton;		% Save to base workspace button
		outContainer;		% Panel containing the above
		
		dispSP;				% Scrollpanel to display selected output
		dispContainer;		% Panel containing dispSP (adding margin)
		doSplit;			% Split between display & listbox
		
		selOutput	= 0;	% Topmost selected output
		
		interpreter;		% Current interpreter
		
		input;				% Input Manager
		syncInput;			% If selected, the value of inputBox of the 
							% input manager is synchronised with the 
							% value of outBox
		syncTimer;			% Timer to do that
		synced;				% Current change already synced
	end
	
	methods
		function o = output(drcn)
			o@dracon.gui.view(drcn);
			import dracon.gui.util.split
			
			o.interpreter = dracon.output.raw(drcn);
			o.interpreter.refresh();
			
			o.fig = figure('integerhandle', 'off', ...
						'menubar', 'none', ...
						'userdata', drcn, ...
						'dockcontrols', 'off', ...
						'visible', 'off', ...
						'Color', o.DO_SEP_COLOR, ...
						'closeRequestFcn', @(~,~)o.close(), ...
						'sizeChangedFcn', @(~,~)o.figSizeChanged());
			o.fig.OuterPosition(4) = o.DLG_HEIGHT;
			
			o.outContainer = uipanel(o.fig, ...
						'BorderType', 'none', ...
						'Units', 'pixel', ...
						'sizeChangedFcn', @(~,~)o.outContSizeChanged());
			o.outContainer.Position(2) = o.DO_SEP_DEFAULT_Y + ...
											o.DO_SEP_HEIGHT + 1;
			o.outContainer.Position(4) = o.OUT_CONT_DEFAULT_HEIGHT;
			
			o.setIntButton = uicontrol(o.outContainer, ...
									'Style', 'pushbutton', ...
									'TooltipString', 'Ctrl+I', ...
									'String', o.SET_BUT_TEXT , ...
									'Callback', @(~,~)o.setInterpreter());
			o.setIntButton.Position(1) = o.BUT_MARGL + 1;
			o.setIntButton.Position(2) = o.outContainer.Position(3) - ...
										o.BUT_HEIGHT - o.SET_BUT_MARGT + 1;
			o.setIntButton.Position(3) = o.SET_BUT_WIDTH;
			o.setIntButton.Position(4) = o.BUT_HEIGHT;
			
			o.intText = uicontrol(o.outContainer, ...
								'Style', 'text', ...
								'String', o.interpreter.name);
			o.intText.Position(1) = o.BUT_MARGL + 1 + o.SET_BUT_WIDTH + ...
									o.INTER_TEXT_MARGL;
			o.intText.Position(2) = o.setIntButton.Position(2);
			o.intText.Position(3) = o.intText.Extent(3);
			o.intText.Position(4) = o.TEXT_HEIGHT;
			
			o.outBox = uicontrol(o.outContainer, ...
								'Style', 'ListBox', ...
								'Callback', @(~,~)o.outputClick(), ...
								'Max', 2, ...
								'Value', []);
			o.outBox.Position(1) = o.OUT_MARGL;
			o.outBox.Position(2) = o.SV_BUT_MARGB + o.SV_BUT_MARGT + ...
									o.BUT_HEIGHT + 1;
										
			o.saveFButton = uicontrol(o.outContainer, ...
									'Style', 'pushbutton', ...
									'TooltipString', 'Ctrl+S', ...
									'String', o.SVF_BUT_TEXT , ...
									'Position', [o.BUT_MARGL + 1, ...
												o.SV_BUT_MARGB + 1, ...
												o.SVF_BUT_WIDTH, ...
												o.BUT_HEIGHT], ...
									'Enable', 'off', ...
									'Callback', @(~,~)o.saveToFile());
			o.saveBButton = uicontrol(o.outContainer, ...
									'Style', 'pushbutton', ...
									'TooltipString', 'Ctrl+Shift+S', ...
									'String', o.SVB_BUT_TEXT , ...
									'Position', [0, ...
												o.SV_BUT_MARGB + 1, ...
												o.SVB_BUT_WIDTH, ...
												o.BUT_HEIGHT], ...
									'Enable', 'off', ...
									'Callback', @(~,~)o.saveToWorkspace());
			o.saveBButton.Position(1) = o.saveFButton.Position(1) + ...
										o.saveFButton.Position(3) + ...
										o.SV_BUT_MARG;
			
			o.syncInput = uicontrol(o.outContainer, ...
									'Style', 'Checkbox', ...
									'TooltipString', o.SYNC_TOOLTIP, ...
									'String', o.SYNC_TEXT, ...
									'Position', [0, ...
												o.SV_BUT_MARGB + 1, ...
												o.SYNC_WIDTH, ...
												o.BUT_HEIGHT], ...
									'Callback', @(~,~)o.syncCheck());
			o.syncInput.Position(1) = o.saveBButton.Position(1) + ...
										o.saveBButton.Position(3) + ...
										o.SYNC_MARGL;
									
			o.dispContainer = uipanel(o.fig, ...
						'BorderType', 'none', ...
						'Units', 'pixel', ...
						'sizeChangedFcn', @(~,~)o.dContSizeChanged());
			o.dispContainer.Position(4) = o.DO_SEP_DEFAULT_Y;
			o.dispSP = dracon.gui.util.scrollpanel(o.dispContainer, ...
						'Units', 'pixel');
			o.dispSP.window.Position(1) = o.DISP_MARGL + 1;
			o.dispSP.window.Position(2) = o.DISP_MARGB + 1;
			o.dispSP.panel.Position(3:4) = 0;
			o.dispSP.stickUp = 0;
			o.dispSP.stickLeft = 0;
			o.doSplit = split(o.dispContainer, ...
								o.outContainer, ...
								o.fig, ...
								split.HORIZONTAL);
			
			o.fig.WindowButtonUpFcn = @(~,~)o.doSplit.onButtonUp();
			o.fig.WindowButtonMotionFcn = @(~,~)o.doSplit.onMove();
			o.fig.WindowKeyPressFcn = @(~,ev)o.onKey(ev);
			o.fig.WindowScrollWheelFcn = @(~, ev)o.onScroll(ev);
			
			o.input = drcn.getView('input');
			drcn.addlistener('NetsRun', @(~,~)o.onRun());
			drcn.addlistener('NetsChanged', @(~,~)o.onRun());
			drcn.addlistener('ValuesChanged', @(~,~)o.onRun());
			
			o.syncTimer = timer();
			o.syncTimer.Period = o.SYNC_PERIOD;
			o.syncTimer.TimerFcn = @(~,~)o.sync();
			o.syncTimer.ExecutionMode = 'fixedSpacing';
		end
		
		function data = getSelectedData(o)
			data = o.interpreter.getData(o.outBox.Value);
		end
		
		function highlightData(o, which, hll, hlr)
			text = o.interpreter.getText(which);
			for k = 1:numel(which)
				text{k} = [hll, text{k}, hlr];
			end
			o.outBox.String(which) = text;
		end
		
		function clearHighlight(o)
			o.outBox.String = o.interpreter.getText();
		end
	end  
	
	methods (Hidden)
		function figSizeChanged(o)
			o.outContainer.Position(3) = o.fig.Position(3);
			o.dispContainer.Position(3) = o.fig.Position(3);
			
			if(o.fig.Position(4) >= o.DO_SEP_HEIGHT)
				dy = o.fig.Position(4) - o.outContainer.Position(2) - ...
					o.outContainer.Position(4) + 1;

				if(o.dispContainer.Position(4) < -dy)
					if(o.dispContainer.Position(4) > 0)
						o.outContainer.Position(2) =  ...
							o.outContainer.Position(2) - ...
							o.dispContainer.Position(4);
						dy = dy + o.dispContainer.Position(4);
						o.dispContainer.Position(4) = 0;
					end
					o.outContainer.Position(4) = dy + ...
						o.outContainer.Position(4);
				else
					if(dy > 0 && o.outContainer.Position(4) < ...
							o.OUT_CONT_DEFAULT_HEIGHT)
						o.outContainer.Position(4) = dy + ...
							o.outContainer.Position(4);
					else
						o.dispContainer.Position(4) = dy + ...
							o.dispContainer.Position(4);
						o.outContainer.Position(2) = dy + ...
							o.outContainer.Position(2);
					end
				end
			end
		end
		
		function outContSizeChanged(o)
			o.setIntButton.Position(2) = o.outContainer.Position(4) - ...
										o.BUT_HEIGHT - o.SET_BUT_MARGT + 1;
			o.intText.Position(2) = o.setIntButton.Position(2);
			o.outBox.Position(3) = o.outContainer.Position(3) - ...
									o.OUT_MARGL - o.OUT_MARGR;
								
			o.outBox.Position(4) = max(0, o.setIntButton.Position(2) - ...
								o.outBox.Position(2) - o.SET_BUT_MARGB);
		end
		
		function dContSizeChanged(o)
			ns(1) = o.dispContainer.Position(3) - ...
				o.DISP_MARGL - o.DISP_MARGR;
			ns(2) = o.dispContainer.Position(4) - ...
				o.DISP_MARGB - o.DISP_MARGT;
			o.dispSP.window.Position(3:4) = max(0, ns);
		end
		
		function onKey(o, ev)
			switch ev.Key
				case 'escape'
					o.close();
			end
			
			if(ismember('control', ev.Modifier))
				switch ev.Key
					case 'i'
						o.setInterpreter();
						
					case 's'
						if(~isempty(o.outBox.Value))
							if(ismember('shift', ev.Modifier))
								o.saveToWorkspace();
							else
								o.saveToFile();
							end
						end
				end
			end
			
			if(isempty(o.fig.CurrentObject) || ...
					o.fig.CurrentObject ~= o.dispContainer)
				o.dispSP.onKey(ev);
			end
		end
		
		function onScroll(o, ev)
			if(isempty(o.fig.CurrentObject) || ...
					o.fig.CurrentObject ~= o.dispContainer)
				o.dispSP.onScroll(ev, o.fig.CurrentModifier);
			end
		end
		
		function onRun(o)
			o.interpreter.refresh();
			
			o.outBox.Value = [];
			o.outBox.String = o.interpreter.getText();
			o.intText.String = o.interpreter.name;
			o.intText.Position(3) = o.intText.Extent(3);
			o.outBox.Value = 1:numel(o.outBox.String);
			o.outputClick();
		end
		
		function outputClick(o)
			if(isempty(o.outBox.Value))
				if(o.selOutput > 0)
					o.interpreter.deselect(o.dispSP.panel, o.selOutput);
					o.dispSP.panel.Position(3:4) = 0;
					o.selOutput = 0;
				end
				o.saveBButton.Enable = 'off';
				o.saveFButton.Enable = 'off';
				
			elseif(o.selOutput == 0)
				o.selOutput = o.outBox.Value(1);
				o.interpreter.select(o.dispSP.panel, o.selOutput);
				o.saveBButton.Enable = 'on';
				o.saveFButton.Enable = 'on';
				
			elseif(o.selOutput ~= o.outBox.Value(1))
				o.interpreter.deselect(o.dispSP.panel, o.selOutput);
				o.dispSP.panel.Position(3:4) = 0;
				
				o.selOutput = o.outBox.Value(1);
				
				o.interpreter.select(o.dispSP.panel, o.selOutput);
				o.saveBButton.Enable = 'on';
				o.saveFButton.Enable = 'on';
			end
			
			o.synced = 0;
		end
		
		function syncCheck(o)
			if(o.syncInput.Value)
				o.synced = 0;
				start(o.syncTimer);
			else
				stop(o.syncTimer);
			end
		end
		
		function sync(o)
			if(~o.synced)
				o.input.selectRunData(o.outBox.Value);
				o.synced = 1;
			end
		end
		
		function setInterpreter(o)
			si = o.drcn.getDlg('setinterpreter');
			if(si.show())
				o.interpreter = si.newInterpreter;
			end
			if(o.selOutput > 0)
				o.interpreter.deselect(o.dispSP.panel, o.selOutput);
				o.selOutput = 0;
			end
			o.onRun();
		end
		
		function saveToFile(o)
			o.interpreter.saveToFile(o.outBox.Value);
		end
		
		function saveToWorkspace(o)
			dlg = o.drcn.getDlg('getvarname');
			if(dlg.show())
				assignin('base', dlg.newName, ...
					o.interpreter.getData(o.outBox.Value));
			end
		end
		
		function close(o)
			if(o.syncInput.Value)
				stop(o.syncTimer);
				o.syncInput.Value = 0;
			end
			dracon.gui.util.toggleView(o.drcn, 'output')
		end
	end
	
	methods (Static)
		function pos = getDefaultPos()
			import dracon.gui.view.output;
			pos = get(groot, 'ScreenSize');
			pos(1) = pos(1) + output.DLG_MARGL;
			pos(2) = max(pos(2), pos(2) + pos(4) ...
				- output.DLG_MARGT - output.DLG_HEIGHT);
			pos(3) = min(output.DLG_WIDTH, pos(3) - pos(1));
			pos(4) = output.DLG_HEIGHT;
			pos = max(pos, 1);
		end
	end
end

