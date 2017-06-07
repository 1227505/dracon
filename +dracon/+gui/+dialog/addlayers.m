classdef addlayers < dracon.gui.dialog
%ADDLAYERS Dialog for addings layers to a net.
    properties (Constant, Transient, Hidden)
        NAME = 'Add Layers';
        OKTEXT = 'Add Layers';
        CANCTEXT = 'Cancel';
        
        ERRDLGTITLE = 'Add Layers ERROR';
        
        TPOS = 'Position';
        TNUML = 'Number of Layers';
        TNUMN = 'Nodes per Layer';
        
        INLAYTEXT = 'After the input layer';
        LAYSTEXT = 'After layer ';
        
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
        
        numL;
        numN;
    end
    
    methods
        function al = addlayers(drcn)
            al@dracon.gui.dialog(drcn);
        end
       
        function ok = show(al, x, y, lp)
			if(nargin == 4)
				al.nsPosX.Value = x;
				al.nsPosY.Value = y;
				al.pos.Value = lp + 1;
			end
			
            al.nsUpdate();
            ok = show@dracon.gui.dialog(al);
        end
    end
    
    methods (Hidden)
        function init(al)
            al.minW = al.WIDTH;
            al.maxW = al.WIDTH;
            al.dMaxW = al.DMAXW;
        end
        
        function createContent(al)
            pan = al.scroll.panel;
            
            screen = get(groot, 'ScreenSize');
            
            pan.BorderType = 'etchedin';
            pan.BorderWidth = al.PANBORDERW;
            al.dlg.Position(3) = al.WIDTH;
            al.dlg.Position(1) = (screen(3) - al.WIDTH)/2;
           
            width = pan.Position(3) - al.MARGL - al.MARGR - ...
                   al.PANBORDERW * 2;
               
            bott = al.PADDINGB + al.MARGEB;
            
            al.numN = uicontrol(pan, 'Style', 'edit', ...
                                     'String', '1', ...
                                     'HorizontalAlign', 'left');
            al.numN.Position(1:3) = [al.MARGL, bott, width];
            
            bott = bott + al.MARGET + al.numN.Position(4) + al.MARGTB;
            
            u = uicontrol(pan, 'Style', 'Text', ...
                               'String', al.TNUMN, ...
                               'HorizontalAlign', 'left');
            u.Position = [al.MARGL, bott, width, ...
                          ceil(u.Extent(3)/width)*u.Extent(4)];
            uistack(u, 'bottom');
            
            bott = bott + al.MARGTT + u.Position(4) + al.MARGEB;
            
            al.numL = uicontrol(pan, 'Style', 'edit', ...
                                     'String', '1', ...
                                     'HorizontalAlign', 'left');
            al.numL.Position(1:3) = [al.MARGL, bott, width];
            
            bott = bott + al.MARGET + al.numL.Position(4) + al.MARGTB;
            
            u = uicontrol(pan, 'Style', 'Text', ...
                               'String', al.TNUML, ...
                               'HorizontalAlign', 'left');
            u.Position = [al.MARGL, bott, width, ...
                          ceil(u.Extent(3)/width)*u.Extent(4)];
            uistack(u, 'bottom');
            
            bott = bott + al.MARGTT + u.Position(4) + al.MARGEB;
            
            al.pos = uicontrol(pan, 'Style', 'popupmenu', ...
                                    'String', 'TEMP');
            al.pos.Position = [al.MARGL, bott, width, al.pos.Extent(4)];
            
            bott = bott + al.MARGET + al.pos.Position(4) + al.MARGTB;
            
            u = uicontrol(pan, 'Style', 'Text', ...
                               'String', al.TPOS, ...
                               'HorizontalAlign', 'left');
            u.Position = [al.MARGL, bott, width, ...
                          ceil(u.Extent(3)/width)*u.Extent(4)];
            uistack(u, 'bottom');
            
            bott = bott + al.MARGTT + u.Position(4);
            
            bott = dracon.gui.util.netselect(al, @al.onNetSelect, ...
                bott, width);
            
            bott = bott + al.PADDINGT;
            
            pan.Position(4) = bott;
            bott = bott + al.bSpace;
            
            al.dlg.Position(2) = screen(4) - al.MARGT - bott;
            al.dlg.Position(4) = bott;
            
            pan.Children(1:5) = pan.Children(5:-1:1);
        end
        
        function onOk(al)
			al.focusOk();
            try
                nLays = al.getInput(al.numL, al.TNUML);
                nNodes = al.getInput(al.numN, al.TNUMN);
            catch ex
				an.drcn.error('', an.ERRDLGTITLE, ex.message);
                onOk@dracon.gui.dialog(al, 0);
                return;
            end
            al.drcn.addLayers(al.x, al.y, al.pos.Value, nLays, nNodes);
            
            onOk@dracon.gui.dialog(al);
        end
        
        function onNetSelect(al, posX, posY)
            al.net = al.drcn.nets{posX}{posY};
            al.x = posX;
            al.y = posY;
            
            text = cell(al.net.layers+1, 1);
            text{1} = al.INLAYTEXT;
            for i = 1:al.net.layers
                text{i+1} = [al.LAYSTEXT, dec2base(i, 10)];
            end
            al.pos.String = text;
            al.pos.Value = min(al.pos.Value, al.net.layers+1);
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
