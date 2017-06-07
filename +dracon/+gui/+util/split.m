classdef split < handle
%SPLIT Description TODO

	properties (Constant, Transient)
		VERTICAL = 0;
		HORIZONTAL = 1;
	end

	properties (Hidden, Constant, Transient)
	end

	properties (Hidden)
		left;		% Left or bottom object
		right;		% Right or top object
		fig;		% Figure containing the objects
					% (not necessarily the direct parent)
		dir;		% Vertical or horizontal split
		parMarg;	% Margin of the parent in relation to the figure
		
		lastPoint;	% Last mouse position
		move	= 0;% Move split
	end

	methods
		function s = split(left, right, fig, dir, parMarg)
			if(nargin < 5)
				s.parMarg = [0 0];
				if(nargin < 4)
					s.dir = s.VERTICAL;
				else
					s.dir = dir;
				end
			else
				s.parMarg = parMarg;
			end
			
			s.left = left;
			s.right = right;
			s.fig = fig;
			
			left.Units = 'pixels';
			right.Units = 'pixels';
			
			s.lastPoint = s.getCurrentPoint();
			
			left.Parent.ButtonDownFcn = @(~,~)s.onButtonDown();
		end
	end

	% Call these in the Window event functions of the containing figure.
	methods (Hidden)
		function onButtonUp(s)
			s.move = 0;
			s.onMove();
		end

		function onMove(s)
			cp = s.getCurrentPoint();
			if(s.move)
				d = cp(s.dir + 1) - s.lastPoint(s.dir + 1);
				
				if(d < 0)
					if(cp(s.dir + 1) > s.right.Position(s.dir + 1))
						s.lastPoint = cp;
						return;
					end
					d = -min(-d, s.left.Position(3 + s.dir));
				else
					if(cp(s.dir + 1) < s.left.Position(s.dir + 3))
						s.lastPoint = cp;
						return;
					end
					d = min(d, s.right.Position(3 + s.dir));
				end
				
				if(d ~= 0)
					s.left.Position(3 + s.dir) = ...
										s.left.Position(3 + s.dir) + d;
					s.right.Position(3 + s.dir) = ...
										s.right.Position(3 + s.dir) - d;
					s.right.Position(1 + s.dir) = ...
										s.right.Position(1 + s.dir) + d;
				end
				
				if(s.dir == s.VERTICAL)
					s.fig.Pointer = 'left';
				else
					s.fig.Pointer = 'top';
				end
				
			else
				if(s.dir == s.VERTICAL)
					if(cp(1) > s.left.Position(3) && ...
							cp(1) < s.right.Position(1) && ...
							cp(2) >= 1 && ...
							cp(2) <= s.left.Parent.Position(4))
						s.fig.Pointer = 'left';
					elseif(s.lastPoint(1) > s.left.Position(3) && ...
							s.lastPoint(1) < s.right.Position(1) && ...
							s.lastPoint(2) >= 1 && ...
							s.lastPoint(2) <= s.left.Parent.Position(4))
						s.fig.Pointer = 'arrow';
					end
				else
					if(cp(2) > s.left.Position(4) && ...
							cp(2) < s.right.Position(2) && ...
							cp(1) >= 1 && ...
							cp(1) <= s.left.Parent.Position(3))
						s.fig.Pointer = 'top';
					elseif(s.lastPoint(2) > s.left.Position(4) && ...
							s.lastPoint(2) < s.right.Position(2) && ...
							s.lastPoint(1) >= 1 && ...
							s.lastPoint(1) <= s.left.Parent.Position(3))
						s.fig.Pointer = 'arrow';
					end
				end
			end
			s.lastPoint = cp;
		end
	end
	
	methods (Hidden)
		function onButtonDown(s)
			switch s.fig.SelectionType
				case 'normal'
					s.move = 1;
			end
		end
		
		function cp = getCurrentPoint(s)
			cp = s.fig.CurrentPoint - s.parMarg;
		end
	end
end

