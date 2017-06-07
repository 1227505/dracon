classdef rmnet < dracon.gui.dialog
%RMNET Dialog to remove a layer from a net.
    properties (Constant, Transient, Hidden)
        NAME = 'Delete Network';
        OKTEXT = 'Delete Net';
        CANCTEXT = 'Cancel';
        
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
        posX = 0;
        posY = 0;
        nsPosX;
        nsPosY;
        nsUpdate;
    end
    
    methods
        function rn = rmnet(drcn)
            rn@dracon.gui.dialog(drcn);
        end
       
        function ok = show(rn, x, y)
            if(nargin == 3)
                rn.nsPosX.Value = x;
                rn.nsPosY.Value = y;
            end
            rn.nsUpdate();
            ok = show@dracon.gui.dialog(rn);
        end
    end
    
    methods (Hidden)
        function init(rn)
            rn.minW = rn.WIDTH;
            rn.maxW = rn.WIDTH;
            rn.dMaxW = rn.DMAXW;
        end
        
        function createContent(rn)
            pan = rn.scroll.panel;
            
            screen = get(groot, 'ScreenSize');
            
            pan.BorderType = 'etchedin';
            pan.BorderWidth = rn.PANBORDERW;
            rn.dlg.Position(3) = rn.WIDTH;
            rn.dlg.Position(1) = (screen(3) - rn.WIDTH)/2;
           
            width = pan.Position(3) - rn.MARGL - rn.MARGR - ...
                   rn.PANBORDERW * 2;
               
            bott = rn.PADDINGT + dracon.gui.util.netselect(rn, @rn.onNetSelect, rn.PADDINGB, width);
            
            pan.Position(4) = bott;
            bott = bott + rn.bSpace;
            
            rn.dlg.Position(2) = screen(4) - rn.MARGT - bott;
            rn.dlg.Position(4) = bott;
            
            pan.Children(1:2) = pan.Children(2:-1:1);
        end
        
        function onOk(rn)
            rn.drcn.rmNet(rn.posX, rn.posY);
            
            onOk@dracon.gui.dialog(rn);
        end
        
        function onNetSelect(rn, posX, posY)
            rn.posX = posX;
            rn.posY = posY;
        end
    end
end
