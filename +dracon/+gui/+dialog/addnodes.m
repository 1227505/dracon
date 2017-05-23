classdef addnodes < dracon.gui.dialog
%ADDNODES Dialog for adding nodes to a layer.
    properties (Constant, Transient, Hidden)
        NAME = 'Add Nodes';
        OKTEXT = 'Add Nodes';
        CANCTEXT = 'Cancel';
        
        ERRDLGTITLE = 'Add Nodes ERROR';
        
        TPOS = 'Position';
        TNUMN = 'Nodes to add';
        
        INLAYTEXT = 'In the input layer';
        LAYSTEXT = 'In layer ';
        
        WIDTH = 187;
        DMAXW = 202;
        MARGT = 120;
        
        PANBORDERW = 1;
        
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
    
    properties (Hidden)
        pos;
        
        x;
        y;
        net = [];
        nsUpdate;
        nsPosX;
        nsPosY;
        
        numN;
    end
    
    methods
        function an = addnodes(drcn)
            an@dracon.gui.dialog(drcn);
        end
       
        function ok = show(an, x, y, lp)
			if(nargin == 4)
				an.nsPosX.Value = x;
				an.nsPosY.Value = y;
				an.pos.Value = lp + 1;
			end
			
            an.nsUpdate();
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
            
            pan.BorderType = 'etchedin';
            pan.BorderWidth = an.PANBORDERW;
            an.dlg.Position(3) = an.WIDTH;
            an.dlg.Position(1) = (screen(3) - an.WIDTH)/2;
           
            width = pan.Position(3) - an.MARGL - an.MARGR - ...
                   an.PANBORDERW * 2;
               
            bott = an.PADDINGB + an.MARGEB;
            
            an.numN = uicontrol(pan, 'Style', 'edit', ...
                                     'String', '1', ...
                                     'HorizontalAlign', 'left');
            an.numN.Position(1:3) = [an.MARGL, bott, width];
            
            bott = bott + an.MARGET + an.numN.Position(4) + an.MARGTB;
            
            u = uicontrol(pan, 'Style', 'Text', ...
                               'String', an.TNUMN, ...
                               'HorizontalAlign', 'left');
            u.Position = [an.MARGL, bott, width, ...
                          ceil(u.Extent(3)/width)*u.Extent(4)];
            uistack(u, 'bottom');
            
            bott = bott + an.MARGTT + u.Position(4) + an.MARGEB;
            
            an.pos = uicontrol(pan, 'Style', 'popupmenu', ...
                                    'String', 'TEMP');
            an.pos.Position = [an.MARGL, bott, width, an.pos.Extent(4)];
            
            bott = bott + an.MARGET + an.pos.Position(4) + an.MARGTB;
            
            u = uicontrol(pan, 'Style', 'Text', ...
                               'String', an.TPOS, ...
                               'HorizontalAlign', 'left');
            u.Position = [an.MARGL, bott, width, ...
                          ceil(u.Extent(3)/width)*u.Extent(4)];
            uistack(u, 'bottom');
            
            bott = bott + an.MARGTT + u.Position(4);
            
            bott = dracon.gui.util.netselect(an, @an.onNetSelect, bott, width);
            
            bott = bott + an.PADDINGT;
            
            pan.Position(4) = bott;
            bott = bott + an.bSpace;
            
            an.dlg.Position(2) = screen(4) - an.MARGT - bott;
            an.dlg.Position(4) = bott;
            
            pan.Children(1:4) = pan.Children(4:-1:1);
        end
        
        function onOk(an)
			an.focusOk();
            try
                nNodes = an.getInput(an.numN, an.TNUMN);
            catch ex
				an.drcn.error('', an.ERRDLGTITLE, ex.message);
                onOk@dracon.gui.dialog(an, 0);
                return;
            end
            
            an.drcn.addNodes(an.x, an.y, an.pos.Value - 1, nNodes);
            
            onOk@dracon.gui.dialog(an);
        end
        
        function onNetSelect(an, posX, posY)
            an.net = an.drcn.nets{posX}{posY};
            an.x = posX;
            an.y = posY;
            
            text = cell(an.net.layers+1, 1);
            text{1} = an.INLAYTEXT;
            for i = 1:an.net.layers
                text{i+1} = [an.LAYSTEXT, dec2base(i, 10)];
            end
            an.pos.String = text;
            an.pos.Value = min(an.pos.Value, an.net.layers+1);
        end
    end
    
    methods (Hidden, Static)
        function num = getInput(field, name)
            num = str2num(field.String); %#ok<ST2NM>
            if(isempty(num))
                throw(MException('dracon:inputNaN',...
                    'Input for ''%s'' must be a number or a calculation.', name));
            end
            if(mod(num,1))
                throw(MException('dracon:inputReal',...
                    'Input for ''%s'' must be an integer.', name));
            end
            if(num <= 0)
                throw(MException('dracon:inputNegative',...
                    'Input for ''%s'' must be positive.', name));
            end
        end
    end
end
