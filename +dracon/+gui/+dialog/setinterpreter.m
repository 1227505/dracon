classdef setinterpreter < dracon.gui.dialog
%SETINTERPRETER Dialog set the itnerpreter for the output manager
% New interpreter available in as.newInterpreter

	properties
		newInterpreter;
	end

	properties (Constant, Transient, Hidden)
		NAME		= 'Set Interpreter';
		OKTEXT		= 'Select';
		CANCTEXT	= 'Cancel';

		ERR_DLG_TITLE	= 'Set Interpreter ERROR';
		INVALID_FILE	= 'Invalid file path.';

		SOURCE_PATH = 'dracon.output';

		NO_FILE		= 'No File selected';
		ALL_FILES	= 'All Files';

		WIDTH		= 187;
		MARGT		= 120;
		DMAXW		= 202;
		PAN_BORDERW = 1;

		OPT_T_MARGB	= -1;
		OPT_P_MARGB	= 8;
		OPT_MARGL	= 8;
		OPT_MARGR	= 8;
		OPT_MARGT	= 8;
		OPT_PADD	= -3;
	end

	properties (Hidden)
		interList;
		lastPath	= '';
		curPan;
	end

	methods
		function si = setinterpreter(drcn)
			si@dracon.gui.dialog(drcn);
		end

		function ok = show(si)
			si.optUpdate();
			ok = show@dracon.gui.dialog(si);
		end
	end

	methods (Hidden)
		function init(si)
			si.minW = si.WIDTH;
			si.maxW = si.WIDTH;
			si.dMaxW = si.DMAXW;
		end

		function createContent(si)
			pan = si.scroll.panel;
			si.scroll.stickUp = 1;

			screen = get(groot, 'ScreenSize');

			pan.BorderType = 'etchedin';
			pan.BorderWidth = si.PAN_BORDERW;
			si.dlg.Position(3) = si.WIDTH;
			si.dlg.Position(1) = (screen(3) - si.WIDTH)/2;

			classes = meta.package.fromName(si.SOURCE_PATH);
			classes = sort({classes.ClassList.Name});
			names = classes;

			for k = numel(classes):-1:1
				names{k} = eval([classes{k}, '.NAME']);
			end

			si.interList = uicontrol(pan, ...
						'String', names, ...
						'Value', 1, ...
						'UserData', [classes; classes], ...
						'HorizontalAlign', 'left', ...
						'Callback', @(pop,~)si.optUpdate());

			if(numel(classes) == 1)
				si.interList.Style = 'text';
				bott = si.OPT_T_MARGB;
			else
				si.interList.Style = 'popupmenu';
				bott = si.OPT_P_MARGB;
			end
			bott = bott + si.PAN_BORDERW;
			si.interList.Position(1) = si.OPT_MARGL;
			si.interList.Position(2) = bott + 1;
			si.interList.Position(3) = si.WIDTH - ...
										si.OPT_MARGL - ...
										si.OPT_MARGR;
									
			si.interList.Position(4) = si.interList.Extent(4);
			bott = bott + si.interList.Position(4) + si.OPT_MARGT;

			bott = bott + si.PAN_BORDERW;
			pan.Position(4) = bott;
			bott = bott + si.bSpace;
			si.dlg.Position(2) = screen(4) - si.MARGT - bott;
			si.dlg.Position(4) = bott;
		end

		function optUpdate(si)
			opt = si.interList.UserData{2, si.interList.Value};

			if(isempty(si.curPan))
				dy = 0;
			else
				dy = si.curPan.Position(4);
				si.curPan.Visible = 'off';
			end
			if(ischar(opt))
				init = eval([opt, '.INIT']);
				desc = eval([opt, '.DESC']);
				opt = uipanel(si.scroll.panel, ...
							'BorderType', 'none', ...
							'Units', 'pixels', ...
							'UserData', desc, ...
							'Position', si.interList.Position);
				si.interList.UserData{2, si.interList.Value} = opt;
				opt.Position(2) = 1;
				bott = 1;
				for k = length(init):-1:1
					s = size(init{k}, 2);
					tpos = 3;
					bott = bott + si.OPT_P_MARGB;
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
									'String', si.NO_FILE);
						tpos = 4;
						if(numel(init{k}{2}) > 1 && init{k}{2}(2) == '+')
							in.Callback = @(ui,~) ...
										si.fileSelect(ui, init{k}{3}, 1);
						else
							in.Callback = @(ui,~) ...
										si.fileSelect(ui, init{k}{3});
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
					bott = bott + int.Position(4) + si.OPT_PADD;

					if(s >= tpos && ~isempty(init{k}{tpos}))
						int.TooltipString = init{k}{tpos};
					end
				end
				opt.Position(4) = bott;
				opt.Children = opt.Children(end:-1:1);
				uistack(opt, 'bottom');
			end
			si.curPan = opt;
			opt.Visible = 'on';
			dy = opt.Position(4) - dy;
			si.scroll.panel.Position(4) = si.scroll.panel.Position(4) + dy;
			si.interList.Position(2) = si.interList.Position(2) + dy;

			dy = si.scroll.panel.Position(4) - ...
				si.scroll.window.Position(4);
			if(dy > 0)
				if(dy >= si.dlg.Position(2))
					dy = si.dlg.Position(2) - 1;
				end
				si.scroll.window.Position(4) = dy + ...
					si.scroll.window.Position(4);
				si.dlg.Position(4) = dy + si.dlg.Position(4);
				si.dlg.Position(2) = si.dlg.Position(2) - dy;
			end
			si.interList.TooltipString = opt.UserData;
		end

		function onOk(si)
			si.focusOk();
			
			elem = si.curPan.Children(1:2:end);
			num = numel(elem);
			opt = cell(1, num + 1);
			opt{1} = si.drcn;
			
			try
				for k = 1:num
					opt{num - k + 2} = si.processInput(elem(k));
				end
				si.newInterpreter = feval(si.interList. ...
					UserData{1, si.interList.Value}, opt{:});
			catch ex
				if(strcmp(ex.identifier, 'MATLAB:FileIO:InvalidFid'))
					msg = si.INVALID_FILE;
				else
					msg = ex.message;
				end
				si.drcn.error(ex.identifier, si.ERR_DLG_TITLE, msg);
				onOk@dracon.gui.dialog(si, 0);
				return;
			end

			onOk@dracon.gui.dialog(si);
		end

		function fileSelect(si, ui, type, mult)
			if(nargin < 4 || mult == 0)
				mult = 'off';
			else
				mult = 'on';
			end
			type = [type; {'*.*', si.ALL_FILES}];
			[data, path] = uigetfile(type, '', si.lastPath, ...
									'MultiSelect', mult);
			if(path ~= 0)
				if(~iscell(data))
					data = {data};
				end
				ui.String = strjoin(data, '; ');
				ui.UserData = strcat(path, data);
				si.lastPath = path;
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
