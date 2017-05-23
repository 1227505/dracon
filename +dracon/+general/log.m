classdef log < handle
	%LOG Summary of this class goes here
	%   Detailed explanation goes here

	properties (Constant, Transient, Hidden)
		LOGSIZE = 20;
	end

	properties
		drcn;
	end

	properties (Hidden, SetAccess = private)
		pos;
	end

	properties (Access = private)
		savedC;
		savedN;
	end


	methods
		function l = log(drcn)
			l.drcn = drcn;
			drcn.addlistener('MultiEditStarted', @(~,~)l.startMultiEdit());
			drcn.addlistener('MultiEditEnded', @(~,~)l.endMultiEdit());
			l.reset();
		end

		function save(l, cData)
			l.drcn.menu.undo.Enable = 'on';
			l.drcn.menu.redo.Enable = 'off';

			if(l.drcn.multiEdit)
				l.savedC = [{[cData, l.savedC{1}]}, l.savedC(2:end)];
			else
				m = min(numel(l.savedC), l.LOGSIZE - 1);
				l.savedC = [{cData}, l.savedC(l.pos:m)];
				l.savedN = [{l.drcn.cloneNets()}, l.savedN(l.pos:m)];
			end

			l.pos = 1;
			for k = 1:numel(cData)
				l.invertData(k);
			end
		end

		function undo(l)
			if(l.pos <= numel(l.savedC))
				l.do();
				l.pos  = l.pos + 1;

				l.drcn.menu.redo.Enable = 'on';
				len = numel(l.savedC);
				if(l.pos > len)
					l.drcn.menu.undo.Enable = 'off';
				end
			end
		end

		function redo(l)
			if(l.pos > 1)
				l.pos  = l.pos - 1;
				l.do();

				l.drcn.menu.undo.Enable = 'on';
				l.drcn.setSaved(0);
				if(l.pos < 2)
					l.drcn.menu.redo.Enable = 'off';
				end
			end
		end

		function reset(l)
			import dracon.util.netdata
			l.savedC = {};
			l.savedN = {};
			l.pos = 1;
			l.drcn.menu.undo.Enable = 'off';
			l.drcn.menu.redo.Enable = 'off';
		end
	end

	methods (Access = private)
		function do(l)
			nets = l.savedN{l.pos};
			l.savedN{l.pos} = l.drcn.nets;
			l.drcn.nets = nets;

			for k = 1:numel(l.savedC{l.pos})
				data = l.savedC{l.pos}(k).copy();

				switch(data.type)
					case data.ADDNET
						l.drcn.notify('NetAdded', data);
						
					case data.ADDLAYERS
						l.drcn.notify('LayersAdded', data);
						
					case data.ADDNODES
						l.drcn.notify('NodesAdded', data);
						
					case data.RMNET
						l.drcn.notify('NetRemoved', data);
						
					case data.RMLAYER
						for j = 1:data.num
							l.drcn.notify('LayerRemoved', data);
						end
						
					case data.RMNODE
						for j = 1:data.num
							l.drcn.notify('NodeRemoved', data);
						end
						
					case data.MVNET
							l.drcn.notify('NetMoved', data);
							
					case data.MVLAYERS
							l.drcn.notify('LayersMoved', data);
						
					case data.MVNODES
							l.drcn.notify('NodesMoved', data);
						
					case data.CHVALUES
							l.drcn.notify('ValuesChanged', data);
				end

				l.invertData(k);
			end
			l.savedC{l.pos} = l.savedC{l.pos}(end:-1:1);
		end

		function invertData(l, k)
			data = l.savedC{l.pos}(k);

			data.invertType();

			switch data.type
				case data.ADDNET
					if(data.netY == 1 && ( ...
							(~isempty(data.num) && data.num == -1)))
						data.netY = 0;
					end
					
				case data.RMNET
					if(data.netY == 0)
						data.netY = 1;
					end
			
				case data.MVNET
					data.netX = data.netX([2,1]);
					data.netY = data.netY([2,1]);
					if(data.netY(2) == 1 && ( ...
							(~isempty(data.num) && data.num == -1)))
						data.netY(2) = 0;
						if(data.netX(1) < data.netX(2))
							data.netX(2) = data.netX(2) + 1;
						else
							data.netX(1) = data.netX(1) - 1;
						end
					end
					if(data.netY(1) == 0)
						data.netY(1) = 1;
						if(data.netX(1) <= data.netX(2) && ...
								data.netY(2) > 0)
							data.netX(2) = data.netX(2) + 1;
						end
					else
						if(~isempty(data.num) && data.num == -1 && ...
								data.netX(1) < data.netX(2))
							data.netX(2) = data.netX(2) - 1;
						end
					end
					
				case data.MVLAYERS
					data.netX = data.netX([2,1]);
					data.netY = data.netY([2,1]);
					l = data.layPos(3) + 1;
					nlp = data.layPos(1);
					num = data.layPos(2) - data.layPos(1) + 1;
					r = data.layPos(3) + num;
					
					if(data.netX(1) == data.netX(2) && ...
							data.netY(1) == data.netY(2))
					
						if(r > nlp)
							l = l - num;
							r = r - num;
							nlp = nlp - 1;
						else
							nlp = nlp + num - 1;
						end
					else
						nlp = nlp - 1;
					end
					
					data.layPos = [l, r, nlp];
					
				case data.MVNODES
					data.netX = data.netX([2,1]);
					data.netY = data.netY([2,1]);
					data.layPos = data.layPos([2,1]);
					t = data.nodePos(3);
					nnp = data.nodePos(1);
					num = data.nodePos(2) - data.nodePos(1) + 1;
					b = data.nodePos(3) + num - 1;
					
					if(data.netX(1) == data.netX(2) && ...
							data.netY(1) == data.netY(2) && ...
							data.layPos(1) == data.layPos(2))
					
						if(t > nnp)
							t = t - num;
							b = b - num;
						else
							nnp = nnp + num;
						end
					end
					
					data.nodePos = [t, b, nnp];
			end
		end

		function startMultiEdit(l)
			if(~l.drcn.multiEdit)
				m = min(numel(l.savedC), l.LOGSIZE - 1);
				l.savedN = [{l.drcn.cloneNets()}, l.savedN(l.pos:m)];
				import dracon.util.netdata
				l.savedC = [{netdata.empty(0,0)}, l.savedC(l.pos:m)];
			end
		end

		function endMultiEdit(l)
			if(~isempty(l.savedC) && isempty(l.savedC{1}))
				l.savedC = l.savedC(2:end);
				l.savedN = l.savedN(2:end);
			end
		end
	end
end

