classdef addsource < dracon.gui.dialog
%ADDSOURCE Dialog to add source to the input or training manager
% New source available in as.newSource

	properties
		newSource;
	end

	properties (Constant, Transient, Hidden)
		NAME			= 'Add Source';
		OKTEXT			= 'Add';
		CANCTEXT		= 'Cancel';

		ERR_DLG_TITLE	= 'Add Source ERROR';
		INVALID_FILE	= 'Invalid file path.';

		SOURCE_PATH		= 'dracon.input';

		NO_FILE			= 'No File selected';
		ALL_FILES		= 'All Files';

		WIDTH			= 187;
		MARGT			= 120;
		DMAXW			= 202;
		PAN_BORDERW		= 1;

		OPT_T_MARGB		= -1;
		OPT_P_MARGB		= 8;
		OPT_MARGL		= 8;
		OPT_MARGR		= 8;
		OPT_MARGT		= 8;
		OPT_PADD		= -3;
	end

	properties (Hidden)
		sourceList;
		lastPath	= '';
		curPan;
	end

	methods
		function as = addsource(drcn)
			as@dracon.gui.dialog(drcn);
		end

		function ok = show(as)
			as.optUpdate();
			ok = show@dracon.gui.dialog(as);
		end
	end

	methods (Hidden)
		function init(as)
			as.minW = as.WIDTH;
			as.maxW = as.WIDTH;
			as.dMaxW = as.DMAXW;
		end

		function createContent(as)
			pan = as.scroll.panel;
			as.scroll.stickUp = 1;

			screen = get(groot, 'ScreenSize');

			pan.BorderType = 'etchedin';
			pan.BorderWidth = as.PAN_BORDERW;
			as.dlg.Position(3) = as.WIDTH;
			as.dlg.Position(1) = (screen(3) - as.WIDTH)/2;

			classes = meta.package.fromName(as.SOURCE_PATH);
			classes = sort({classes.ClassList.Name});
			names = classes;

			for k = numel(classes):-1:1
				names{k} = eval([classes{k}, '.NAME']);
			end

			as.sourceList = uicontrol(pan, ...
						'String', names, ...
						'Value', 1, ...
						'UserData', [classes; classes], ...
						'HorizontalAlign', 'left', ...
						'Callback', @(pop,~)as.optUpdate());

			if(numel(classes) == 1)
				as.sourceList.Style = 'text';
				bott = as.OPT_T_MARGB;
			else
				as.sourceList.Style = 'popupmenu';
				bott = as.OPT_P_MARGB;
			end
			bott = bott + as.PAN_BORDERW;
			as.sourceList.Position(1) = as.OPT_MARGL;
			as.sourceList.Position(2) = bott + 1;
			as.sourceList.Position(3) = as.WIDTH - ...
										as.OPT_MARGL - ...
										as.OPT_MARGR;
									
			as.sourceList.Position(4) = as.sourceList.Extent(4);
			bott = bott + as.sourceList.Position(4) + as.OPT_MARGT;

			bott = bott + as.PAN_BORDERW;
			pan.Position(4) = bott;
			bott = bott + as.bSpace;
			as.dlg.Position(2) = screen(4) - as.MARGT - bott;
			as.dlg.Position(4) = bott;
		end

		function optUpdate(as)
			opt = as.sourceList.UserData{2, as.sourceList.Value};

			if(isempty(as.curPan))
				dy = 0;
			else
				dy = as.curPan.Position(4);
				as.curPan.Visible = 'off';
			end
			if(ischar(opt))
				init = eval([opt, '.INIT']);
				desc = eval([opt, '.DESC']);
				opt = uipanel(as.scroll.panel, ...
							'BorderType', 'none', ...
							'Units', 'pixels', ...
							'UserData', desc, ...
							'Position', as.sourceList.Position);
				as.sourceList.UserData{2, as.sourceList.Value} = opt;
				opt.Position(2) = 1;
				bott = 1;
				for k = length(init):-1:1
					s = size(init{k}, 2);
					tpos = 3;
					bott = bott + as.OPT_P_MARGB;
					if(s > 1 && iscell(init{k}{2}))
						in = uicontrol(opt, 'Style', 'popupmenu', ...
											 'String', init{k}{2}(1,:));
						in.Position(4) = in.Extent(4);
						if(size(init{k}{2}, 1) > 1)
							in.TooltipString = init{k}{2}{2,1};
							in.Callback = @(~,~)set(in, ...
								'TooltipString', init{k}{2}{2,in.Value});
						end
					elseif(s > 1 && ...
							~isempty(init{k}{2}) && ...
							init{k}{2}(1) == 'F')
						in = uicontrol(opt, ...
									'Style', 'pushbutton', ...
									'String', as.NO_FILE);
						tpos = 4;
						if(numel(init{k}{2}) > 1 && init{k}{2}(2) == '+')
							in.Callback = @(ui,~) ...
										as.fileSelect(ui, init{k}{3}, 1);
						else
							in.Callback = @(ui,~) ...
										as.fileSelect(ui, init{k}{3});
						end
					else
						in = uicontrol(opt, 'Style', 'edit', ...
										'HorizontalAlign', 'left');
						if(s > 2)
							in.TooltipString = init{k}{3};
						end

						if(s > 1)
							in.UserData = {init{k}{1},init{k}{2}};
							if(isempty(init{k}{2}))
								in.UserData{2} = 'S';
							elseif(~isnan(str2double(init{k}{2})))
								in.UserData{2} = ['S', init{k}{2}];
							elseif(isnumeric(init{k}{2}))
								in.UserData{2} = ['S', ...
									num2str(init{k}{2})];
							end

							if(s > 3)
								in.String = init{k}{4};
							end
						end
					end
					in.Position(1) = 1;
					in.Position(2) = bott;
					in.Position(3) = opt.Position(3);
					bott = bott + in.Position(4);

					int = uicontrol(opt, 'Style', 'Text', ...
										 'String', init{k}{1}, ...
										 'HorizontalAlign', 'left');
					int.Position(1) = 1;
					int.Position(2) = bott;
					int.Position(3) = in.Position(3);
					int.Position(4) = int.Extent(4);
					bott = bott + int.Position(4) + as.OPT_PADD;

					if(s >= tpos && ~isempty(init{k}{tpos}))
						int.TooltipString = init{k}{tpos};
					end
				end
				opt.Position(4) = bott;
				opt.Children = opt.Children(end:-1:1);
			end
			as.curPan = opt;
			opt.Visible = 'on';
			dy = opt.Position(4) - dy;
			as.scroll.panel.Position(4) = as.scroll.panel.Position(4) + dy;
			as.sourceList.Position(2) = as.sourceList.Position(2) + dy;

			dy = as.scroll.panel.Position(4) - ...
				as.scroll.window.Position(4);
			if(dy > 0)
				if(dy >= as.dlg.Position(2))
					dy = as.dlg.Position(2) - 1;
				end
				as.scroll.window.Position(4) = dy + ...
					as.scroll.window.Position(4);
				as.dlg.Position(4) = dy + as.dlg.Position(4);
				as.dlg.Position(2) = as.dlg.Position(2) - dy;
			end
			as.sourceList.TooltipString = opt.UserData;
		end

		function onOk(as)
			as.focusOk();
			
			elem = as.curPan.Children(1:2:end);
			num = numel(elem);
			opt = cell(1, num);
			
			try
				for k = 1:num
					opt{num - k + 1} = as.processInput(elem(k));
				end
				as.newSource = feval(as.sourceList. ...
					UserData{1, as.sourceList.Value}, opt{:});
			catch ex
				if(strcmp(ex.identifier, 'MATLAB:FileIO:InvalidFid'))
					msg = as.INVALID_FILE;
				else
					msg = ex.message;
				end
				as.drcn.error('', as.ERR_DLG_TITLE, msg);
				onOk@dracon.gui.dialog(as, 0);
				return;
			end

			onOk@dracon.gui.dialog(as);
		end

		function fileSelect(as, ui, type, mult)
			if(nargin < 4 || mult == 0)
				mult = 'off';
			else
				mult = 'on';
			end
			type = [type; {'*.*', as.ALL_FILES}];
			[data, path] = uigetfile(type, '', as.lastPath, ...
									'MultiSelect', mult);
			if(path ~= 0)
				if(~iscell(data))
					data = {data};
				end
				ui.String = strjoin(data, '; ');
				ui.UserData = strcat(path, data);
				as.lastPath = path;
			end
		end
	end

	methods (Hidden, Static)
		function in = processInput(field)
			if(strcmp(field.Style, 'edit'))
				if(isempty(field.UserData))
					in = field.String;

				elseif(field.UserData{2}(1) == 'S')
					len = str2double(field.UserData{2}(2:end));
					if(~isnan(len) && len > numel(field.String))
						throw(MException('dracon:inputShort',...
							['Input for ''%s'' must be at ', ...
							'least %d characters long.'], ...
							field.UserData{1}, len));
					end
					in = field.String;

				elseif(field.UserData{2} == 'V')
					if(~isvarname(field.String))
						throw(MException('dracon:invalidVariableName',...
							['Input for ''%s'' must be a ', ...
							'valid variable name.'], ...
							field.UserData{1}));
					end
					in = field.String;
					
				else
					in = str2num(field.String); %#ok<ST2NM>
					if(isempty(in))
						throw(MException('dracon:inputNaN',...
							['Input for ''%s'' must be a ', ...
							'number or a calculation.'], ...
							field.UserData{1}));
					end

					nat = ismember('N',field.UserData{2});
					if(mod(in,1) && ...
					   (ismember('Z',field.UserData{2}) || nat))
						throw(MException('dracon:inputReal',...
							'Input for ''%s'' must be an integer.', ...
							field.UserData{1}));
					end

					pos = ismember('+',field.UserData{2});
					neg = ismember('-',field.UserData{2});
					if(in < 0 && (nat || (pos && ~neg)))
						throw(MException('dracon:inputNegative',...
							'Input for ''%s'' must not be negative.', ...
							field.UserData{1}));
					end

					if(in > 0 && (neg && ~pos))
						throw(MException('dracon:inputPositive',...
							'Input for ''%s'' must not be positive.', ...
							field.UserData{1}));
					end

					nul = ismember('0',field.UserData{2});
					if(in == 0 && (nat || pos || neg) && ~nul)
						throw(MException('dracon:inputZero',...
							'Input for ''%s'' must be nonzero.', ...
							field.UserData{1}));
					end
				end
			elseif(strcmp(field.Style, 'pushbutton'))
				in = field.UserData;
				if(~iscell(in))
					throw(MException('dracon:noFile',...
						'At least one file must be selected'));
				end
			else
				in = field.Value;
			end
		end
	end
end
