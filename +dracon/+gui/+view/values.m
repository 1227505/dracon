classdef values < dracon.gui.view
	%VALUES Summary of this class goes here
	%   Detailed explanation goes here
	
	properties (Constant, Transient)
		NAME = 'Value Display';
	end
	
	properties (Constant, Transient, Hidden)
		DEFAULT_SHOW = 'off';
		SHORTKEY = 'D';
		POSITION = 0;

		ERR_DLG_TITLE	= 'Value ERROR';

        
		% Dialog default position
		DLG_MARGR		= 450;	% Margin to screen, right
		DLG_MARGT		= 200;	% Margin to screen, top
		DLG_WIDTH		= 235;	% Width
		DLG_HEIGHT		= 393;	% Height
		
		
		CONTENT_WIDTH		= 218;
		BUTTON_SIZE			= [110, 22];	% Size of all Buttons
		POP_SIZE			= [110 20];
		TEXT_HEIGHT			= 12;
		CHECK_HEIGHT		= 14;
		
		RAN_BUT_MARGL		= 10;
		RAN_MARGB			= 10;
		RAN_MARGT			= 10;
		RAN_MARGV			= 5;
		RAN_BIASES_TEXT		= 'Randomize Biases';
		RAN_BIASES_TOOLTIP	= ['Randomizes all biases according ', ...
								'to a normal distribution'];
		RAN_WEIGHTS_TEXT	= 'Randomize Weights';
		RAN_WEIGHTS_TOOLTIP	= ['Randomizes all weights according ', ...
								'to a normal distribution'];
		RAN_FIELD_MARGL		= 4;
		RAN_FIELD_WIDTH		= 38;
		RAN_MU_TEXT			= char(956);
		RAN_MU_TOOLTIP		= ['<html><i>Finite real value</i><br>', ...
								'Mean of the normal ', ...
								'distribution.</html>']
		RAN_MU_DEFAULT		= '0';
		RAN_MU_ERR			= [char(956), ' must be a finite, ', ...
								'real number.'];
		RAN_SIG_TEXT		= char(963);
		RAN_SIG_TOOLTIP		= ['<html><i>Finite real value</i><br>', ...
								'Standard deviation of the normal ', ...
								'distribution.</html>']
		RAN_SIG_DEFAULT		= '0.01';
		RAN_SIG_ERR			= [char(963), ' must be a finite, ', ...
								'real number.'];
		RAN_TO_HEIGHT		= 18;
		RAN_TO_WIDTH		= 14;
		RAN_TO_TEXT			= '-';
		
		COL_PAN_NAME		= 'Node Colors';
		COL_PAN_BORDERT		= 'etchedout';
		COL_PAN_BORDERW		= 1;
		COL_PADT			= 22;
		COL_PADB			= 5;
		COL_PADR			= 8;
		
		COL_BUT_MARGL		= 8;
		COL_OPT_MARGL		= 28;
		
		COL_B_MARGV			= 15;
		COL_BO_MARGV		= 5;
		
		
		COL_LOW_TEXT		= 'Low';
		COL_LOW_DEFAULT		= [0 0 1];
		COL_LOW_TOOLTIP		= 'TODO';
		COL_V_LOW_DEFAULT	= '0';
		COL_V_LOW_TOOLTIP	= 'TODO';
		COL_V_LOW_ERR		= 'Low must be a finite, real number.';
		COL_HIGH_TEXT		= 'High';
		COL_HIGH_DEFAULT	= [1 0 0];
		COL_HIGH_TOOLTIP	= 'TODO';
		COL_V_HIGH_DEFAULT	= '1';
		COL_V_HIGH_TOOLTIP	= 'TODO';
		COL_V_HIGH_ERR		= 'High must be a finite, real number.';
		COL_SIZE			= [50, 22];
		COL_V_WIDTH			= 50;
		COL_V_MARGL			= 10;
		
		BIA_TEXT			= 'by Bias';
		BIA_TOOLTIP			= 'TODO';
		
		RUN_TEXT			= 'by Run Data';
		RUN_TOOLTIP			= 'TODO';
		RUN_FCN_OPTS		= {'Mean', 'Median', 'Maximum', 'Minimum'};
		RUN_FCN_TOOLTIPS	= {'a','b','c','d'};
		
		INF_TEXT			= 'by Influence';
		INF_TOOLTIP			= 'TODO';
		INF_USE_TEXT		= 'Use Input';
		INF_USE_TOOLTIP		= ['<html>If this and at least one input ', ...
								'value in the Input Manager are ', ...
								'selected, the first of the latter ', ...
								'is used as input when determining ', ...
								'node influence.<br>Otherwise all ', ...
								'input nodes are set to 0.</html>'];
		INF_SET_TEXT		= 'Set Zero';
		INF_SET_TOOLTIP		= 'TODO';
		
		RES_TEXT			= 'Reset';
		RES_TOOLTIP			= 'Reset node colors to their default value.';
	end
	
	properties (Hidden)
		sp;				% Scrollpanel containing all ui elements
		
		network;		% Network view
		input;			% Input Manager
		
		% Options
		randMu;
		randSigma;
		
		colorLow;
		colorHigh;
		colorLowVal;		% Values at which the colors are applied
		colorHighVal;
		
		runDataFcn;
		
		useInput;
		setZero;
	end
	
	methods
		function v = values(drcn)
			v@dracon.gui.view(drcn);
			
			v.fig = figure('integerhandle', 'off', ...
						'menubar', 'none', ...
						'userdata', drcn, ...
						'dockcontrols', 'off', ...
						'visible', 'off', ...
						'WindowKeyPressFcn', @(~,ev)v.onKey(ev), ...
						'closeRequestFcn', @(~,~)dracon.gui.util. ...
										toggleView(drcn, 'values'));
			v.fig.OuterPosition(4) = v.DLG_HEIGHT;
			
			v.sp = dracon.gui.util.scrollpanel(v.fig);
			v.sp.stickUp = 1;
			v.sp.panel.Position(3) = v.CONTENT_WIDTH;
			v.fig.WindowScrollWheelFcn = @(~,ev) ...
				v.sp.onScroll(ev, v.fig.CurrentModifier);
			
			cp = uipanel(v.sp.panel, ...
						'Units', 'pixels', ...
						'Title', v.COL_PAN_NAME, ...
						'BorderType', v.COL_PAN_BORDERT, ...
						'BorderWidth', v.COL_PAN_BORDERW);
			cp.Position(3) = v.CONTENT_WIDTH;
			
			% Color stuff here
			
			but = uicontrol(cp, ...
				'Style', 'pushbutton', ...
				'String', v.RES_TEXT, ...
				'TooltipString', v.RES_TOOLTIP,...
				'Callback', @(~,~)v.resetColors());
			but.Position(1) = v.COL_BUT_MARGL;
			but.Position(2) = v.COL_PADB + 1;
			but.Position(3:4) = v.BUTTON_SIZE;
			
			v.setZero = uicontrol(cp, ...
				'Style', 'checkbox', ...
				'String', v.INF_SET_TEXT, ...
				'TooltipString', v.INF_SET_TOOLTIP);
			v.setZero.Position(1) = v.COL_OPT_MARGL;
			v.setZero.Position(2) = but.Position(2) + ...
									but.Position(4) + ...
									v.COL_B_MARGV;
			v.setZero.Position(3) = cp.Position(3) - ...
									v.COL_OPT_MARGL - ...
									v.COL_PADR;
			v.setZero.Position(4) = v.CHECK_HEIGHT;
			
			v.useInput = uicontrol(cp, ...
				'Style', 'checkbox', ...
				'String', v.INF_USE_TEXT, ...
				'TooltipString', v.INF_USE_TOOLTIP);
			v.useInput.Position(1) = v.COL_OPT_MARGL;
			v.useInput.Position(2) = v.setZero.Position(2) + ...
									v.setZero.Position(4) + ...
									v.COL_BO_MARGV;
			v.useInput.Position(3) = cp.Position(3) - ...
									v.COL_OPT_MARGL - ...
									v.COL_PADR;
			v.useInput.Position(4) = v.CHECK_HEIGHT;
			
			but = uicontrol(cp, ...
				'Style', 'pushbutton', ...
				'String', v.INF_TEXT, ...
				'TooltipString', v.INF_TOOLTIP,...
				'Callback', @(~,~)v.colorByInfluence());
			but.Position(1) = v.COL_BUT_MARGL;
			but.Position(2) = v.useInput.Position(2) + ...
								v.useInput.Position(4) + ...
								v.COL_BO_MARGV;
			but.Position(3:4) = v.BUTTON_SIZE;
			
			v.runDataFcn = uicontrol(cp, ...
				'Style', 'popupmenu', ...
				'String', v.RUN_FCN_OPTS, ...
				'TooltipString', v.RUN_FCN_TOOLTIPS{1});
			v.runDataFcn.Callback = @(~,~)set(v.runDataFcn, ...
				'TooltipString', ...
				v.RUN_FCN_TOOLTIPS{v.runDataFcn.Value});
			v.runDataFcn.Position(1) = v.COL_OPT_MARGL;
			v.runDataFcn.Position(2) = but.Position(2) + ...
										but.Position(4) + ...
										v.COL_B_MARGV;
			v.runDataFcn.Position(3:4) = v.POP_SIZE;
			
			but = uicontrol(cp, ...
				'Style', 'pushbutton', ...
				'String', v.RUN_TEXT, ...
				'TooltipString', v.RUN_TOOLTIP,...
				'Callback', @(~,~)v.colorByRunData());
			but.Position(1) = v.COL_BUT_MARGL;
			but.Position(2) = v.runDataFcn.Position(2) + ...
								v.runDataFcn.Position(4) + ...
								v.COL_BO_MARGV;
			but.Position(3:4) = v.BUTTON_SIZE;
			
			but2 = uicontrol(cp, ...
				'Style', 'pushbutton', ...
				'String', v.BIA_TEXT, ...
				'TooltipString', v.BIA_TOOLTIP,...
				'Callback', @(~,~)v.colorByBias());
			but2.Position(1) = v.COL_BUT_MARGL;
			but2.Position(2) = but.Position(2) + ...
								but.Position(4) + ...
								v.COL_B_MARGV;
			but2.Position(3:4) = v.BUTTON_SIZE;
			
			v.colorHigh = uicontrol(cp, ...
				'Style', 'pushbutton', ...
				'String', v.COL_HIGH_TEXT, ...
				'BackgroundColor', v.COL_HIGH_DEFAULT, ...
				'ForegroundColor', v.getContrast(v.COL_HIGH_DEFAULT), ...
				'TooltipString', v.COL_HIGH_TOOLTIP);
			v.colorHigh.Callback = @(~,~)v.colorClick(v.colorHigh);
			v.colorHigh.Position(1) = v.COL_BUT_MARGL;
			v.colorHigh.Position(2) = but2.Position(2) + ...
									but2.Position(4) + ...
									v.COL_B_MARGV - 1;
			v.colorHigh.Position(3:4) = v.COL_SIZE;
			
			v.colorHighVal = uicontrol(cp, ...
				'Style', 'edit', ...
				'String', v.COL_V_HIGH_DEFAULT, ...
				'TooltipString', v.COL_V_HIGH_TOOLTIP);
			v.colorHighVal.Position(1) = v.colorHigh.Position(1) + ...
										v.colorHigh.Position(3) + ...
										v.COL_V_MARGL;
			v.colorHighVal.Position(2) = v.colorHigh.Position(2) + 1;
			v.colorHighVal.Position(3) = v.COL_V_WIDTH;
			uistack(v.colorHighVal, 'down');
			
			v.colorLow = uicontrol(cp, ...
				'Style', 'pushbutton', ...
				'String', v.COL_LOW_TEXT, ...
				'BackgroundColor', v.COL_LOW_DEFAULT, ...
				'ForegroundColor', v.getContrast(v.COL_LOW_DEFAULT), ...
				'TooltipString', v.COL_LOW_TOOLTIP);
			v.colorLow.Callback = @(~,~)v.colorClick(v.colorLow);
			v.colorLow.Position(1) = v.COL_BUT_MARGL;
			v.colorLow.Position(2) = v.colorHigh.Position(2) + ...
									v.colorHigh.Position(4) + ...
									v.COL_BO_MARGV - 1;
			v.colorLow.Position(3:4) = v.COL_SIZE;
			
			v.colorLowVal = uicontrol(cp, ...
				'Style', 'edit', ...
				'String', v.COL_V_LOW_DEFAULT, ...
				'TooltipString', v.COL_V_LOW_TOOLTIP);
			v.colorLowVal.Position(1) = v.colorLow.Position(1) + ...
										v.colorLow.Position(3) + ...
										v.COL_V_MARGL;
			v.colorLowVal.Position(2) = v.colorLow.Position(2) + 1;
			v.colorLowVal.Position(3) = v.COL_V_WIDTH;
			uistack(v.colorLowVal, 'down');
			
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			
			cp.Position(4) = v.colorLowVal.Position(2) + ...
							v.colorLowVal.Position(4) + ...
							v.COL_PADT - 1;
			cp.Children = cp.Children(end:-1:1);
			
			% Randomize stuff here
			
			but = uicontrol(v.sp.panel, ...
							'Style', 'pushbutton', ...
							'String', v.RAN_BIASES_TEXT, ...
							'TooltipString', v.RAN_BIASES_TOOLTIP,...
							'Callback', @(~,~)v.randBiases());
			but.Position(1) = v.RAN_BUT_MARGL + 1;
			but.Position(2) = cp.Position(2) + ...
								cp.Position(4) + ...
								v.RAN_MARGB;
			but.Position(3:4) = v.BUTTON_SIZE;
			
			v.randMu = uicontrol(v.sp.panel, ...
							'Style', 'edit', ...
							'String', v.RAN_MU_DEFAULT, ...
							'TooltipString', v.RAN_MU_TOOLTIP);
			v.randMu.Position(1) = but.Position(1) + ...
								but.Position(3) + ...
								v.RAN_FIELD_MARGL;
			v.randMu.Position(2) = but.Position(2) + 1;
			v.randMu.Position(3) = v.RAN_FIELD_WIDTH;
			uistack(v.randMu, 'down');
			
			to = uicontrol(v.sp.panel, ...
							'Style', 'text', ...
							'String', v.RAN_TO_TEXT);
			to.Position(1) = v.randMu.Position(1) + v.randMu.Position(3);
			to.Position(2) = v.randMu.Position(2);
			to.Position(3) = v.RAN_TO_WIDTH;
			to.Position(4) = v.RAN_TO_HEIGHT;
			
			v.randSigma = uicontrol(v.sp.panel, ...
							'Style', 'edit', ...
							'String', v.RAN_SIG_DEFAULT, ...
							'TooltipString', v.RAN_SIG_TOOLTIP);
			v.randSigma.Position(1) = to.Position(1) + ...
								to.Position(3);
			v.randSigma.Position(2) = to.Position(2);
			v.randSigma.Position(3) = v.RAN_FIELD_WIDTH;
			v.sp.panel.Children([1, 3, 4]) = ...
				v.sp.panel.Children([3, 4, 1]);
							
			but2 = uicontrol(v.sp.panel, ...
							'Style', 'pushbutton', ...
							'String', v.RAN_WEIGHTS_TEXT, ...
							'TooltipString', v.RAN_WEIGHTS_TOOLTIP,...
							'Callback', @(~,~)v.randWeights());
			but2.Position(1) = v.RAN_BUT_MARGL + 1;
			but2.Position(2) = but.Position(2) + ...
								but.Position(4) + ...
								v.RAN_MARGV;
			but2.Position(3:4) = v.BUTTON_SIZE;
			
			txt = uicontrol(v.sp.panel, ...
							'Style', 'text', ...
							'String', v.RAN_MU_TEXT, ...
							'TooltipString', v.RAN_MU_TOOLTIP);
			txt.Position([1, 3]) = v.randMu.Position([1, 3]);
			txt.Position(2) = but2.Position(2) + 1;
			txt.Position(4) = v.TEXT_HEIGHT;
			
			txt = uicontrol(v.sp.panel, ...
							'Style', 'text', ...
							'String', v.RAN_SIG_TEXT, ...
							'TooltipString', v.RAN_SIG_TOOLTIP);
			txt.Position([1, 3]) = v.randSigma.Position([1, 3]);
			txt.Position(2) = but2.Position(2) + 1;
			txt.Position(4) = v.TEXT_HEIGHT;
			
			%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
			
			v.sp.panel.Children = v.sp.panel.Children(end:-1:1);
			v.sp.panel.Position(4) = but2.Position(2) + ...
									but2.Position(4) + ...
									v.RAN_MARGT - 1;
			v.network = drcn.getView('network');
			v.input = drcn.getView('input');
		end
	end  
	
	methods (Hidden)
		function onKey(v, ev)
			switch ev.Key
				case 'escape'
					dracon.gui.util.toggleView(v.drcn, 'values')
					
				otherwise
					v.sp.onKey(ev);
			end
			
			if(ismember('control', ev.Modifier))
				switch ev.Key
				end
			end
		end
		
		function randWeights(v)
			[mu, sigma] = v.checkRand();
			if(isnan(mu))
				return;
			end
			v.drcn.randomizeWeights(mu, sigma);
		end
		
		function randBiases(v)
			[mu, sigma] = v.checkRand();
			if(isnan(mu))
				return;
			end
			v.drcn.randomizeBiases(mu, sigma);
		end
		
		function resetColors(v)
			for x = 1:numel(v.drcn.nets)
				for y = 1:numel(v.drcn.nets{x})
					n = v.drcn.nets{x}{y};
					for no = 1:n.in
						v.network.resetNodeColor(x, y, 0, no);
					end
					for l = 1:n.layers
						for no = 1:numel(n.biases{l})
							v.network.resetNodeColor(x, y, l, no);
						end
					end
				end
			end
		end
		
		function colorByBias(v)
			if(isempty(v.drcn.nets))
				return;
			end
			[low, high] = v.checkInterpol();
			if(isnan(low))
				return;
			end
			colL = v.colorLow.BackgroundColor;
			colH = v.colorHigh.BackgroundColor;
			
			for x = 1:numel(v.drcn.nets)
				for y = 1:numel(v.drcn.nets{x})
					n = v.drcn.nets{x}{y};
					for no = 1:n.in
						v.network.resetNodeColor(x, y, 0, no);
					end
					for l = 1:n.layers
						val = v.interColor(n.biases{l}, ...
											low, high, ...
											colL, colH);
						for no = 1:numel(n.biases{l})
							v.network.setNodeColor(x, y, l, no, val(no,:));
						end
					end
				end
			end
		end
		
		function colorByRunData(v)
			if(isempty(v.drcn.nets) || isempty(v.drcn.runData))
				return;
			end
			[low, high] = v.checkInterpol();
			if(isnan(low))
				return;
			end
			colL = v.colorLow.BackgroundColor;
			colH = v.colorHigh.BackgroundColor;
			
			switch v.runDataFcn.Value
				case 1
					fcn = @(x)mean(x, 2);
					
				case 2
					fcn = @(x)median(x, 2);
					
				case 3
					fcn = @(x)max(x, [], 2);
					
				case 4
					fcn = @(x)min(x, [], 2);
			end
			
			for x = 1:numel(v.drcn.nets)
				for y = 1:numel(v.drcn.nets{x})
					n = v.drcn.nets{x}{y};
					data = v.drcn.runData{x}{y};
					val = v.interColor(fcn(data{1}), ...
										low, high, ...
										colL, colH);
					for no = 1:n.in
						v.network.setNodeColor(x, y, 0, no, val(no,:));
					end
					for l = 1:n.layers
						val = v.interColor(fcn(data{l+1}), ...
											low, high, ...
											colL, colH);
						for no = 1:numel(n.biases{l})
							v.network.setNodeColor(x, y, l, no, val(no,:));
						end
					end
				end
			end
		end
		
		function colorByInfluence(v)
			if(isempty(v.drcn.nets))
				return;
			end
			[low, high] = v.checkInterpol();
			if(isnan(low))
				return;
			end
			colL = v.colorLow.BackgroundColor;
			colH = v.colorHigh.BackgroundColor;
			
			nods = v.network.getSelectedNodes();
			
			if(v.setZero.Value)
				for x = 1:numel(nods)
					for y = 1:numel(nods{x})
						for l = 1:numel(nods{x}{y})
							is = isnan(nods{x}{y}{l});
							if(~all(is))
								nods{x}{y}{l}(is) = 0;
							end
						end
					end
				end
			end
			
			if(v.useInput.Value && v.input.selInput > 0)
				in = v.input.getTopSelectedData();
			else
				in = 0;
				for y = 1:numel(v.drcn.nets{1})
					in = in + v.drcn.nets{1}{y}.in;
				end
				in = zeros(in, 1);
			end
			
			try
				inf = v.drcn.getInfluence(in, nods);
			catch ex
				v.drcn.error(ex.identifier, v.ERR_DLG_TITLE, ex.message);
				return;
			end
			
			for x = 1:numel(v.drcn.nets)
				for y = 1:numel(v.drcn.nets{x})
					n = v.drcn.nets{x}{y};
					val = v.interColor(inf{x}{y}{1}, ...
										low, high, ...
										colL, colH);
					for no = 1:n.in
						v.network.setNodeColor(x, y, 0, no, val(no,:));
					end
					for l = 1:n.layers
						val = v.interColor(inf{x}{y}{l+1}, ...
											low, high, ...
											colL, colH);
						for no = 1:numel(n.biases{l})
							v.network.setNodeColor(x, y, l, no, val(no,:));
						end
					end
				end
			end
		end
		
		function [low, high] = checkInterpol(v)
			low = str2num(v.colorLowVal.String); %#ok<*ST2NM>
			if(isempty(low) || isinf(low) || isnan(low) || ~isreal(low))
				v.drcn.error('', v.ERR_DLG_TITLE, v.COL_V_LOW_ERR);
				low = NaN;
				high = NaN;
				return;
			end
			high = str2num(v.colorHighVal.String);
			if(isempty(high) || isinf(high) || ...
					isnan(high) || ~isreal(high))
				v.drcn.error('', v.ERR_DLG_TITLE, v.COL_V_HIGH_ERR);
				low = NaN;
			end
		end
		
		function [mu, sigma] = checkRand(v)
			mu = str2num(v.randMu.String);
			if(isempty(mu) || isinf(mu) || isnan(mu) || ~isreal(mu))
				v.drcn.error('', v.ERR_DLG_TITLE, v.RAN_MU_ERR);
				mu = NaN;
				sigma = NaN;
				return;
			end
			sigma = str2num(v.randSigma.String);
			if(isempty(sigma) || isinf(sigma) || ...
					isnan(sigma) || ~isreal(sigma))
				v.drcn.error('', v.ERR_DLG_TITLE, v.RAN_SIG_ERR);
				mu = NaN;
			end
		end
	end
	
	methods (Static, Hidden)
		function colorClick(ui)
			import dracon.gui.view.values
			ui.BackgroundColor = uisetcolor(ui.BackgroundColor);
			ui.ForegroundColor = values.getContrast(ui.BackgroundColor);
		end
	end
	
	methods (Static)
		function pos = getDefaultPos()
			import dracon.gui.view.values;
			pos = get(groot, 'ScreenSize');
			pos(1) = max(pos(1), ...
				pos(3) - values.DLG_MARGR - values.DLG_WIDTH + 1);
			pos(2) = max(pos(2), pos(2) + pos(4) ...
				- values.DLG_MARGT - values.DLG_HEIGHT);
			pos(3) = min(values.DLG_WIDTH, pos(3) - pos(1));
			pos(4) = values.DLG_HEIGHT;
			pos = max(pos, 1);
		end
		
		% val has to be a column vector
		function col = interColor(val, low, high, col1, col2)
			p = (val - low)/(high - low);

			col = (1 - p) * col1 + p * col2;

			a = any(col < 0, 2);
			col(a, :) = col(a, :) - repmat(min(col(a, :), [], 2), 1 ,3);

			a = any(col > 1, 2);
			col(a, :) = col(a, :) ./ repmat(max(col(a, :), [], 2), 1, 3);
		end
		
		function col = getContrast(col)
			if(col * [76.228685; 149.695984; 29.075331] > 186)
				col = [0, 0, 0];
			else
				col = [1, 1, 1];
			end
		end
	end
end

