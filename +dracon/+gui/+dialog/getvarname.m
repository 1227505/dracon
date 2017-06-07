classdef getvarname < dracon.gui.dialog
	%GETVARNAME Dialog to enter the name of a variable.
	% The name is saved in gv.newName
	properties (Constant, Transient, Hidden)
		NAME		= 'Enter Variable Name';
		OKTEXT		= 'Select Name';
		CANCTEXT	= 'Cancel';
		
		VNAME		= 'Variable Name:';
		ERR_DLG_TITLE	= 'Get Variable Name ERROR';
		INVALID_NAME	= 'Input must be a valid variable name.';

		WIDTH = 187;
		DMAXW = 202;
		MARGT = 120;

		PANBORDERW = 1;

		OPTPMARGR = 8;
		OPTPMARGL = 8;
		OPTPMARGT = -2;
		OPTPMARGB = 8;

		INTMARGL = 8;
		INTMARGT = 8;
		INTMARGB = -4;

		INFMARGL = 8;
		INFMARGT = 8;
		INFMARGB = 0;

		PADDINGT = 8;
		PADDINGB = 2;

		MARGL = 8;
		MARGR = 8;

		MARGTT = 0;
		MARGTB = -10;

		MARGET = 8;
		MARGEB = 8;

		MARGEE = 6;
	end
	
	properties
		newName = 'var';
	end

	properties (Hidden)
		varName;
	end

	methods
		function gv = getvarname(drcn)
			gv@dracon.gui.dialog(drcn);
		end

		function ok = show(gv)
			ok = show@dracon.gui.dialog(gv);
		end
	end

	methods (Hidden)
		function init(rn)
			rn.minW = rn.WIDTH;
			rn.maxW = rn.WIDTH;
			rn.dMaxW = rn.DMAXW;
		end

		function createContent(gv)
			pan = gv.scroll.panel;

			screen = get(groot, 'ScreenSize');

			pan.BorderType = 'etchedin';
			pan.BorderWidth = gv.PANBORDERW;
			gv.dlg.Position(3) = gv.WIDTH;
			gv.dlg.Position(1) = (screen(3) - gv.WIDTH)/2;
			
			bott = gv.OPTPMARGB;
			popW = pan.Position(3) - gv.OPTPMARGL - gv.OPTPMARGR - ...
				   gv.PANBORDERW * 2;
			gv.varName = uicontrol(pan, 'Style', 'edit', ...
										'HorizontalAlign', 'left');
			gv.varName.Position(1:3) = [gv.INFMARGL, bott, popW];

			bott = 1 + gv.INFMARGT + ...
					gv.varName.Position(4) + gv.INTMARGB;

			u = uicontrol(pan, 'Style', 'Text', ...
							   'String', gv.VNAME, ...
							   'HorizontalAlign', 'left');
			u.Position = [gv.INTMARGL, bott, popW, ...
						  ceil(u.Extent(3)/popW) * u.Extent(4)];
			uistack(u, 'bottom');
			bott = bott + u.Position(4) + gv.INTMARGT;

			pan.Position(4) = bott;
			bott = bott + gv.bSpace;

			gv.dlg.Position(2) = screen(4) - gv.MARGT - bott;
			gv.dlg.Position(4) = bott;
		end

		function onOk(gv)
			if(isvarname(gv.varName.String))
				gv.newName = gv.varName.String;
			else
				gv.drcn.error('dracon:invalidVariableName', ...
								gv.ERR_DLG_TITLE, ...
								gv.INVALID_NAME);
				onOk@dracon.gui.dialog(gv, 0);
				return;
			end
			onOk@dracon.gui.dialog(gv);
		end
	end
end
