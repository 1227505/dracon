classdef training < dracon.gui.view
	%TRAINING Summary of this class goes here
	%   Detailed explanation goes here
	
	properties (Constant, Transient)
		NAME = 'Training Manager';
	end
	
	properties (Constant, Transient, Hidden)
		DEFAULT_SHOW = 'off';
		SHORTKEY = 'T';
		POSITION = 3;

		ERR_DLG_TITLE	= 'Training ERROR';
		DATA_UNSUITABLE	= ['Data size doesn''t match ', ...
							'number of input nodes.'];
		DATA_INCOHERENT	= 'Data size incoherent.';
		NETS_MISMATCHING= 'Nets mismatching.';
		TOO_FEW_SOURCES	= 'Not enough sources.';
		TOO_FEW_INPUT	= 'Not enough input data.';
		INEQUAL_SELECT	= ['Number of selected outputs (%d) and ', ...
							'desired outputs (%d) inequal.'];
		INEQUAL_DATA	= ['Data size of selected outputs (%d) and ', ...
							'desired outputs (%d) inequal.'];
		
		ADD_TEXT		= 'Add Source';
		ADD_TOOLTIP		= '<html><i>CTRL+N</i></html>';
		
		TRAIN_TEXT		= 'Train';
		TRAIN_TOOLTIP	= '<html><i>CTRL+T</i></html>';
		
		SELECT_TEXT		= 'Select as Input';
		SELECT_TOOLTIP	= ['<html><i>CTRL+S</i><br>', ...
							'Attempt to select data in the same ', ...
							'position as in the Input Manager.'];
		
		RATE_TEXT		= 'Learning rate';
		RATE_TOOLTIP	= ['<html><i>Non-negative real value</i><br>', ...
							'Multiplicator to the adjustments of ', ...
							'weights and biases.<br>', ...
							'Batch size is taken ', ...
							'into account automatically.</html>'];
		RATE_DEFAULT	= '0.5';
		RATE_ERROR		= 'Batch must be a non-negative integer.';
		
		BATCH_TEXT		= 'Batch size';
		BATCH_TOOLTIP	= ['<html><i>Non-negative integer</i><br>', ...
							'How many input values are used at ', ...
							'once for an adjustment.<br>The makeup ', ...
							'of each batch is randomised every epoch.', ...
							'<br>Set 0 or a value greater or equal ', ...
							'to the number of input values to use ', ...
							'all input values at once.</html>'];
		BATCH_DEFAULT	= '1';
		BATCH_ERROR		= 'Batch must be a non-negative integer.';
		
		STOP_TEXT		= 'Desired error';
		STOP_TOOLTIP	= ['<html><i>Non-negative real value</i><br>', ...
							'Training is stopped when this or a ', ...
							'lower error value is reached.</html>'];
		STOP_DEFAULT	= '0';
		STOP_ERROR		= ['The desired error must be a non-negative ', ...
							'real value.'];
		
		EPOCHS_TEXT		= 'Number of epochs';
		EPOCHS_TOOLTIP	= ['<html><i>Positive finite integer</i><br>', ...
							'Maximal number of epochs the net ', ...
							'is trained for, or the absolute number, ', ...
							'if ''stop'' is 0.<br>', ...
							'The net is adjusted once with each input ', ...
							'value per epoch.</html>'];
		EPOCHS_DEFAULT	= '50';
		EPOCHS_ERROR	= 'Epochs must be a positive finite integer.';

		MATCH_BUT_TEXT	= 'Match Data';
		MATCH_TOOLTIP	= ['<html><i>CTRL+M</i><br>', ...
							'Compares selected output values ', ...
							'(Output Manager) to selected desired ', ...
							'output values (Training Manager).<br>', ...
							'Mismatching values are highlighted with ', ...
							'>>> in the Output Manager.<br>', ...
							'If no values are selected, highlights ', ...
							'are cleared.</html>'];
		MATCH_TEXT		= '%d/%d (%.3f%%)';
		HIGHLIGHT_LEFT	= '>>> ';
		HIGHLIGHT_RIGHT	= '';
        
		% Dialog default position
		DLG_MARGR		= 100;	% Margin to screen, right
		DLG_MARGT		= 100;	% Margin to screen, top
		DLG_WIDTH		= 500;	% Width
		DLG_HEIGHT		= 809;	% Height
		
		% Listboxes
		INBOX_DEFAULT_WIDTH = 200;
		OSI_MARGT		= 10;
		OSI_MARGL		= 10;
		OSI_MARGR		= 10;
		OSI_MARGB		= 10;
		
		SI_SEP_WIDTH	= 10;	% Width of the divider between the boxes
		SI_SEP_DEFAULT_X= 301;	% Default position of the seperator
		SI_SEP_COLOR	= [.85 .85 .85];% Colour of the seperator
		SI_CONT_DEFAULT_HEIGHT = 350;	% Default height of the si area
		UPPER_CONT_DEFAULT_HEIGHT = 520;% Default height of the upper area
		% Source add button
		BUT_MARGT		= 5;
		S_BUT_MARGL		= 0;
		BUT_MARGB		= 5;
		S_BUT_WIDTH		= 80;
		T_BUT_WIDTH		= 50;
		SL_BUT_WIDTH	= 100;
		BUT_HEIGHT		= 22;
		ST_BUT_MARG		= 10;
		TSL_BUT_MARG	= 10;
		
		% Display window
		DISP_MARGL		= 10;
		DISP_MARGT		= 10;
		DISP_MARGB		= 10;
		DISP_MARGR		= 10;
		
		DSI_SEP_HEIGHT	= 10;
		DSI_SEP_DEFAULT_Y = 140;
		DSI_SEP_COLOR	= [.85 .85 .85];
		
		% Options
		OPT_FIELD_MARGT	= 5;
		OPT_FIELD_MARGB	= 5;
		OPT_FIELD_WIDTH = 80;
		OPT_BUTTON_HEIGHT= 22;
		OPT_TEXT_MARGL	= 5;
		OPT_MARGV		= 5;
		OPT_PANEL_MIN_WIDTH = 200;
		OPT_TEXT_HEIGHT	= 17;
		
		OSI_SEP_HEIGHT	= 10;
		OSI_SEP_DEFAULT_Y = 230;
		OSI_SEP_COLOR	= [.85 .85 .85];
	end
	
	properties (Hidden)
		sourceBox;			% Listbox for sources
		inputBox;			% Listbox for input
		siSplit;			% Split between the listboxes
		siPanel;			% Panel containing the listboxes
		sAddButton;			% Add Source button
		trainButton;		% Train button
		selButton;			% Select same as input Button
		siContainer;		% Panel containing the above
		
		rateField;			% Editable field to enter the learning rate
		batchField;			% Editable field to enter batch size
		stopField;			% Editable field to an error value to stop at
		epochsField;		% Editable field to enter number of epochs
		matchButton;		% Button to match selected desired output
							% to selected output
		matchText;			% Text displaying number of matches
		optSP;				% Scrollpanel containing the above
		osiContainer;		% Panel containing optSP and siContainer
		osiSplit;			% Split between the listboxes and the options
		
		upperContainer;		% Panel containing the above
		
		dispSP;				% Scrollpanel to display selected input
		dispContainer;		% Panel containing dispSP (adding margin)
		dsiSplit;			% Split between display & listboxes
		
		sources;			% dracon.input.* instances
		selSources;			% Selected sources
		
		selInput	= 0;	% Topmost selected input
		
		runData		= {};	% Data used for last run
		
		input;				% Input Manager
		output;				% Output Manager
	end
	
	methods
		function t = training(drcn)
			t@dracon.gui.view(drcn);
			import dracon.gui.util.split
			
			t.fig = figure('integerhandle', 'off', ...
						'Menubar', 'none', ...
						'Userdata', drcn, ...
						'Dockcontrols', 'off', ...
						'Visible', 'off', ...
						'Color', t.DSI_SEP_COLOR, ...
						'closeRequestFcn', @(~,~)dracon.gui.util. ...
										toggleView(drcn, 'training'), ...
						'sizeChangedFcn', @(~,~)t.figSizeChanged());
			t.fig.OuterPosition(4) = t.DLG_HEIGHT;
			
			t.upperContainer = uipanel(t.fig, ...
						'BorderType', 'none', ...
						'Units', 'pixel', ...
						'sizeChangedFcn', @(~,~)t.upperContSizeChanged());
			t.upperContainer.Position(2) = t.DSI_SEP_DEFAULT_Y + ...
											t.DSI_SEP_HEIGHT + 1;
			t.upperContainer.Position(4) = t.UPPER_CONT_DEFAULT_HEIGHT;
			
			t.osiContainer = uipanel(t.upperContainer, ...
						'BorderType', 'none', ...
						'Units', 'pixel', ...
						'BackgroundColor', t.OSI_SEP_COLOR, ...
						'Position', [t.OSI_MARGL + 1, ...
									t.OSI_MARGB + 1, ...
									0, 0], ...
						'sizeChangedFcn', @(~,~)t.osiContSizeChanged());
			t.osiContainer.Position(3) = t.upperContainer.Position(3) - ...
											t.OSI_MARGL - t.OSI_MARGR;
			t.osiContainer.Position(4) = t.upperContainer.Position(4) - ...
											t.OSI_MARGB - t.OSI_MARGT;
			
			t.siContainer = uipanel(t.osiContainer, ...
						'BorderType', 'none', ...
						'Units', 'pixel', ...
						'sizeChangedFcn', @(~,~)t.siContSizeChanged());
			t.siContainer.Position(2) = t.OSI_SEP_DEFAULT_Y + ...
											t.OSI_SEP_HEIGHT + 1;
			t.siContainer.Position(4) = t.SI_CONT_DEFAULT_HEIGHT;
			
			t.siPanel = uipanel(t.siContainer, ...
						'BorderType', 'none', ...
						'Units', 'pixel', ...
						'BackgroundColor', t.SI_SEP_COLOR);
			t.siPanel.Position(2) = t.BUT_MARGB + t.BUT_HEIGHT + ...
									t.BUT_MARGT + 1;
								
			t.optSP = dracon.gui.util.scrollpanel(t.osiContainer, ...
						'Units', 'pixel');
			t.optSP.panel.Position(3) = t.OPT_PANEL_MIN_WIDTH;
			t.optSP.window.Position(1) = 1;
			t.optSP.window.Position(2) = 1;
			t.optSP.window.Position(3) = t.osiContainer.Position(3);
			t.optSP.window.Position(4) = t.OSI_SEP_DEFAULT_Y;
			t.optSP.stickUp = 1;
			t.optSP.stickLeft = 1;
			
			t.matchButton = uicontrol(t.optSP.panel, ...
									'Style', 'pushbutton', ...
									'TooltipString', t.MATCH_TOOLTIP, ...
									'String', t.MATCH_BUT_TEXT, ...
									'Callback', @(~,~)t.matchData());
			t.matchButton.Position(1) = 0;
			t.matchButton.Position(2) = t.OPT_FIELD_MARGB;
			t.matchButton.Position(3) = t.OPT_FIELD_WIDTH + 2;
			t.matchButton.Position(4) = t.OPT_BUTTON_HEIGHT;
			
			t.matchText = uicontrol(t.optSP.panel, ...
									'Style', 'text', ...
									'TooltipString', t.MATCH_TOOLTIP);
			t.matchText.Position(1) = t.matchButton.Position(1) + ...
										t.matchButton.Position(3) + ...
										t.OPT_TEXT_MARGL;
			t.matchText.Position(2) = t.matchButton.Position(2);
			t.matchText.Position(3) = 0;
			t.matchText.Position(4) = t.OPT_TEXT_HEIGHT;
			
			t.epochsField = uicontrol(t.optSP.panel, ...
									'Style', 'edit', ...
									'TooltipString', t.EPOCHS_TOOLTIP, ...
									'String', t.EPOCHS_DEFAULT);
			t.epochsField.Position(1) = 1;
			t.epochsField.Position(2) = t.matchButton.Position(2) + ...
										t.matchButton.Position(4) + ...
										t.OPT_MARGV;
			t.epochsField.Position(3) = t.OPT_FIELD_WIDTH;
			
			text = uicontrol(t.optSP.panel, ...
							'Style', 'text', ...
							'String', t.EPOCHS_TEXT, ...
							'TooltipString', t.EPOCHS_TOOLTIP);
			text.Position(1) = t.matchText.Position(1);
			text.Position(2) = t.epochsField.Position(2);
			text.Position(3) = text.Extent(3);
			text.Position(4) = t.OPT_TEXT_HEIGHT;
			
			t.stopField = uicontrol(t.optSP.panel, ...
									'Style', 'edit', ...
									'TooltipString', t.STOP_TOOLTIP, ...
									'String', t.STOP_DEFAULT);
			t.stopField.Position(1) = 1;
			t.stopField.Position(2) = t.epochsField.Position(2) + ...
										t.epochsField.Position(4) + ...
										t.OPT_MARGV;
			t.stopField.Position(3) = t.OPT_FIELD_WIDTH;
			
			text = uicontrol(t.optSP.panel, ...
							'Style', 'text', ...
							'String', t.STOP_TEXT, ...
							'TooltipString', t.STOP_TOOLTIP);
			text.Position(1) = t.matchText.Position(1);
			text.Position(2) = t.stopField.Position(2);
			text.Position(3) = text.Extent(3);
			text.Position(4) = t.OPT_TEXT_HEIGHT;
			
			t.batchField = uicontrol(t.optSP.panel, ...
									'Style', 'edit', ...
									'TooltipString', t.BATCH_TOOLTIP, ...
									'String', t.BATCH_DEFAULT);
			t.batchField.Position(1) = 1;
			t.batchField.Position(2) = t.stopField.Position(2) + ...
										t.stopField.Position(4) + ...
										t.OPT_MARGV;
			t.batchField.Position(3) = t.OPT_FIELD_WIDTH;
			
			text = uicontrol(t.optSP.panel, ...
							'Style', 'text', ...
							'String', t.BATCH_TEXT, ...
							'TooltipString', t.BATCH_TOOLTIP);
			text.Position(1) = t.matchText.Position(1);
			text.Position(2) = t.batchField.Position(2);
			text.Position(3) = text.Extent(3);
			text.Position(4) = t.OPT_TEXT_HEIGHT;
			
			t.rateField = uicontrol(t.optSP.panel, ...
									'Style', 'edit', ...
									'TooltipString', t.RATE_TOOLTIP, ...
									'String', t.RATE_DEFAULT);
			t.rateField.Position(1) = 1;
			t.rateField.Position(2) = t.batchField.Position(2) + ...
										t.batchField.Position(4) + ...
										t.OPT_MARGV;
			t.rateField.Position(3) = t.OPT_FIELD_WIDTH;
			
			text = uicontrol(t.optSP.panel, ...
							'Style', 'text', ...
							'String', t.RATE_TEXT, ...
							'TooltipString', t.RATE_TOOLTIP);
			text.Position(1) = t.matchText.Position(1);
			text.Position(2) = t.rateField.Position(2);
			text.Position(3) = text.Extent(3);
			text.Position(4) = t.OPT_TEXT_HEIGHT;
			
			t.optSP.panel.Position(4) = t.rateField.Position(2) + ...
										t.rateField.Position(4) + ...
										t.OPT_FIELD_MARGT + ...
										t.OPT_FIELD_MARGB;
			t.optSP.panel.Children = t.optSP.panel.Children(end:-1:1);
			
			t.osiSplit = split(t.optSP.window, ...
								t.siContainer, ...
								t.fig, ...
								split.HORIZONTAL);
			t.osiSplit.parMarg(1) = t.OSI_MARGL;
			
			t.sourceBox = uicontrol(t.siPanel, ...
						'Style', 'ListBox', ...
						'Callback', @(~,~)t.sourceClick(), ...
						'Max', 2, ...
						'Value', []);
			t.sourceBox.Position(1:2) = 1;
			t.sourceBox.Position(3) = t.SI_SEP_DEFAULT_X - 1;
										
			t.inputBox = uicontrol(t.siPanel, ...
						'Style', 'ListBox', ...
						'Callback', @(~,~)t.inputClick(), ...
						'Max', 2, ...
						'Value', []);
			t.inputBox.Position(1) = t.SI_SEP_DEFAULT_X + ...
										t.SI_SEP_WIDTH;
			t.inputBox.Position(2) = 1;
			t.inputBox.Position(3) = t.siPanel.Position(3) + 1 - ...
										t.inputBox.Position(1);
			t.sAddButton = uicontrol(t.siContainer, ...
						'Style', 'pushbutton', ...
						'String', t.ADD_TEXT , ...
						'Position', [t.S_BUT_MARGL + 1, ...
									t.BUT_MARGB + 1, ...
									t.S_BUT_WIDTH, ...
									t.BUT_HEIGHT], ...
						'TooltipString', t.ADD_TOOLTIP, ...
						'Callback', @(~,~)t.addSource());
			t.trainButton = uicontrol(t.siContainer, ...
						'Style', 'pushbutton', ...
						'String', t.TRAIN_TEXT , ...
						'Position', [0, ...
									t.BUT_MARGB + 1, ...
									t.T_BUT_WIDTH, ...
									t.BUT_HEIGHT], ...
						'Enable', 'off', ...
						'TooltipString', t.TRAIN_TOOLTIP, ...
						'Callback', @(~,~)t.trainAll());
			t.trainButton.Position(1) = t.sAddButton.Position(1) + ...
										t.sAddButton.Position(3) + ...
										t.ST_BUT_MARG;
			t.selButton = uicontrol(t.siContainer, ...
						'Style', 'pushbutton', ...
						'String', t.SELECT_TEXT , ...
						'TooltipString', t.SELECT_TOOLTIP, ...
						'Position', [0, ...
									t.BUT_MARGB + 1, ...
									t.SL_BUT_WIDTH, ...
									t.BUT_HEIGHT], ...
						'Callback', @(~,~)t.selAsInput());
			t.selButton.Position(1) = t.trainButton.Position(1) + ...
										t.trainButton.Position(3) + ...
										t.TSL_BUT_MARG;
									
			t.siSplit = split(t.sourceBox, t.inputBox, t.fig);
			t.siSplit.parMarg(1) = t.OSI_MARGL;
			
			
			t.dispContainer = uipanel(t.fig, ...
						'BorderType', 'none', ...
						'Units', 'pixel', ...
						'sizeChangedFcn', @(~,~)t.dContSizeChanged());
			t.dispContainer.Position(4) = t.DSI_SEP_DEFAULT_Y;
			t.dispSP = dracon.gui.util.scrollpanel(t.dispContainer, ...
						'Units', 'pixel');
			t.dispSP.window.Position(1) = t.DISP_MARGL + 1;
			t.dispSP.window.Position(2) = t.DISP_MARGB + 1;
			t.dispSP.panel.Position(3:4) = 0;
			t.dispSP.stickUp = 0;
			t.dispSP.stickLeft = 0;
			t.dsiSplit = split(t.dispContainer, ...
								t.upperContainer, ...
								t.fig, ...
								split.HORIZONTAL);
							
			t.input = drcn.getView('input');
			t.output = drcn.getView('output');
			
			t.fig.WindowButtonUpFcn = @(~,~)t.onButtonUp();
			t.fig.WindowButtonMotionFcn = @(~,~)t.onMove();
			t.fig.WindowKeyPressFcn = @(~,ev)t.onKey(ev);
			t.fig.WindowScrollWheelFcn = @(~, ev)t.onScroll(ev);
		end
		
		function data = getSelectedData(t)
			data = [];
			sel = t.inputBox.Value;
			try
				for k = 1:numel(t.selSources)
					s = t.sources{t.selSources(k)};
					ndata = sel(sel <= s.dataNum);
					if(~isempty(ndata))
						data = [data, s.getData(ndata)]; ...
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
	end
	
	methods (Hidden)
		function figSizeChanged(t)
			t.upperContainer.Position(3) = t.fig.Position(3);
			t.dispContainer.Position(3) = t.fig.Position(3);
			
			if(t.fig.Position(4) >= t.DSI_SEP_HEIGHT)
				dy = t.fig.Position(4) - t.upperContainer.Position(2) - ...
					t.upperContainer.Position(4) + 1;

				if(t.dispContainer.Position(4) < -dy)
					if(t.dispContainer.Position(4) > 0)
						t.upperContainer.Position(2) =  ...
							t.upperContainer.Position(2) - ...
							t.dispContainer.Position(4);
						dy = dy + t.dispContainer.Position(4);
						t.dispContainer.Position(4) = 0;
					end
					t.upperContainer.Position(4) = dy + ...
						t.upperContainer.Position(4);
				else
					if(dy > 0 && t.upperContainer.Position(4) < ...
							t.UPPER_CONT_DEFAULT_HEIGHT)
						t.upperContainer.Position(4) = dy + ...
							t.upperContainer.Position(4);
					else
						t.dispContainer.Position(4) = dy + ...
							t.dispContainer.Position(4);
						t.upperContainer.Position(2) = dy + ...
							t.upperContainer.Position(2);
					end
				end
			end
		end
		
		function upperContSizeChanged(t)
			ns(1) = t.upperContainer.Position(3) - ...
				t.OSI_MARGL - t.OSI_MARGR;
			ns(2) = t.upperContainer.Position(4) - ...
				t.OSI_MARGB - t.OSI_MARGT;
			t.osiContainer.Position(3:4) = max(0, ns);
		end
		
		function osiContSizeChanged(t)
			t.siContainer.Position(3) = t.osiContainer.Position(3);
			t.optSP.window.Position(3) = t.osiContainer.Position(3);
			
			t.osiSplit.parMarg(2) = t.upperContainer.Position(2) + ...
									t.OSI_MARGB - 1;
			
			if(t.fig.Position(4) >= t.OSI_SEP_HEIGHT)
				dy = t.osiContainer.Position(4) - ...
					t.siContainer.Position(2) - ...
					t.siContainer.Position(4) + 1;

				if(t.optSP.window.Position(4) < -dy)
					if(t.optSP.window.Position(4) > 0)
						t.siContainer.Position(2) =  ...
							t.siContainer.Position(2) - ...
							t.optSP.window.Position(4);
						dy = dy + t.optSP.window.Position(4);
						t.optSP.window.Position(4) = 0;
					end
					t.siContainer.Position(4) = max(0, ...
										dy + t.siContainer.Position(4));
				else
					if(dy > 0 && t.siContainer.Position(4) < ...
							t.SI_CONT_DEFAULT_HEIGHT)
						t.siContainer.Position(4) = dy + ...
							t.siContainer.Position(4);
					else
						t.optSP.window.Position(4) = dy + ...
							t.optSP.window.Position(4);
						t.siContainer.Position(2) = dy + ...
							t.siContainer.Position(2);
					end
				end
			end
		end
		
		function siContSizeChanged(t)
			ns(1) = t.siContainer.Position(3);
			ns(2) = t.siContainer.Position(4) - t.siPanel.Position(2) + 1;
			dx = ns(1) - t.siPanel.Position(3);
			ns = max(ns, 0);
			t.siPanel.Position(3:4) = ns;
			
			t.siSplit.parMarg(2) = t.fig.Position(4) - t.OSI_MARGT - ...
									t.siPanel.Position(4);
			
			t.sourceBox.Position(4) = ns(2);
			t.inputBox.Position(4) = ns(2);

			if(t.sourceBox.Position(3) < -dx)
				if(t.sourceBox.Position(3) > 0)
					t.inputBox.Position(1) =  ...
						t.inputBox.Position(1) - ...
						t.sourceBox.Position(3);
					dx = dx + t.sourceBox.Position(3);
					t.sourceBox.Position(3) = 0;
				end
				t.inputBox.Position(3) = dx + ...
					t.inputBox.Position(3);
			else
				if(dx > 0 && t.inputBox.Position(3) < ...
						t.INBOX_DEFAULT_WIDTH)
					t.inputBox.Position(3) = dx + ...
						t.inputBox.Position(3);
				else
					t.sourceBox.Position(3) = dx + ...
						t.sourceBox.Position(3);
					t.inputBox.Position(1) = dx + ...
						t.inputBox.Position(1);
				end
			end
		end
		
		function dContSizeChanged(t)
			ns(1) = t.dispContainer.Position(3) - ...
				t.DISP_MARGL - t.DISP_MARGR;
			ns(2) = t.dispContainer.Position(4) - ...
				t.DISP_MARGB - t.DISP_MARGT;
			t.dispSP.window.Position(3:4) = max(0, ns);
		end
		
		function onButtonUp(t)
			t.siSplit.onButtonUp();
			t.dsiSplit.onButtonUp();
			t.osiSplit.onButtonUp();
		end
		
		function onMove(t)
			t.siSplit.onMove();
			t.dsiSplit.onMove();
			t.osiSplit.onMove();
		end
		
		function onKey(t, ev)
			switch ev.Key
				case 'escape'
					dracon.gui.util.toggleView(t.drcn, 'training')
					
				case 'delete'
					if(t.fig.CurrentObject == t.sourceBox && ...
							~isempty(t.sourceBox.Value))
						val = t.sourceBox.Value;
						t.sourceBox.Value = [];
						t.sourceClick();
						pos = 1;
						for k = 1:min(numel(t.runData), max(val))
							num = numel(t.runData{k});
							if((num <= 0 || t.runData{k}(1) > 0) && ...
									k == val(pos))
								pos = pos + 1;
								t.runData{k} = -num;
							end
						end
						delete(t.sources{val});
						t.sources(val) = [];
						t.sourceBox.String(val) = [];
					end
			end
			
			if(ismember('control', ev.Modifier))
				switch ev.Key
					case 't'
						if(strcmp(t.trainButton.Enable, 'on'))
							uicontrol(t.trainButton);
							t.trainButton.Callback();
						end
						
					case 'n'
						t.sAddButton.Callback();
						
					case 's'
						t.selButton.Callback();
						
					case 'm'
						t.matchButton.Callback();
				end
			end
			
			if(isempty(t.fig.CurrentObject) || ...
					(t.fig.CurrentObject ~= t.inputBox && ...
					t.fig.CurrentObject ~= t.sourceBox))
				t.dispSP.onKey(ev);
			end
		end
		
		function onScroll(t, ev)
			if(isempty(t.fig.CurrentObject) || ...
					(t.fig.CurrentObject ~= t.inputBox && ...
					t.fig.CurrentObject ~= t.sourceBox))
				
				if(t.fig.CurrentPoint(2) > t.dispContainer.Position(4))
					t.optSP.onScroll(ev, t.fig.CurrentModifier);
				else
					t.dispSP.onScroll(ev, t.fig.CurrentModifier);
				end
			end
		end
		
		function addSource(t)
			as = t.drcn.getDlg('addsource');
			if(as.show())
				ns = as.newSource;
				t.sources = [t.sources, {ns}];
				t.sourceBox.String = [t.sourceBox.String; {ns.source}];
			end
		end
		
		function sourceClick(t)
			add = [setdiff(t.sourceBox.Value, t.selSources), 0];
			rm = [setdiff(t.selSources, t.sourceBox.Value), 0];
			
			text = t.inputBox.String;
			val = t.inputBox.Value;
			pr = 1;
			ps = 0;
			for k = 1:numel(t.selSources)
				num = t.sources{t.selSources(k)}.dataNum;
				if(t.selSources(k) == rm(pr))
					text(ps+1:ps+num) = [];
					val(val > ps & val <= ps+num) = [];
					val(val > ps+num) = val(val > ps+num) - num;
					if(t.selInput > ps+num)
						t.selInput = t.selInput - num;
					elseif(t.selInput > ps)
						t.selInput = 0;
					end
					pr = pr + 1;
				else
					ps = ps + num;
				end
			end
			
			pa = 1;
			ps = 0;
			for k = 1:numel(t.sourceBox.Value)
				num = t.sources{t.sourceBox.Value(k)}.dataNum;
				if(t.sourceBox.Value(k) == add(pa))
					text = [text(1:ps); ...
							t.sources{add(pa)}.text; ...
							text(ps+1:end)];
					pa = pa + 1;
					val(val > ps) = val(val > ps) + num;
					if(t.selInput > ps)
						t.selInput = t.selInput + num;
					end
				end
				ps = ps + num;
			end
			
			if(~isempty(t.inputBox.Value))
				dn = t.inputBox.Value(1);
				[dsn, dn] = t.getSourceFromInput(dn);
				if(ismember(dsn, rm))
					t.sources{dsn}.deselect(t.dispSP.panel, dn);
					if(~isempty(val))
						[dsn, dn] = t.getSourceFromInput(val(1));
						t.sources{dsn}.select(t.dispSP.panel, dn);
					end
				end
			end
			
			t.inputBox.Value = val;
			t.inputBox.String = text;
			
			t.selSources = t.sourceBox.Value;
			
			if(isempty(val))
				t.trainButton.Enable = 'off';
				t.dispSP.panel.Position(3:4) = 0;
				t.dispSP.onResize();
			else
				t.trainButton.Enable = 'on';
			end
		end
		
		function inputClick(t)
			if(isempty(t.inputBox.Value))
				if(t.selInput > 0)
					[dsn, dn] = t.getSourceFromInput(t.selInput);
					t.sources{dsn}.deselect(t.dispSP.panel, dn);
					t.dispSP.panel.Position(3:4) = 0;
					t.dispSP.onResize();
					t.selInput = 0;
				end
				t.trainButton.Enable = 'off';
				
			elseif(t.selInput == 0)
				t.selInput = t.inputBox.Value(1);
				[dsn, dn] = t.getSourceFromInput(t.selInput);
				t.sources{dsn}.select(t.dispSP.panel, dn);
				t.trainButton.Enable = 'on';
				
			elseif(t.selInput ~= t.inputBox.Value(1))
				[dsn, dn] = t.getSourceFromInput(t.selInput);
				t.sources{dsn}.deselect(t.dispSP.panel, dn);
				t.dispSP.panel.Position(3:4) = 0;
				t.dispSP.onResize();
				
				t.selInput = t.inputBox.Value(1);
				
				[dsn, dn] = t.getSourceFromInput(t.selInput);
				t.sources{dsn}.select(t.dispSP.panel, dn);
				t.trainButton.Enable = 'on';
			end
		end
		
		function trainAll(t)
			rate = str2double(t.rateField.String);
			if(rate <= 0 || ~isreal(rate) || ~isfinite(rate))
				t.drcn.error('', t.ERR_DLG_TITLE, t.RATE_ERROR);
			end
			batch = str2double(t.batchField.String);
			if(floor(batch) ~= batch || batch < 0 || ~isreal(batch))
				t.drcn.error('', t.ERR_DLG_TITLE, t.BATCH_ERROR);
			end
			stop = str2double(t.stopField.String);
			if(~isreal(stop) || isnan(stop) || stop < 0)
				t.drcn.error('', t.ERR_DLG_TITLE, t.STOP_ERROR);
			end
			epochs = str2double(t.epochsField.String);
			if(floor(epochs) ~= epochs || isinf(epochs) || epochs < 1)
				t.drcn.error('', t.ERR_DLG_TITLE, t.EPOCHS_ERROR);
			end
			
			try
				in = t.input.getSelectedData();
				out = t.getSelectedData();
				
				all = size(in, 2);
				if(batch == 0 || batch > all)
					batch = all;
				end
				
				t.drcn.train(in, out, rate, stop, epochs, batch);
			catch ex
				t.drcn.error(ex.identifier, t.ERR_DLG_TITLE, ex.message);
			end
		end
		
		function matchData(t)
			num = numel(t.inputBox.Value);
			if(num == 0)
				t.output.clearHighlight();
				return;
			end
			numo = numel(t.output.outBox.Value);
			if(numo ~= num)
				msg = sprintf(t.INEQUAL_SELECT, numo, num);
				t.drcn.error('', t.ERR_DLG_TITLE, msg);
				return;
			end
			try
				data1 = t.getSelectedData();
				data2 = t.output.getSelectedData();
			catch ex
				t.drcn.error(ex.identifier, t.ERR_DLG_TITLE, ex.message);
			end
			ds = size(data1, 1);
			dso = size(data2, 1);
			if(dso ~= ds)
				msg = sprintf(t.INEQUAL_DATA, dso, ds);
				t.drcn.error('', t.ERR_DLG_TITLE, msg);
				return;
			end
			match = all(data1 == data2, 1);

			t.output.highlightData(t.output.outBox.Value(~match), ...
									t.HIGHLIGHT_LEFT, ...
									t.HIGHLIGHT_RIGHT);

			match = sum(match);
			t.matchText.String = sprintf(t.MATCH_TEXT, ...
										match, num, ...
										100*match/num);
			t.matchText.Position(3) = t.matchText.Extent(3);
			t.optSP.panel.Position(3) = max(t.OPT_PANEL_MIN_WIDTH, ...
										t.matchText.Extent(3) + ...
										t.matchText.Position(1) - 1);
		end
		
		function selAsInput(t)
			s = t.input.sourceBox.Value;
			if(max(s) > numel(t.sources))
				t.drcn.error('', t.ERR_DLG_TITLE, t.TOO_FEW_SOURCES);
				return;
			end
			in = t.input.inputBox.Value;
			nd = 0;
			for k = 1:numel(s)
				nd = nd + t.sources{k}.dataNum;
			end
			if(max(in) > nd)
				t.drcn.error('', t.ERR_DLG_TITLE, t.TOO_FEW_INPUT);
				return;
			end
			t.sourceBox.Value = s;
			t.sourceClick();
			t.inputBox.Value = in;
			t.inputClick();
		end
		
		function [snum, num] = getSourceFromInput(t, num)
			snum = [];
			for k = 1:numel(t.selSources)
				snum = t.selSources(k);
				if(num <= t.sources{snum}.dataNum)
					return;
				end
				num = num - t.sources{snum}.dataNum;
			end
		end
	end
	
	methods (Static)
		function pos = getDefaultPos()
			import dracon.gui.view.training;
			pos = get(groot, 'ScreenSize');
			pos(1) = max(pos(1), ...
				pos(3) - training.DLG_MARGR - training.DLG_WIDTH + 1);
			pos(2) = max(pos(2), pos(2) + pos(4) ...
				- training.DLG_MARGT - training.DLG_HEIGHT);
			pos(3) = min(training.DLG_WIDTH, pos(3) - pos(1));
			pos(4) = training.DLG_HEIGHT;
			pos = max(pos, 1);
		end
	end
end

