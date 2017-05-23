classdef addnet < dracon.gui.dialog
%ADDNET Dialog for net generation.
	properties (Constant, Transient, Hidden)
		NAME = 'Add new Neural Network';
		OKTEXT = 'Add Network';
		CANCTEXT = 'Cancel';
		NET_PATH = 'dracon.nn';

		TNAME = 'Name:';
		FNAME_DEFAULT = 'Net';
		TPOS = 'Insert';
		FIRSTCOLTEXT = 'As new first column';
		COLTEXT1 = 'In column ';
		COLTEXT2 = 'After column ';
		FIRSTROWTEXT = 'As new first row';
		ROWTEXT = 'After net ';

		ERRDLGTITLE = 'Add Net ERROR';

		MARGT = 120;
		MARGB = 80;
		WIDTH = 400;
		DMAXW = 450;

		NETPOSYMARGB = 4;

		PANMARGB = 5;
		PANMARGL = 5;
		PANMARGR = 1;
		PANBORDERW = 1;
		PANBORDERT = 'etchedin';


		OPTPMARGR = 8;
		OPTPMARGL = 8;
		OPTPMARGT = -2;
		OPTPMARGB = 8;

		OPTPTMARGT = 7;

		OPTTMARGB = -1;


		INOPTMARG = -8;

		INTMARGL = 8;
		INTMARGT = 8;
		INTMARGB = -10;

		INFMARGL = 8;
		INFMARGT = 8;
		INFMARGB = 0;

		INMARGB = 10;
	end

	properties (Hidden)
		type;
		posX;
		posY;
		netName;
	end

	methods
		function an = addnet(drcn)
			an@dracon.gui.dialog(drcn);
		end

		function ok = show(an, x, y)
			name = strtrim(an.netName.String);

			if(nargin == 3)
				an.posX.Value = x + 1;
				an.posY.Value = y + 1;
			end

			if(isempty(an.drcn.nets))
				if(isempty(name))
					an.netName.String = [an.FNAME_DEFAULT, ' 1'];
				end

				an.posX.Value = 1;
				an.posX.Enable = 'off';
			else
				len = numel(an.FNAME_DEFAULT);
				if(isempty(name) || ...
						(strcmp(an.FNAME_DEFAULT, name(1:len)) && ...
						~isnan(str2double(name(len+2:end)))))

					if(isempty(name))
						name = [an.FNAME_DEFAULT, ' 1'];
						i = 1;
					else
						i = str2double(name(len+2:end));
					end

					next = 1;
					while(next)
						next = 0;
						for j = 1:numel(an.drcn.nets)
							for k = 1:numel(an.drcn.nets{j})
								next = strcmp(name, an.drcn.nets{j}{k}.name);
								if(next)
									i = i + 1;
									break;
								end
							end
							if(next)
								break;
							end
						end
						name = [an.FNAME_DEFAULT, ' ', dec2base(i,10)];
					end
					an.netName.String = name;
				end

				numnets = numel(an.drcn.nets);
				cols = cell(1,numnets*2+1);
				cols{1} = an.FIRSTCOLTEXT;
				for i = 1:numnets
					cols{i*2} = [an.COLTEXT1, dec2base(i,10)];
					cols{i*2+1} = [an.COLTEXT2, dec2base(i,10)];
				end
				an.posX.Value = min(an.posX.Value, numnets*2+1);
				an.posX.String = cols;
				an.posX.Enable = 'on';
			end

			an.colCallback();

			ok = show@dracon.gui.dialog(an);
		end
	end

	methods (Hidden)
		function init(an)
			an.minW = an.WIDTH;
			an.maxW = an.WIDTH;
			an.dMaxW = an.DMAXW;
		end

		function createContent(an)
			pan = an.scroll.panel;

			screen = get(groot, 'ScreenSize');
			maxH = screen(4) - an.MARGT - an.MARGB;

			pan.BorderType = 'etchedin';
			pan.BorderWidth = an.PANBORDERW;
			an.dlg.Position(3) = an.WIDTH;
			an.dlg.Position(1) = (screen(3) - an.WIDTH)/2;

			[bott, an.type] = an.fillPanel(pan, an.NET_PATH, an.PANMARGB);
			bott = bott + an.NETPOSYMARGB;
			popW = pan.Position(3) - an.OPTPMARGL - an.OPTPMARGR - ...
				   an.PANBORDERW * 2;

			bott = bott + an.INFMARGB;
			an.posY = uicontrol(pan, 'Style', 'popupmenu', ...
									 'String', an.FIRSTROWTEXT, ...
									 'Enable', 'off');
			an.posY.Position = ...
				[an.INFMARGL, bott, popW, an.posY.Extent(4)];
			uistack(an.posY, 'bottom');

			bott = bott + an.INFMARGT + an.posY.Position(4) + an.INFMARGB;

			an.posX = uicontrol(pan, 'Style', 'popupmenu', ...
							   'String', an.FIRSTCOLTEXT, ...
							   'Enable', 'off', ...
							   'Callback', @(~,~)an.colCallback());
			an.posX.Position = ...
				[an.INFMARGL, bott, popW, an.posX.Extent(4)];
			uistack(an.posX, 'bottom');

			bott = bott + an.INFMARGT + an.posX.Position(4) + an.INTMARGB;

			u = uicontrol(pan, 'Style', 'Text', ...
							   'String', an.TPOS, ...
							   'HorizontalAlign', 'left');
			u.Position = [an.INTMARGL, bott, popW, ...
						  ceil(u.Extent(3)/popW)*u.Extent(4)];
			uistack(u, 'bottom');

			bott = bott + u.Position(4) + an.INTMARGT + an.INFMARGB;

			an.netName = uicontrol(pan, 'Style', 'edit', ...
										'HorizontalAlign', 'left');
			an.netName.Position(1:3) = [an.INFMARGL, bott, popW];
			uistack(an.netName, 'bottom');

			bott = bott + an.INFMARGT + ...
					an.netName.Position(4) + an.INTMARGB;

			u = uicontrol(pan, 'Style', 'Text', ...
							   'String', an.TNAME, ...
							   'HorizontalAlign', 'left');
			u.Position = [an.INTMARGL, bott, popW, ...
						  ceil(u.Extent(3)/popW)*u.Extent(4)];
			uistack(u, 'bottom');
			bott = bott + u.Position(4) + an.INTMARGT;

			pan.Position(4) = bott;

			maxH = min(maxH, bott + an.bSpace);
			an.dlg.Position(2) = screen(4) - an.MARGT - maxH;
			an.dlg.Position(4) = maxH;
		end

		function [bott, pop] = fillPanel(an, pan, path, bott)
			lists = meta.package.fromName(path);
			classes = sort({lists.ClassList.Name});
			names = classes;

			def = 1;
			for k = numel(classes):-1:1
				if(eval([classes{k}, '.DEFAULT']))
					def = k;
				end
				names{k} = eval([classes{k}, '.NAME']);
			end

			desc = eval([classes{def}, '.DESC']);
			opt = eval([classes{def}, '.OPT']);

			invpan = uipanel(pan, 'BorderType', 'none', 'Units', 'pixels');
			invpan.Position(2) = bott;
			ibott = 1;

			npan = an.addOptions(classes{def}, invpan, ibott);
			if(npan == 0)
				npan = ibott;
			else
				ibott = ibott + npan.Position(4);
				uistack(npan, 'bottom');
			end

			popW = pan.Position(3) - an.OPTPMARGL - ...
									an.OPTPMARGR - an.PANBORDERW * 2;

			pop = uicontrol(invpan, 'String', names, ...
								  'TooltipString', desc, ...
								  'HorizontalAlign', 'left', ...
								  'Callback', @(pop,~)an.update(pop));
			if(numel(classes) == 1)
				pop.Style = 'text';
				ibott = ibott + an.OPTTMARGB;
				pop.UserData = {1,{classes{1};npan}};
				pop.Value = 1;
			else
				pop.Style = 'popupmenu';
				pop.UserData = {def,[classes; classes]};
				pop.UserData{2}{2,def} = npan;
				pop.Value = def;
				ibott = ibott + an.OPTPMARGB;
			end
			uistack(pop, 'bottom');
			pop.Position = [an.OPTPMARGL, ibott, popW, ceil(pop.Extent(3)/popW)*pop.Extent(4)];
			ibott = ibott + pop.Position(4) + an.OPTPMARGT;

			u = uicontrol(invpan, 'Style', 'Text', ...
								  'String', [opt, ':'], ...
								  'HorizontalAlign', 'left');
			uistack(u, 'bottom');
			u.Position = [an.OPTPMARGL, ibott, popW, ceil(u.Extent(3)/popW)*u.Extent(4)];
			ibott = ibott + u.Position(4) + an.OPTPTMARGT;

			invpan.Position(4) = ibott;
			bott = bott + ibott - 1;
			pan.Position(4) = bott;
		end

		function npan = addOptions(an, path, pan, bott)
			packs = meta.package.fromName(path);
			init = eval([path, '.INIT']);

			sPacks = size(packs, 2);
			sInit = size(init, 2); 
			if(sPacks || sInit)
				data = {gobjects(1,sInit), gobjects(1,sPacks)};
				panW = pan.Position(3) - an.PANMARGL - ...
						an.PANMARGR - an.PANBORDERW * 2;
				npan = uipanel(pan, 'Units', 'pixels', ...
									'BorderWidth', an.PANBORDERW, ...
									'BorderType', an.PANBORDERT, ...
									'Position', [an.PANMARGL, bott, ...
												panW, 0]);
				bott = an.PANMARGB;

				if(sPacks)
					packs = {packs.PackageList.Name};
					for k = sPacks:-1:1
						[bott, data{2}(k)] = ...
							an.fillPanel(npan, packs{k}, bott);
					end

					if(sInit)
						bott = bott + an.INOPTMARG;
					end
				end

				if(sInit)
					bott = bott + an.INMARGB;
					popW = npan.Position(3) - an.OPTPMARGL - ...
							an.OPTPMARGR - an.PANBORDERW * 2;
					for k = sInit:-1:1
						s = size(init{k},2);

						bott = bott + an.INFMARGB;
						if(s > 1 && iscell(init{k}{2}))
							in = uicontrol(npan, 'Style', 'popupmenu', ...
												 'String', init{k}{2});
							in.Position = [an.INFMARGL, bott, ...
											popW, in.Extent(4)];
						else
							in = uicontrol(npan, 'Style', 'edit', ...
											'HorizontalAlign', 'left');

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
							in.Position(1:3) = [an.INFMARGL, bott, popW];
						end
						uistack(in, 'bottom');

						bott = bott + an.INFMARGT + ...
									in.Position(4) + an.INTMARGB;
						data{1}(k) = in;

						int = uicontrol(npan, 'Style', 'Text', ...
											 'String', init{k}{1}, ...
											 'HorizontalAlign', 'left');
						int.Position = [an.INTMARGL, bott, popW, ...
								ceil(int.Extent(3)/popW)*int.Extent(4)];
						uistack(int, 'bottom');
						bott = bott + int.Position(4) + an.INTMARGT;

						if(s > 2 && ~isempty(init{k}{3}))
							in.TooltipString = init{k}{3};
							int.TooltipString = init{k}{3};
						end
					end
					npan.Position(4) = bott;
				end
				npan.UserData = data;
			else
				npan = 0;
			end
		end

		function update(an, pop)
			pos = pop.Value;
			if(pop.UserData{1} ~= pos)
				pop.TooltipString = eval([pop.UserData{2}{1,pos}, '.DESC']);
				bott = pop.UserData{2}{2,pop.UserData{1}};
				if(~isnumeric(bott))
					bott.Visible = 'off';
					height = -bott.Position(4);
					bott = bott.Position(2);
				else
					height = 0;
				end

				if(ischar(pop.UserData{2}{2,pos}))
					npan = an.addOptions(pop.UserData{2}{1,pos}, ...
										pop.Parent, bott);
					if(npan == 0)
						pop.UserData{2}{2,pos} = bott;
					else
						pop.UserData{2}{2,pos} = npan;
						height = height + npan.Position(4);
					end
				elseif(~isnumeric(pop.UserData{2}{2,pos}))
					pop.UserData{2}{2,pos}.Visible = 'on';
					height = height + pop.UserData{2}{2,pos}.Position(4);
				end

				if(height ~= 0)
					par = pop.Parent;
					while(par ~= an.scroll.window)
						for i = 1:numel(par.Children)
							c = par.Children(i);
							if(c.Position(2) > bott)
								c.Position(2) = c.Position(2) + height;
							end
						end

						par.Position(4) = par.Position(4) + height;
						bott = par.Position(2);
						par = par.Parent;
					end
				end

				dpos2 = an.dlg.Position(2);
				if(height > 0 && dpos2 > an.MARGB)
					dpos4 = an.dlg.Position(4);
					height = an.scroll.panel.Position(4) + an.bSpace;
					if(height > dpos4)
						an.dlg.Position(2) = max(dpos2 - height + dpos4, an.MARGB);
						an.dlg.Position(4) = dpos4 + dpos2 - an.dlg.Position(2);
					end
				end

				pop.UserData{1} = pos;
				an.onResize();
			end
		end

		function colCallback(an)
			pos = an.posX.Value;
			if(mod(pos,2))
				an.posY.Value = 1;
				an.posY.String = an.FIRSTROWTEXT;
				an.posY.Enable = 'off';
			else
				pos = pos/2;
				rows = numel(an.drcn.nets{pos});
				an.posY.Value = min(an.posY.Value, rows+1);
				text = cell(1,rows+1);
				text{1} = an.FIRSTROWTEXT;
				for i = 1:rows
					text{i+1} = [an.ROWTEXT, dec2base(i,10), ' (', ...
								 an.drcn.nets{pos}{i}.name, ')'];
				end
				an.posY.String = text;
				an.posY.Enable = 'on';
			end
		end

		function onOk(an)
			an.focusOk();
			try
				[~, net] = an.createNet(an.type);
			catch ex
				an.drcn.error('', an.ERRDLGTITLE, ex.message);
				onOk@dracon.gui.dialog(an, 0);
				return;
			end

			net.name = strtrim(an.netName.String);

			x = an.posX.Value;
			if(mod(x,2))
				an.drcn.addNet(net, (x+1)/2, 0);
			else
				an.drcn.addNet(net, x/2, an.posY.Value);
			end

			onOk@dracon.gui.dialog(an);
		end

		function [nopt, opt] = createNet(an, field)
			if(iscell(field.UserData))
				name = field.UserData{2}{1,field.Value};
				field = field.UserData{2}{2,field.Value};

				if(~isnumeric(field))
					sInit = size(field.UserData{1},2);
					sOpt = size(field.UserData{2},2);

					args = cell(1,sInit+sOpt);

					for i = 1:sInit
						args{i} = an.processInput(field.UserData{1}(i));
					end

					for i = 1:sOpt
						[nopt, opt] = an.createNet(field.UserData{2}(i));
						args{sInit+i} = {nopt,opt};
					end
				else
					args = {};
				end

				opt = feval(name, args{:});
				nopt = strsplit(name, '.');
				nopt = nopt{end-1};
			else
				opt = 0;
				nopt = 0;
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
			else
				in = field.Value;
			end
		end
	end
end
