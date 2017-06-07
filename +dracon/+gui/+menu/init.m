function init(drcn)
% INIT Initializes the menu bar.
	import dracon.gui.*;
	import dracon.gui.menu.update;
	main = drcn.view.(drcn.VIEW_MAIN).fig;

	% Necessary to deactivate ctrl+W close shortcut
	main.Visible = 'on';
	drawnow;
	main.MenuBar = 'none';

	% File
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	m = uimenu(main, 'label', 'File', 'pos', 1);

	% Open
	uimenu(m, 'label', 'Open', 'accel', 'O', ...
				'call', @(~,~)dracon.gui.menu.file.open(drcn));

	% Close
	uimenu(m, 'label', 'Close and New', 'accel', 'W', ...
				'separator', 'on', ...
				'call', @(~,~)dracon.gui.menu.file.close(drcn));

	% Save
	% The handle is saved so it can be dis-/enabled.
	drcn.menu.save = uimenu(m, 'label', 'Save', 'accel', 'S', ...
				'separator', 'on', ...
				'call', @(~,~)dracon.gui.menu.file.save(drcn));

	% Save as
	uimenu(m, 'label', 'Save as...', ...
			  'call', @(~,~)dracon.gui.menu.file.saveas(drcn));

	% Export
	drcn.menu.export = uimenu(m, 'label', 'Export', 'Enable', 'off', ...
				'call', @(~,~)dracon.gui.menu.file.export(drcn));

	% Exit
	uimenu(m, 'label', 'Exit', 'separator', 'on', 'accel', 'Q', ...
			  'call', @(~,~)dracon.gui.menu.file.exit(drcn));
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% Edit
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		m = uimenu(main, 'label', 'Edit', 'pos', 2);

		% Undo
		drcn.menu.undo = uimenu(m, 'label', 'Undo', 'Enable', 'off', ...
						 'accel', 'Z', ...
						 'call', @(~,~)dracon.gui.menu.edit.undo(drcn));

		% Redo
		drcn.menu.redo = uimenu(m, 'label', 'Redo', 'Enable', 'off', ...
						 'accel', 'Y', ...
						 'call', @(~,~)dracon.gui.menu.edit.redo(drcn));

		% Add
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		m2 = uimenu(m, 'label', 'Add...', 'separator', 'on');

		% New Network
		uimenu(m2, 'label', 'New Network', 'accel', 'N', ...
					'call', @(~,~)dracon.gui.menu.edit.add.newnet(drcn));

		% Layers
		drcn.menu.addlay = uimenu(m2, 'label', 'Layers to a Network', ...
					'Enable', 'off', ...
					'call', @(~,~)dracon.gui.menu.edit.add.layers(drcn));

		% Nodes
		drcn.menu.addnod = uimenu(m2, 'label', 'Nodes to a Layer', ...
					'Enable', 'off', ...
					'call', @(~,~)dracon.gui.menu.edit.add.nodes(drcn));
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		% Remove
		%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
		m2 = uimenu(m, 'label', 'Delete...');

		% New Network
		drcn.menu.rmnet = uimenu(m2, 'label', 'Network', ...
					'Enable', 'off', ...
					'call', @(~,~)dracon.gui.menu.edit.rm.net(drcn));

		% Layers
		drcn.menu.rmlay = uimenu(m2, 'label', 'Layer', 'Enable', 'off', ...
					'call', @(~,~)dracon.gui.menu.edit.rm.layer(drcn));

		% Nodes
		drcn.menu.rmnod = uimenu(m2, 'label', 'Node', 'Enable', 'off', ...
					'call', @(~,~)dracon.gui.menu.edit.rm.node(drcn));
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	% View
	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	m = uimenu(main, 'label', 'View', 'pos', 3);

	% All (Generated)
		views = fieldnames(drcn.view);
		lv = length(views);
		pos = zeros(1, lv);
		for k = 1:lv
			pos(k) = drcn.view.(views{k}).POSITION;
			drcn.menu.view.(views{k}) = uimenu(m, ...
				'label', drcn.view.(views{k}).NAME, ...
				'accel', drcn.view.(views{k}).SHORTKEY, ...
				'call', @(~,~)dracon.gui.util.toggleView(drcn,views{k}));
			if(strcmp(views{k}, drcn.VIEW_MAIN))
				drcn.menu.view.(views{k}).Enable = 'off';
			end
		end
		[~, pos] = sort(pos(end:-1:1), 'descend');
		m.Children = m.Children(pos);

	%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	drcn.addlistener('NetsOpened', @(~,~)update(drcn));
	drcn.addlistener('NetsReset', @(~,~)update(drcn));
	drcn.addlistener('NetRemoved', @(~,~)update(drcn));
	drcn.addlistener('NetAdded', @(~,~)update(drcn));
end

