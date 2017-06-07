classdef dracon < handle
	% DRACON dynamic representation and creation of neural networks
	% Created by Dorian Staudt.
	%   DRACONOBJ = DRACON
	%   DRACONOBJ = DRACON()
	%   DRACONOBJ = DRACON('gui')
	%   returns an instance of dracon and 
	%   starts the dracon graphical user interface.
	%
	%   DRACONOBJ = DRACON('command')
	%   returns an instance of dracon.
	%
	%   DRACONOBJ = DRACON(___, FILE) 
	%   opens the specified file.
	%   See also OPENFILE

	properties (Constant)
		NAME = 'dracon';	% Title of the gui.
		VERSION = 'v1.1';   % Current version, also part of the title.
	end

	properties
		fname = '';		% Current filename.
	end

	events
		NetsOpened;			% Notified when nets are loaded from a file.
							% No data.
		NetsReset;			% Notified when the current nets are closed.
							% No data.
		NetAdded;			% Notified when a net is created.
							% Uses net data (dracon.util.netdata).
		LayersAdded;		% Notified when layers are added to a net.
							% Uses net data (dracon.util.netdata).
		NodesAdded;			% Notified when nodes are added to a layer.
							% Uses net data (dracon.util.netdata).
		NetRemoved;			% Notified when a net is deleted.
							% Uses net data (dracon.util.netdata).
		LayerRemoved;		% Notified when a layer is deleted.
							% Uses net data (dracon.util.netdata).
		NodeRemoved;		% Notified when a node is deleted.
							% Uses net data (dracon.util.netdata).
		NetMoved;			% Notified when a net is moved.
							% Uses net data (dracon.util.netdata).
		LayersMoved;		% Notified when a group of layers is moved.
							% Uses net data (dracon.util.netdata).
		NodesMoved;			% Notified when a group of nodes is moved.
							% Uses net data (dracon.util.netdata).

		NetsChanged;		% Notified when layers or nodes are changed.
							% Uses net data (dracon.util.netdata).
							
		ValuesChanged;		% Notified when weights or biases are changed.
							% Uses net data (dracon.util.netdata).

		MultiEditStarted;	% Notified when drcn.editMultiple(1) is called
							% and multiEdit is 0.
							% No data.
		MultiEditEnded;		% Notified when drcn.editMultiple(0) is called.
							% and multiEdit is 1.
							% No data.
							
		NetsRun;			% Notified when drcn.run or drcn.runSingle is
							% called.
							% No data.
	end

	properties (Constant, Hidden, Transient)
		DEFAULT_FNAME	= 'New Neural Network';
		DEFAULT_FTYPE	= '.nn';

		DEFAULT_ONCLOSEDELETE = 1;  % Delete instance when GUI is closed

		VIEW_MAIN		= 'network';
		VIEW_PATH		= 'dracon.gui.view';
		
		DLG_PATH		= 'dracon.gui.dialog';

		PREF_FNAME		= 'PREFERENCES.';

		% Changing this makes all older savefiles invalid.
		SAVE_VNAME		= 'NETS';

		OPEN_FILE_ERROR	= 'Open File ERROR';
		FILETYPES		= {'*.nn', 'Neural Network'; '*.*', 'All Files'};

		ONLY_GUI_WARNING= 'This feature is unavailable in command mode.';
		
		NO_COMMON_TRAIN	= 'The current nets cannot be trained together.';
		
		INVALID_NAME	= 'Input must be a valid function name.';
		
		GUI		= 'gui';		% Command to start the gui, default.
		COMM	= 'command';	% Command to start in command line mode.
	end

	properties (Hidden)
		nets = {};		% Current networks.

		pref;			% Preferences.
		dpath;			% Path of the toolkit.

		dialog;			% Dialogs.
		view;			% Windows, views
		menu;			% Menu Items.
		log;			% Log to enable undo/redo actions.
		
		runData = {};	% Values of each layer after nets were run.
	end

	properties (SetAccess = private)
		gui = 0;        % Gui currently on.
		multiEdit = 0;  % Multi edit active
	end

	methods
		function drcn = dracon(mode, net)
		% Create a new instance of dracon.
			[drcn.dpath, ~] = fileparts(mfilename('fullpath'));
			drcn.dpath = [drcn.dpath, '/'];

			drcn.loadPreferences([drcn.dpath, drcn.PREF_FNAME]);

			if(nargin > 0)
				sgui = length(drcn.GUI);
				scom = length(drcn.COMM);
				validateattributes(mode, {'char'}, {'row'}, ...
								   'dracon', 'mode', 1);
				mode = lower(mode);
				smode = length(mode);
				if(strncmpi(mode, drcn.GUI, min(smode, sgui)))
					drcn.gui = 1;
				elseif(~strncmpi(mode, drcn.COMM, min(smode, scom)))
					throw(MException('dracon:wrongArgument',...
						['The first argument must resemble ', ...
						 '''gui'' or ''command''.']));
				end

				if(nargin > 1)
					validateattributes(mode, {'char'}, {'row'}, ...
									   'dracon', 'net', 2);
				else
					net = 0;
				end
			else
				drcn.gui = 1;
				net = 0;
			end


			if(drcn.gui)
				drcn.openGui();
			end

			drcn.log = dracon.general.log(drcn);

			if(net)
				[path, file, ext] = fileparts(net);
				drcn.openFile([file, ext], [path, '/']);
			end

			drcn.addlistener('NetAdded', ...
					@(~,data)drcn.changeNotice(data));
			drcn.addlistener('NetRemoved', ...
					@(~,data)drcn.changeNotice(data));
			drcn.addlistener('NetMoved', ...
					@(~,data)drcn.changeNotice(data));
			drcn.addlistener('LayersAdded', ...
					@(~,data)drcn.changeNotice(data));
			drcn.addlistener('LayerRemoved', ...
					@(~,data)drcn.changeNotice(data));
			drcn.addlistener('LayersMoved', ...
					@(~,data)drcn.changeNotice(data));
			drcn.addlistener('NodesAdded', ...
					@(~,data)drcn.changeNotice(data));
			drcn.addlistener('NodeRemoved', ...
					@(~,data)drcn.changeNotice(data));
			drcn.addlistener('NodesMoved', ...
					@(~,data)drcn.changeNotice(data));
				
			drcn.addlistener('ValuesChanged', ...
					@(~,data)drcn.valuesChanged());
			
			if(drcn.gui)
				drcn.view.(drcn.VIEW_MAIN).focus();
			end
		end

		function openFile(drcn, file, path)
			% OPENFILE Open existing network.
			%   OPENFILE(DRGNOBJ, FILE, PATH)
			%   attempts to open the network FILE on path PATH.
			%   If unsuccesful, an error is thrown.

			validateattributes(file, {'char'}, {'row'}, ...
							   'openFile', 'file', 1);
			validateattributes(path, {'char'}, {'row'}, ...
							   'openFile', 'path', 2);
			if(exist([path, file], 'file'))
				load([path, file], '-mat');
				if(~exist(drcn.SAVE_VNAME, 'var'))
					drcn.error('invalidFile', drcn.OPEN_FILE_ERROR, ...
							   'File of invalid format.');
					return;
				end
				drcn.nets = eval(drcn.SAVE_VNAME);

				drcn.pref.svpath = path;
				drcn.fname = file;

				drcn.setSaved(1);
				drcn.log.reset();
				drcn.notify('NetsOpened');
			else
				drcn.error('noFile', drcn.OPEN_FILE_ERROR, ...
						   'File does not exist.');
			end
		end

		function saved = isSaved(drcn)
			% ISSAVED Current progress has been saved.
			%   SAVED = ISSAVED(DRACONOBJ)
			%   returns 1 if the current progress has been saved,
			%   0 otherwise.

			saved = strcmp('off', drcn.menu.save.Enable);
		end

		function reset(drcn)
			% RESET Reset the network.
			%   RESET(DRACONOBJ)
			%   resets any progress. Preferences are kept.

			drcn.nets = {};
			drcn.fname = '';

			drcn.setSaved(1);
			drcn.log.reset();
			drcn.notify('NetsReset');
		end

		function addNet(drcn, net, x, y)
			% ADDNET Adds net at given position.
			%   ADDNET(DRACONOBJ, NET, X, Y)
			%   Adds NET at position [X, Y].
			%   Set Y to 0 to begin a new column.

			validateattributes(net, {'dracon.nn'}, {'scalar'}, ...
							   'addNet', 'net', 1);
			validateattributes(x, {'numeric'}, {'scalar','positive', ...
							   'integer', '<=', numel(drcn.nets) + 1}, ...
							   'addNet', 'x', 2);
			if(y ~= 0)
				validateattributes(y, {'numeric'}, {'scalar', ...
									'integer', 'positive', ...
									'<=', numel(drcn.nets{x}) + 1}, ...
									'addNet', 'y', 3);
			end

			import dracon.util.netdata
			data = netdata(netdata.ADDNET, x, y);
			if(drcn.gui)
				drcn.log.save(data.copy());
			end
			if(y == 0)
				drcn.nets = [drcn.nets(1:x-1), {{net}}, drcn.nets(x:end)];
			else
				drcn.nets{x} = [drcn.nets{x}(1:y-1), {net}, ...
								drcn.nets{x}(y:end)];
			end

			drcn.notify('NetAdded', data);
		end

		function rmNet(drcn, x, y)
			% RMNET Deletes one net.
			%   RMNET(DRACONOBJ, X, Y)
			%   Deletes net [X, Y].

			validateattributes(x, {'numeric'}, {'scalar','positive', ...
							   'integer', '<=', numel(drcn.nets)}, ...
							   'rmNet', 'x', 1);
			validateattributes(y, {'numeric'}, {'scalar','positive', ...
							   'integer', '<=', numel(drcn.nets{x})}, ...
							   'rmNet', 'y', 2);

			import dracon.util.netdata
			data = netdata(netdata.RMNET, x, y);
			data.net = drcn.nets{x}{y};
			if(numel(drcn.nets{x}) < 2)
				data.num = -1;
			end
			if(drcn.gui)
				drcn.log.save(data.copy());
			end

			if(numel(drcn.nets{x}) > 1)
				drcn.nets{x} = [drcn.nets{x}(1:y-1), ...
								drcn.nets{x}(y+1:end)];
			else
				drcn.nets = [drcn.nets(1:x-1), drcn.nets(x+1:end)];
			end

			drcn.notify('NetRemoved', data);
		end
		
		function moveNet(drcn, x, y, nx, ny)
			if(nx == x && (ny == y || ny == y + 1))
				return;
			end
			validateattributes(x, {'numeric'}, {'scalar','positive', ...
								'integer', '<=', numel(drcn.nets)}, ...
								'moveNet', 'x', 1);
			validateattributes(y, {'numeric'}, {'scalar','positive', ...
								'integer', '<=', numel(drcn.nets{x})}, ...
								'moveNet', 'y', 2);
			validateattributes(nx, {'numeric'}, {'scalar','positive', ...
								'integer', '<=', numel(drcn.nets) + 1}, ...
								'moveNet', 'nx', 3);
							
			em = drcn.editMultiple(1);
			
			import dracon.util.netdata
			data = netdata(netdata.MVNET, [x, nx], [y, ny]);
			if(ny == 0)
				drcn.nets = [drcn.nets(1:nx-1), ...
							{drcn.nets{x}(y)}, ...
							drcn.nets(nx:end)];
				if(x >= nx)
					x = x + 1;
				end
			else
				validateattributes(ny, {'numeric'}, {'scalar', ...
									'integer', 'positive', ...
									'<=', numel(drcn.nets{nx}) + 1}, ...
									'moveNet', 'ny', 4);
				
				drcn.nets{nx} = [drcn.nets{nx}(1:ny-1), ...
								drcn.nets{x}(y), ...
								drcn.nets{nx}(ny:end)];
				if(x == nx && y >= ny)
					y = y + 1;
				end
			end
			if(numel(drcn.nets{x}) > 1)
				drcn.nets{x} = [drcn.nets{x}(1:y-1), ...
								drcn.nets{x}(y+1:end)];
			else
				drcn.nets = [drcn.nets(1:x-1), drcn.nets(x+1:end)];
				data.num = -1;
			end
			if(drcn.gui)
				drcn.log.save(data.copy());
			end
			drcn.notify('NetMoved', data);
			
			if(em)
				drcn.editMultiple(0);
			end
		end

		function addLayers(drcn, x, y, l, nl, nn)
			% ADDLAYERS Adds layers to a network.
			%   ADDLAYERS(DRACONOBJ, X, Y, LAYPOS, NUMLAY, NUMNODES)
			%   Adds NUMLAY layers of size NUMNODES at position LAYPOS to
			%   net [X, Y].

			validateattributes(x, {'numeric'}, {'scalar','positive', ...
							   'integer', '<=', numel(drcn.nets)}, ...
							   'addLayers', 'x', 1);
			validateattributes(y, {'numeric'}, {'scalar','positive', ...
							   'integer', '<=', numel(drcn.nets{x})}, ...
							   'addLayers', 'y', 2);
			net = drcn.nets{x}{y};
			validateattributes(l, {'numeric'}, {'scalar','positive', ...
							   'integer', '<=', net.layers + 1}, ...
							   'addLayers', 'laypos', 3);
			validateattributes(nl, {'numeric'}, {'scalar','positive', ...
							   'integer'}, 'addLayers', 'numlay', 4);
			validateattributes(nn, {'numeric'}, {'scalar','positive', ...
							   'integer'}, 'addLayers', 'numnodes', 5);

			import dracon.util.netdata
			data = netdata(netdata.ADDLAYERS, x, y, l, nn, nl);
			drcn.log.save(data.copy());

			net.addLayers(l - 1, nn, nl);

			drcn.notify('LayersAdded', data);
		end

		function rmLayer(drcn, x, y, l)
			% RMLAYER Deletes one layer from a network.
			%   RMLAYERS(DRACONOBJ, X, Y, LAYPOS)
			%   Deletes layer LAYPOS from net [X, Y].

			validateattributes(x, {'numeric'}, {'scalar','positive', ...
							   'integer', '<=', numel(drcn.nets)}, ...
							   'rmLayer', 'x', 1);
			validateattributes(y, {'numeric'}, {'scalar','positive', ...
							   'integer', '<=', numel(drcn.nets{x})}, ...
							   'rmLayer', 'y', 2);
			net = drcn.nets{x}{y};
			validateattributes(l, {'numeric'}, {'scalar','>=', 0, ...
							   'integer', '<=', net.layers}, ...
							   'rmLayer', 'laypos', 3);

			if (net.layers < 2)
				drcn.rmNet(x, y);
			else                
				import dracon.util.netdata
				data = netdata(netdata.RMLAYER, x, y, l, 0, 1);
				data.nodePos = drcn.getLayerHeight(net, l);
				drcn.log.save(data.copy());

				net.rmLayer(l);

				drcn.notify('LayerRemoved', data);
			end
		end
		
		function moveLayers(drcn, x, y, nx, ny, l, r, nlp)
			if(nx == x && ny == y && l - 1 <= nlp && r >= nlp)
				return;
			end
			
			validateattributes(x, {'numeric'}, {'scalar','positive', ...
								'integer', '<=', numel(drcn.nets)}, ...
								'moveLayers', 'x', 1);
			validateattributes(y, {'numeric'}, {'scalar','positive', ...
								'integer', '<=', numel(drcn.nets{x})}, ...
								'moveLayers', 'y', 2);
			validateattributes(nx, {'numeric'}, {'scalar','positive', ...
								'integer', '<=', numel(drcn.nets)}, ...
								'moveLayers', 'nx', 3);
			validateattributes(ny, {'numeric'}, {'scalar','positive', ...
								'integer', '<=', numel(drcn.nets{nx})}, ...
								'moveLayers', 'ny', 4);
			validateattributes(r, {'numeric'}, {'scalar','positive', ...
								'integer', '<=', ...
								drcn.nets{x}{y}.layers}, ...
								'moveLayers', 'r', 6);
			validateattributes(l, {'numeric'}, {'scalar','positive', ...
								'integer', '<=', r}, ...
								'moveLayers', 'l', 5);
			validateattributes(nlp, {'numeric'}, {'scalar','>=', 0, ...
								'integer', '<=', ...
								drcn.nets{nx}{ny}.layers}, ...
								'moveLayers', 'nlp', 7);
			
			em = drcn.editMultiple(1);
			
			n = drcn.nets{x}{y};
			nn = drcn.nets{nx}{ny};
			
			bi = n.biases(l:r);
			we = n.weights(l+1:r);
			
			for k = l:r-1
				n.rmLayer(l);
			end
			rmn = n.rmLayer(l);
			
			import dracon.util.netdata
			data = netdata(netdata.MVLAYERS, [x, nx], [y, ny], ...
												[l, r, nlp]);
			
			if(nx == x && ny == y && nlp >= l)
				nlp = nlp - r + l - 1;
				rmn = 0;
			end
			nn.insertLayers(nlp, bi, we);
			
			if(drcn.gui)
				drcn.log.save(data.copy());
			end
			drcn.notify('LayersMoved', data);
			
			if(rmn)
				drcn.rmNet(x, y);
			end
			
			if(em)
				drcn.editMultiple(0);
			end
		end

		function addNodes(drcn, x, y, l, nn)
			% ADDNODES Adds nodes to a layer.
			%   ADDNODES(DRACONOBJ, X, Y, LAYPOS, NUMNODES)
			%   Adds NUMNODES nodes to layer LAYPOS in net [X, Y].

			validateattributes(x, {'numeric'}, {'scalar','positive', ...
							   'integer', '<=', numel(drcn.nets)}, ...
							   'addNodes', 'x', 1);
			validateattributes(y, {'numeric'}, {'scalar','positive', ...
							   'integer', '<=', numel(drcn.nets{x})}, ...
							   'addNodes', 'y', 2);
			net = drcn.nets{x}{y};
			validateattributes(l, {'numeric'}, {'scalar','>=', 0, ...
							   'integer', '<=', net.layers}, ...
							   'addNodes', 'laypos', 3);
			validateattributes(nn, {'numeric'}, {'scalar','positive', ...
							   'integer'}, 'addLayers', 'numnodes', 4);

			import dracon.util.netdata
			data = netdata(netdata.ADDNODES, x, y, l, 0, nn);
			data.nodePos = drcn.getLayerHeight(net, data.layPos) + 1;
			drcn.log.save(data.copy());

			net.addNodes(l, nn);

			drcn.notify('NodesAdded', data);
		end

		function rmNode(drcn, x, y, l, n)
			% RMNODE Deletes one node from a layer.
			%   RMLAYERS(DRACONOBJ, X, Y, LAYPOS, NODEPOS)
			%   Deletes node NODEPOS from layer LAYPOS in net [X, Y].

			validateattributes(x, {'numeric'}, {'scalar','positive', ...
							   'integer', '<=', numel(drcn.nets)}, ...
							   'rmNode', 'x', 1);
			validateattributes(y, {'numeric'}, {'scalar','positive', ...
							   'integer', '<=', numel(drcn.nets{x})}, ...
							   'rmNode', 'y', 2);
			net = drcn.nets{x}{y};
			validateattributes(l, {'numeric'}, {'scalar','>=', 0, ...
							   'integer', '<=', net.layers}, ...
							   'rmNode', 'laypos', 3);
			h = drcn.getLayerHeight(net, l);
			validateattributes(n, {'numeric'}, {'scalar','positive', ...
							   'integer', '<=', h}, ...
							   'rmNode', 'nodepos', 4);

			if (h < 2)
				drcn.rmLayer(x, y, l);
			else
				import dracon.util.netdata
				data = netdata(netdata.RMNODE, x, y, l, n, 1);
				drcn.log.save(data.copy());

				net.rmNode(l, n);

				drcn.notify('NodeRemoved', data);
			end
		end
		
		function moveNodes(drcn, x, y, nx, ny, lp, nlp, t, b, nnp)
			if(x == nx && y == ny && lp == nlp && ...
					t <= nnp && b + 1 >= nnp)
				return;
			end
			
			validateattributes(x, {'numeric'}, {'scalar','positive', ...
								'integer', '<=', numel(drcn.nets)}, ...
								'moveNodes', 'x', 1);
			validateattributes(y, {'numeric'}, {'scalar','positive', ...
								'integer', '<=', numel(drcn.nets{x})}, ...
								'moveNodes', 'y', 2);
			validateattributes(nx, {'numeric'}, {'scalar','positive', ...
								'integer', '<=', numel(drcn.nets)}, ...
								'moveNodes', 'nx', 3);
			validateattributes(ny, {'numeric'}, {'scalar','positive', ...
								'integer', '<=', numel(drcn.nets{nx})}, ...
								'moveNodes', 'ny', 4);
			validateattributes(lp, {'numeric'}, {'scalar','positive', ...
								'integer', '<=', ...
								drcn.nets{x}{y}.layers}, ...
								'moveNodes', 'lp', 5);
			validateattributes(nlp, {'numeric'}, {'scalar','positive', ...
								'integer', '<=', ...
								drcn.nets{nx}{ny}.layers}, ...
								'moveNodes', 'nlp', 6);
			validateattributes(b, {'numeric'}, {'scalar','positive', ...
								'integer', '<=', ...
								numel(drcn.nets{x}{y}.biases{lp}) + 1}, ...
								'moveNodes', 'b', 8);
			validateattributes(t, {'numeric'}, {'scalar','positive', ...
								'integer', '<=', b}, ...
								'moveNodes', 't', 7);
			validateattributes(nnp, {'numeric'}, {'scalar','positive', ...
							'integer', '<=', ...
							numel(drcn.nets{nx}{ny}.biases{nlp}) + 1}, ...
							'moveNodes', 'nnp', 9);
			
			em = drcn.editMultiple(1);
			
			n = drcn.nets{x}{y};
			nn = drcn.nets{nx}{ny};
			
			bi = n.biases{lp}(t:b);
			
			nnum = b - t + 1;
			
			nn.insertNodes(nlp, nnp - 1, bi);
			
			if(nx == x && ny == y && nlp == lp && nnp <= t)
				t = t + nnum;
				b = b + nnum;
			end
			
			if(length(n.biases{lp}) <= nnum)
				rml = 1;
			else
				rml = 0;
				for k = t:b
					n.rmNode(lp, t);
				end
			end
			
			import dracon.util.netdata
			data = netdata(netdata.MVNODES, [x, nx], [y, ny], ...
											[lp, nlp], [t, b, nnp]);
			if(drcn.gui)
				drcn.log.save(data.copy());
			end
			drcn.notify('NodesMoved', data);
			
			if(rml)
				if(n.layers < 1)
					n.layers = 1;
					n.biases = {[]};
					n.weights = {[]};
					drcn.rmNet(x, y);
				else
					n.biases = [n.biases(1:lp-1), {[]}, ...
							n.biases(lp+1:end)];
					drcn.rmLayer(x, y, lp);
				end
			end
			
			if(em)
				drcn.editMultiple(0);
			end
		end

		function net = getNet(drcn, x, y)
			% GETNET Returns one net.
			%   NET = GETNET(DRACONOBJ, X, Y)
			%   returns the net at position [X, Y].

			validateattributes(x, {'numeric'}, {'scalar','positive', ...
							   'integer','<=',numel(drcn.nets)}, ...
							   'getNet', 'x', 1);
			validateattributes(y, {'numeric'}, {'scalar','positive', ...
							   'integer','<=',numel(drcn.nets{x})}, ...
							   'getNet', 'y', 2);

			net = drcn.nets{x}{y};
		end
		
		function [out, a] = run(drcn, in, ev)
			validateattributes(drcn.nets, {'cell'}, {'nonempty'}, ...
								'run', 'nets');
			if(nargin < 3 || ev~= 0)
				ev = 1;
			end
			
			len = numel(drcn.nets);
			l1 = numel(drcn.nets{1});
			if(len == 1 && l1 == 1)
				out = {{drcn.runSingle(1, 1, in, ev)}};
				return;
			end
			
			inter = cell(1, len - 1);
			
			i = 0;
			for y = 1:l1
				i = i + drcn.nets{1}{y}.in;
			end
			validateattributes(in, {'numeric'}, {'nrows', i}, ...
								'run', 'in', 1);
			batch = size(in, 2);
			for x = 1:len-1
				o = 0;
				for y = 1:numel(drcn.nets{x})
					o = o + drcn.nets{x}{y}.out;
				end
				i = 0;
				for y = 1:numel(drcn.nets{x+1})
					i = i + drcn.nets{x+1}{y}.in;
				end
				inter{x} = zeros(o, batch);
				validateattributes(inter{x}, {'numeric'}, {'nrows', i}, ...
									'run', ['inter-output ', num2str(x)]);
			end
			
			data = drcn.nets;
			for k = 1:len-1
				posin = 0;
				netnum = numel(drcn.nets{k});
				for l = 1:netnum
					data{k}{l} = drcn.nets{k}{l}.run(in(posin+1: ...
						posin+drcn.nets{k}{l}.in,:), batch);
					posin = posin + drcn.nets{k}{l}.in;
				end
				in = inter{k};
				posout = 0;
				for l = 1:netnum
					in(posout+1:posout+drcn.nets{k}{l}.out,:) = ...
						data{k}{l}{end};
					posout = posout + drcn.nets{k}{l}.out;
				end
			end

			posin = 0;
			for l = 1:numel(drcn.nets{end});
				data{end}{l} = drcn.nets{end}{l}.run(in(posin+1: ...
					posin+drcn.nets{end}{l}.in,:), batch);
				posin = posin + drcn.nets{end}{l}.in;
			end
			
			out = [];
			if(~isempty(data))
				for k = 1:numel(drcn.nets{end})
					out = [out; data{end}{k}{end}]; %#ok<AGROW>
				end
			end
			if(nargout == 2)
				a = data;
			end
			
			if(ev)
				drcn.runData = data;
				drcn.notify('NetsRun');
			end
			
		end
		
		function out = runSingle(drcn, x, y, in, ev)
			validateattributes(x, {'numeric'}, {'scalar','positive', ...
							'integer', '<=', numel(drcn.nets)}, ...
							'runSingle', 'x', 1);
			validateattributes(y, {'numeric'}, {'scalar','positive', ...
							'integer', '<=', numel(drcn.nets{x})}, ...
							'runSingle', 'y', 2);
			n = drcn.nets{x}{y};
			validateattributes(in, {'numeric'}, ...
					{'nrows', n.in}, 'runSingle', 'in', 3);
			if(nargin < 5 || ev~= 0)
				ev = 1;
			end
				
			out = n.run(in, size(in, 2));
			if(numel(drcn.nets) == 1 && numel(drcn.nets{1}) == 1 && ev)
				drcn.runData = {{out}};
			end
			out = out{end};
			
			if(ev)
				drcn.notify('NetsRun');
			end
		end
		
		function out = getInfluence(drcn, in, nods)
			validateattributes(drcn.nets, {'cell'}, {'nonempty'}, ...
								'getInfluence', 'nets');
			
			len = numel(drcn.nets);
			l1 = numel(drcn.nets{1});
			if(len == 1 && l1 == 1)
				out = {{drcn.getInfluenceSingle(1, 1, in, nods{1}{1})}};
				return;
			end
			
			inter = cell(1, len - 1);
			
			i = 0;
			for y = 1:l1
				i = i + drcn.nets{1}{y}.in;
			end
			validateattributes(in, {'numeric'}, {'nrows', i}, ...
								'getInfluence', 'in', 1);
			validateattributes(nods, {'cell'}, { ...
							'numel', numel(drcn.nets)}, ...
							'getInfluence', 'nods', 2);
			
			for x = 1:len-1
				o = 0;
				for y = 1:numel(drcn.nets{x})
					o = o + drcn.nets{x}{y}.out;
				end
				i = 0;
				for y = 1:numel(drcn.nets{x+1})
					i = i + drcn.nets{x+1}{y}.in;
				end
				inter{x} = zeros(o, 1);
				validateattributes(inter{x}, {'numeric'}, {'nrows', i}, ...
							'getInfluence', ['inter-output ', num2str(x)]);
			end
			
			out = drcn.nets;
			for k = 1:len-1
				posin = 0;
				netnum = numel(drcn.nets{k});
				for l = 1:netnum
					out{k}{l} = drcn.nets{k}{l}.getInfluence( ...
						x(posin+1:posin+drcn.nets{k}{l}.in, :), ...
						nods{k}{l});
					posin = posin + drcn.nets{k}{l}.in;
				end
				x = inter{k};
				posout = 0;
				for l = 1:netnum
					x(posout+1:posout+drcn.nets{k}{l}.out,:) = ...
						out{k}{l}{end};
					posout = posout + drcn.nets{k}{l}.out;
				end
			end

			posin = 0;
			netnum = numel(drcn.nets{len});
			for l = 1:netnum
				out{len}{l} = drcn.nets{len}{l}.getInfluence(x(posin+1: ...
					posin+drcn.nets{len}{l}.in,:), nods{len}{l});
				posin = posin + drcn.nets{len}{l}.in;
			end
		end
		
		function out = getInfluenceSingle(drcn, x, y, in, nods)
			validateattributes(x, {'numeric'}, {'scalar','positive', ...
							'integer', '<=', numel(drcn.nets)}, ...
							'getInfluence', 'x', 1);
			validateattributes(y, {'numeric'}, {'scalar','positive', ...
							'integer', '<=', numel(drcn.nets{x})}, ...
							'getInfluence', 'y', 2);
			n = drcn.nets{x}{y};
			validateattributes(in, {'numeric'}, ...
					{'nrows', n.in}, 'getInfluence', 'in', 3);
				
			out = n.getInfluence(in, nods);
		end
		
		function [err, eps] = train(drcn, in, out, rate, stop, eps, batch)
			validateattributes(drcn.nets, {'cell'}, {'nonempty'}, ...
								'train', 'nets');
			len = numel(drcn.nets);
			l1 = numel(drcn.nets{1});
			
			comb = drcn.nets{1}{1}.combgroup;
			for x = 1:len
				for y = 1:numel(drcn.nets{x})
					if(~strcmp(comb, drcn.nets{x}{y}.combgroup))
						throw(MException('dracon:train:combgroup', ...
										drcn.NO_COMMON_TRAIN));
					end
				end
			end
			
			i = 0;
			for y = 1:l1
				i = i + drcn.nets{1}{y}.in;
			end
			validateattributes(in, {'numeric'}, {'nonempty'}, ...
								'train', 'in', 1);
			validateattributes(in, {'numeric'}, {'nrows', i}, ...
								'train', 'in', 1);
			validateattributes(out, {'numeric'}, ...
								{'ncols', size(in, 2)}, ...
								'train', 'out', 2);
			o = 0;
			for y = 1:numel(drcn.nets{end})
				o = o + drcn.nets{end}{y}.out;
			end
			validateattributes(out, {'numeric'}, {'nrows', o}, ...
								'train', 'out', 2);
			validateattributes(rate, {'numeric'}, ...
								{'scalar','positive'}, 'train', 'rate', 3);
				
			if(nargin < 7)
				batch = size(in, 2);
				if(nargin < 6)
					eps = 10000;
					if(nargin < 5)
						stop = 0.1;
					else
						validateattributes(stop, {'numeric'}, ...
												{'scalar', 'positive'}, ...
												'train', 'stop', 4);
					end
				else
					validateattributes(eps, {'numeric'}, ...
									{'scalar', 'positive', 'integer'}, ...
									'train', 'maxIt', 5);
				end
			else
				validateattributes(batch, {'numeric'}, ...
								{'scalar', 'positive', 'integer'}, ...
								'train', 'batch', 6);
			end
			
			if(len == 1 && l1 == 1)
				[err, eps] = drcn.trainSingle(1, 1, in, out, rate, ...
											stop, eps, batch);
				return;
			end
			
			all = size(in ,2);
			m = mod(all, batch);
			inter = cell(1, len - 1);
			if(m)
				interm = inter;
			end
			
			for x = 1:len-1
				o = 0;
				for y = 1:numel(drcn.nets{x})
					o = o + drcn.nets{x}{y}.out;
				end
				i = 0;
				for y = 1:numel(drcn.nets{x+1})
					i = i + drcn.nets{x+1}{y}.in;
				end
				inter{x} = zeros(o, batch);
				if(m)
					interm{x} = inter{x};
				end
				validateattributes(inter{x}, {'numeric'}, {'nrows', i}, ...
								'train', ['inter-output ', num2str(x)]);
			end
			
			stop = stop * all;
			n = drcn.nets{end}{1};
			
			err = sum(n.err(out, drcn.run(in, 0), all));
			
			if(stop >= err)
				eps = 0;
				err = err / all;
				return;
			end
			
			import dracon.util.netdata
			data = netdata(netdata.CHVALUES, 0, 0);
			drcn.log.save(data.copy());
			
			rate = rate / batch;
			nb = (all-m) / batch;
			pos = cell(1,nb);
			best = drcn.nets;
			
			for x = 1:len-1
				o = 0;
				for y = 1:numel(drcn.nets{x})
					o = o + drcn.nets{x}{y}.out;
				end
				i = 0;
				for y = 1:numel(drcn.nets{x+1})
					i = i + drcn.nets{x+1}{y}.in;
				end
				inter{x} = zeros(o, batch);
				validateattributes(inter{x}, {'numeric'}, {'nrows', i}, ...
									'run', ['inter-output ', num2str(x)]);
			end
			
			for k = 1:nb
				pos{k} = (k-1)*batch+1:k*batch;
			end
			if(m > 0)
				pos = [pos, {nb*batch+1:all}];
				nb = nb + 1;
			else
				m = batch;
				interm = inter;
			end

			ns = drcn.cloneNets();

			if(drcn.gui)
				wstr1 = 'Epoch ';
				wstr2 = [' of ', num2str(eps)];
				wstr3 = ', best error: ';
				wstre = num2str(err / all);
				w = waitbar(0,[wstr1, '1', wstr2, wstr3, wstre], ...
					'CreateCancelBtn', @(b,~)set(b.Parent,'UserData',1));
				w.UserData = 0;
				w.Children(2).Title.FontSize = 9;
				w.Name = ['Training ', drcn.fname, '...'];
				w.WindowStyle = 'modal';
				drawnow;
			end
			for k = 1:eps
				if(nb > 1)
					id = randperm(all);
					in = in(:, id);
					out = out(:, id);
				end
				for l = 1:nb-1
					[~, a] = drcn.run(in(:, pos{l}), 0);
					n.trainComb(ns, len, a, ...
						out(:, pos{l}), rate, batch, all, inter);
				end
				[~, a] = drcn.run(in(:, pos{end}), 0);
				n.trainComb(ns, len, a, ...
					out(:, pos{end}), rate, m, all, interm);
				
				% TODO: Make run intern for speed
				nerr = sum(n.err(out, drcn.run(in, 0), all));
				
				if(nerr < err)
					if(nerr <= stop)
						best = ns;
						err = nerr;
						break;
					else
						err = nerr;
						best = drcn.cloneNets(ns);
					end
				end
				if(drcn.gui)
					waitbar(k / eps, w, ...
						[wstr1, num2str(k + 1), wstr2, wstr3, wstre]);
					if(w.UserData == 1)
						break;
					end
				end
			end
			if(drcn.gui)
				delete(w);
			end
			
			drcn.nets = best;
			err = err/all;
			eps = k;
			drcn.notify('ValuesChanged', data);
		end
		
		function [err, eps] = trainSingle(drcn, x, y, in, out, rate, ...
										stop, eps, batch)
			validateattributes(x, {'numeric'}, {'scalar', 'positive', ...
							'integer', '<=', numel(drcn.nets)}, ...
							'trainSingle', 'x', 1);
			validateattributes(y, {'numeric'}, {'scalar', 'positive', ...
							'integer', '<=', numel(drcn.nets{x})}, ...
							'trainSingle', 'y', 2);
			n = drcn.nets{x}{y};
			validateattributes(in, {'numeric'}, ...
					{'nonempty'}, 'trainSingle', 'in', 3);
			validateattributes(in, {'numeric'}, ...
					{'nrows', n.in}, 'trainSingle', 'in', 3);
			validateattributes(out, {'numeric'}, ...
					{'nrows', n.out}, 'trainSingle', 'out', 4);
			validateattributes(out, {'numeric'}, ...
								{'ncols', size(in, 2)}, ...
								'trainSingle', 'out', 4);
			validateattributes(rate, {'numeric'}, ...
					{'scalar','positive'}, 'trainSingle', 'rate', 5);
				
			if(nargin < 9)
				batch = size(in, 2);
				if(nargin < 8)
					eps = 10000;
					if(nargin < 7)
						stop = 0.1;
					else
						validateattributes(stop, {'numeric'}, ...
												{'scalar', 'positive'}, ...
												'trainSingle', 'stop', 6);
					end
				else
					validateattributes(eps, {'numeric'}, ...
									{'scalar', 'positive', 'integer'}, ...
									'trainSingle', 'maxIt', 7);
				end
			else
				validateattributes(batch, {'numeric'}, ...
								{'scalar', 'positive', 'integer'}, ...
								'trainSingle', 'batch', 8);
			end
			
			
			all = size(in ,2);
			err = sum(n.err(out, drcn.runSingle(x, y, in, 0), all));
			stop = stop * all;
			
			if(stop >= err)
				eps = 0;
				err = err / all;
				return;
			end
			
			import dracon.util.netdata
			data = netdata(netdata.CHVALUES, x, y);
			drcn.log.save(data.copy());
			

			rate = rate / batch;
			m = mod(all, batch);
			nb = (all-m) / batch;
			pos = cell(1,nb);
			best = n.clone();
			for k = 1:nb
				pos{k} = (k-1)*batch+1:k*batch;
			end
			if(m > 0)
				pos = [pos, {nb*batch+1:all}];
				nb = nb + 1;
			else
				m = batch;
			end

			if(drcn.gui)
				wstr1 = 'Epoch ';
				wstr2 = [' of ', num2str(eps)];
				wstr3 = ', best error: ';
				wstre = num2str(err / all);
				w = waitbar(0,[wstr1, '1', wstr2, wstr3, wstre], ...
					'CreateCancelBtn', @(b,~)set(b.Parent,'UserData',1));
				w.UserData = 0;
				w.Children(2).Title.FontSize = 9;
				w.Name = ['Training ', drcn.fname, '...'];
				w.WindowStyle = 'modal';
				drawnow;
			end
			for k = 1:eps
				if(nb > 1)
					id = randperm(all);
					in = in(:, id);
					out = out(:, id);
				end
				for l = 1:nb-1
					n.train(n.run(in(:, pos{l}), batch), ...
						out(:, pos{l}), rate, batch, all);
				end
				n.train(n.run(in(:, pos{end}), batch), ...
					out(:, pos{end}), rate, m, all);
				nerr = sum(n.err(out, n.runSimple(in, all), all));
				
				if(nerr < err)
					if(nerr <= stop)
						best = n;
						err = nerr;
						break;
					else
						err = nerr;
						best = n.clone();
						if(drcn.gui)
							wstre = num2str(err / all);
						end
					end
				end
				if(drcn.gui)
					waitbar(k / eps, w, ...
						[wstr1, num2str(k + 1), wstr2, wstr3, wstre]);
					if(w.UserData == 1)
						break;
					end
				end
			end
			if(drcn.gui)
				delete(w);
			end
			
			drcn.nets{x}{y} = best;
			err = err / all;
			eps = k;
			drcn.notify('ValuesChanged', data);
		end
		
		function randomizeBiases(drcn, mu, sigma)
			validateattributes(mu, {'numeric'}, {'scalar', 'finite'}, ...
							'randomizeBiases', 'mu', 1);
			validateattributes(sigma, {'numeric'}, {'scalar', 'finite'}, ...
							'randomizeBiases', 'sigma', 2);
			
			import dracon.util.netdata
			data = netdata(netdata.CHVALUES, 0, 0);
			drcn.log.save(data.copy());
			for x = 1:numel(drcn.nets)
				for y = 1:numel(drcn.nets{x})
					drcn.nets{x}{y}.randomizeBiases(mu, sigma);
				end
			end
			drcn.notify('ValuesChanged');
		end
		
		function randomizeWeights(drcn, mu, sigma)
			validateattributes(mu, {'numeric'}, {'scalar', 'finite'}, ...
							'randomizeBiases', 'mu', 1);
			validateattributes(sigma, {'numeric'}, {'scalar', 'finite'}, ...
							'randomizeBiases', 'sigma', 2);
			
			import dracon.util.netdata
			data = netdata(netdata.CHVALUES, 0, 0);
			drcn.log.save(data.copy());
			for x = 1:numel(drcn.nets)
				for y = 1:numel(drcn.nets{x})
					drcn.nets{x}{y}.randomizeWeights(mu, sigma);
				end
			end
			drcn.notify('ValuesChanged');
		end
		
		function export(drcn)
			validateattributes(drcn.nets, {'cell'}, {'nonempty'}, ...
								'export', 'nets');
			
			len = numel(drcn.nets);
			l1 = numel(drcn.nets{1});
			if(len == 1 && l1 == 1)
				drcn.exportSingle(1, 1);
				return;
			end
			
			inter = zeros(1, len);
			for x = 1:len-1
				for y = 1:numel(drcn.nets{x})
					inter(x) = inter(x) + drcn.nets{x}{y}.out;
				end
				i = 0;
				for y = 1:numel(drcn.nets{x+1})
					i = i + drcn.nets{x+1}{y}.in;
				end
				validateattributes(zeros(inter(x), 1), {'numeric'}, ...
					{'nrows', i}, 'export', ['inter-output ', num2str(x)]);
			end
			
			for y = 1:numel(drcn.nets{end})
				inter(end) = inter(end) + drcn.nets{end}{y}.out;
			end
			
			[file, path] = uiputfile({'*.m', 'MATLAB Code files'; ...
										'*.*', 'All Files'}, '', ...
									drcn.pref.svpath);
			if(file == 0)
				return;
			end
			
			in = 0;
			for y = 1:l1
				in = in + drcn.nets{1}{y}.in;
			end
			
			[~, name] = fileparts(file);
			if(~isvarname(name))
				throw(MException('dracon:export:invalidName', ...
								drcn.INVALID_NAME));
			end
			
			drcn.pref.svpath = path;
			out = fopen([path, file], 'w');
			
			fprintf(out, 'function out = %s(in)\n', name);
			fprintf(out, ['\t%%%s Artificial Neural Network created ', ...
						'with %s %s by Dorian Staudt.\n'], upper(name), ...
						drcn.NAME, drcn.VERSION);
			fprintf(out, '\t%%\tInput: Numeric array of height %d.\n', in);
			fprintf(out, ['\t%%\tOutput: Numeric array of the same ', ...
						'width, and height %d.\n\n'], inter(end));
					
			fprintf(out, '\tnum = size(in, 2);\n');
			for x = 1:len
				posi = 0;
				poso = 0;
				fprintf(out, '\tout = zeros(%d, num);\n', inter(x));
				for y = 1:numel(drcn.nets{x})
					n = drcn.nets{x}{y};
					
					fprintf(out, '\n\t%% Column %d, Row %d: %s\n', ...
								x, y, n.name);
					fprintf(out, '\tx = in(%d:%d, :);\n', ...
									posi+1, posi+n.in);
					fprintf(out, n.getCode());
					fprintf(out, '\tout(%d:%d, :) = x;\n', ...
									poso+1, poso+n.out);
					
					posi = posi + n.in;
					poso = poso + n.out;
				end
				if(x < len)
					fprintf(out, '\tin = out;\n');
				end
			end
			fprintf(out, 'end');
			
			fclose(out);
		end
		
		function exportSingle(drcn, x, y)
			validateattributes(x, {'numeric'}, {'scalar', 'positive', ...
							'integer', '<=', numel(drcn.nets)}, ...
							'exportSingle', 'x', 1);
			validateattributes(y, {'numeric'}, {'scalar', 'positive', ...
							'integer', '<=', numel(drcn.nets{x})}, ...
							'exportSingle', 'y', 2);
			
			[file, path] = uiputfile({'*.m', 'MATLAB Code files'; ...
										'*.*', 'All Files'}, '', ...
									drcn.pref.svpath);
			if(file == 0)
				return;
			end
			
			[~, name] = fileparts(file);
			if(~isvarname(name))
				throw(MException('dracon:export:invalidName', ...
								drcn.INVALID_NAME));
			end
			
			n = drcn.nets{x}{y};
			drcn.pref.svpath = path;
			out = fopen([path, file], 'w');
			
			fprintf(out, 'function x = %s(x)\n', name);
			fprintf(out, ['\t%%%s Artificial Neural Network created ', ...
						'with %s %s by Dorian Staudt.\n'], upper(name), ...
						drcn.NAME, drcn.VERSION);
			fprintf(out, '\t%%\tInput: Numeric array of height %d.\n', ...
						n.in);
			fprintf(out, ['\t%%\tOutput: Numeric array of the same ', ...
						'width, and height %d.\n\n'], n.out);
			
			fprintf(out, '\t%% %s\n', n.name);
			fprintf(out, '\tnum = size(x, 2);\n');
			fprintf(out, n.getCode());
			fprintf(out, 'end');
			
			fclose(out);
		end
		
		function out = getLastOutput(drcn)
			out = [];
			if(~isempty(drcn.runData))
				for k = 1:numel(drcn.nets{end})
					out = [out; drcn.runData{end}{k}{end}]; %#ok<AGROW>
				end
			end
		end
		
		function d = getLayerActivation(drcn, x, y, l)
			validateattributes(x, {'numeric'}, {'scalar','positive', ...
							'integer', '<=', numel(drcn.nets)}, ...
							'getLayerActivation', 'x', 1);
			validateattributes(y, {'numeric'}, {'scalar','positive', ...
							'integer', '<=', numel(drcn.nets{x})}, ...
							'getLayerActivation', 'y', 2);
			validateattributes(l, {'numeric'}, {'scalar','positive', ...
							'integer', '<=', drcn.nets{x}{y}.layers}, ...
							'getLayerActivation', 'l', 3);
							
			if(isempty(drcn.runData))
				d = zeros(numel(drcn.nets{x}{y}.biases{l}), 1);
			else
				d = drcn.runData{x}{y}{l};
			end
		end

		function loadPreferences(drcn, file)
			% LOADPREFERENCES Loads saved preferences.
			%   LOADPREFERENCES(DRAGPNOBJ, FILE)
			%   loads saved preferences from the file FILE.
			%   Unset fields are set to their default value.

			validateattributes(file, {'char'}, {'row'}, ...
							   'loadPreferences', 'file', 1);

			if(exist(file, 'file'))
				load(file, '-mat');
				if(exist(drcn.SAVE_VNAME, 'var'))
					drcn.pref = eval(drcn.SAVE_VNAME);
				end
			end

			if(~isfield(drcn.pref, 'svpath'))
				drcn.pref.svpath = '';
			end

			if(~isfield(drcn.pref, 'view'))
				drcn.pref.view = [];
			end

			views = meta.package.fromName(drcn.VIEW_PATH);
			views = sort({views.ClassList.Name});
			for k = 1:length(views)
				v = strsplit(views{k}, '.');
				v = v{end};
				if(~isfield(drcn.pref.view, v))
					drcn.pref.view.(v) = [];
				end
				if(~isfield(drcn.pref.view.(v), 'pos'))
					drcn.pref.view.(v).pos = ...
						eval([views{k}, '.getDefaultPos();']);
				end
				if(~isfield(drcn.pref.view.(v), 'show'))
					drcn.pref.view.(v).show = ...
						eval([views{k}, '.DEFAULT_SHOW;']);
				end
			end
			drcn.pref.view.(drcn.VIEW_MAIN).show = 'on';
		end

		function openGui(drcn)
			drcn.gui = 1;

			if(isempty(drcn.dialog))
				dlgs = meta.package.fromName(drcn.DLG_PATH);
				dlgs = {dlgs.ClassList.Name};
				for k = 1:length(dlgs)
					d = strsplit(dlgs{k}, '.');
					drcn.dialog.(d{end}) = feval(dlgs{k}, drcn);
				end
			end
			
			views = fieldnames(drcn.pref.view);
			rem = [];
			if(isempty(drcn.view))
				for k = 1:length(views)
					try
						drcn.view.(views{k}) = ...
							feval([drcn.VIEW_PATH, '.', views{k}], drcn);
					catch err
						if(strcmp(err.identifier, ...
								  'MATLAB:UndefinedFunction'))
							drcn.warning('View not available', ...
										 ['View ''', views{k}, ...
										  ''' not available, removed ', ...
										  'from preferences.']);
							drcn.pref.view = ...
								rmfield(drcn.pref.view, views{k});
							rem = [rem, k]; %#ok<AGROW>
						else
							rethrow(err);
						end
					end
				end

				dracon.gui.menu.init(drcn);

				drcn.addlistener('NetAdded', ...
						@(~,~)drcn.setSaved(0));
				drcn.addlistener('NetRemoved', ...
						@(~,~)drcn.setSaved(0));

				drcn.setSaved(1);
			end
			views = views(setdiff(1:length(views), rem));

			for k = 1:numel(views)
				drcn.view.(views{k}).fig.OuterPosition = ...
					drcn.pref.view.(views{k}).pos;
				if(strcmp('on', drcn.pref.view.(views{k}).show))
					dracon.gui.util.toggleView(drcn, views{k});
				end
			end
		end

		function nets = cloneNets(drcn, nets)
			if(nargin < 2)
				nets = drcn.nets;
			end
			for x = 1:numel(drcn.nets)
				for y = 1:numel(drcn.nets{x})
					nets{x}{y} = drcn.nets{x}{y}.clone();
				end
			end
		end

		function done = editMultiple(drcn, start)
			if(drcn.multiEdit && start == 0)
				drcn.notify('MultiEditEnded');
				drcn.multiEdit = 0;
				done = 1;
			elseif(~drcn.multiEdit && start ~= 0)
				drcn.notify('MultiEditStarted');
				drcn.multiEdit = 1;
				done = 1;
			else
				done = 0;
			end
		end

		function dlg = getDlg(drcn, name)
			validateattributes(name, {'char'}, {'nonempty', 'row'}, ...
							   'getDlg', 'name', 1);

			if(isfield(drcn.dialog, name))
				dlg = drcn.dialog.(name);
			else
				dlg = 0;
				name = regexprep(name, '\W', '');
				names = fields(drcn.dialog);
				len = length(name);
				for k = 1:length(names)
					if(strncmpi(name, names{k}, len))
						dlg = drcn.dialog.(names{k});
						break;
					end
				end
			end
		end

		function dlg = getView(drcn, name)
			validateattributes(name, {'char'}, {'nonempty', 'row'}, ...
							   'getView', 'name', 1);

			if(isfield(drcn.view, name))
				dlg = drcn.view.(name);
			else
				dlg = 0;
				name = regexprep(name, '\W', '');
				names = fields(drcn.view);
				len = length(name);
				for k = 1:length(names)
					vname = drcn.view.(names{k}).NAME;
					vname = regexprep(vname, '\W', '');
					if(strncmpi(name, names{k}, len) || ...
							strncmpi(name, vname, len))
						dlg = drcn.view.(names{k});
						break;
					end
				end
			end
		end
	end

	methods (Hidden)        
		function error(drcn, type, title, msg)
			% ERROR Throw error, use a dialog, if the gui is used.
			if(drcn.gui)
				waitfor(errordlg(msg, title, 'modal'));
			else
				throw(MException(['dracon:', type], msg));
			end
		end

		function warning(drcn, title, msg)
			% WARNING Display warning, use a dialog, if the gui is used.
			if(drcn.gui)
				waitfor(warndlg(msg, title, 'modal'));
			else
				warning(msg);
			end
		end

		function setSaved(drcn, saved)
			% SETSAVED Adjusts title and menu, doesn't actually save
			% anything.
			if(drcn.gui)
				if(isempty(drcn.fname))
					name = [dracon.DEFAULT_FNAME, dracon.DEFAULT_FTYPE];
				else
					name = drcn.fname;
				end

				if(saved)
					drcn.menu.save.Enable = 'off';
				else
					name = [name, '*'];
					drcn.menu.save.Enable = 'on';
				end

				views = fieldnames(drcn.view);
				for i = 1:size(views,1)
					drcn.view.(views{i}).setName(name);
				end
			end
		end

		function changeNotice(drcn, data)
			drcn.setSaved(0);
			drcn.runData = {};
			drcn.notify('NetsChanged', data.copy());
		end
		
		function valuesChanged(drcn)
			drcn.setSaved(0);
			drcn.runData = {};
		end

		function height = getLayerHeight(drcn, net, lp)
			if (length(net) == 2)
				net = drcn.nets{net(1)}{net(2)};
			end
			if(lp == 0)
				height = net.in;
			else
				height = length(net.biases{lp});
			end
		end
	end
end
