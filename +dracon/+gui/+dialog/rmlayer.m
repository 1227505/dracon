classdef rmlayer < dracon.gui.dialog
%RMLAYER Dialog to remove a layer from a net.
    properties (Constant, Transient, Hidden)
        NAME = 'Delete Layer';
        OKTEXT = 'Delete Layer';
        CANCTEXT = 'Cancel';
        
        TPOS = 'Layer to delete';
        
        INLAYTEXT = 'Input layer';
        LAYSTEXT = 'Layer ';
        DELTEXT = 'Last layers, delete net'
        
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
    end
    
    methods
        function rl = rmlayer(drcn)
            rl@dracon.gui.dialog(drcn);
        end
       
        function ok = show(rl, x, y, lp)
            if(nargin == 4)
                rl.nsPosX.Value = x;
                rl.nsPosY.Value = y;
                rl.pos.Value = lp;
            end
            
            rl.nsUpdate();
            ok = show@dracon.gui.dialog(rl);
        end
    end
    
    methods (Hidden)
        function init(rl)
            rl.minW = rl.WIDTH;
            rl.maxW = rl.WIDTH;
            rl.dMaxW = rl.DMAXW;
        end
        
        function createContent(rl)
            pan = rl.scroll.panel;
            
            screen = get(groot, 'ScreenSize');
            
            pan.BorderType = 'etchedin';
            pan.BorderWidth = rl.PANBORDERW;
            rl.dlg.Position(3) = rl.WIDTH;
            rl.dlg.Position(1) = (screen(3) - rl.WIDTH)/2;
           
            width = pan.Position(3) - rl.MARGL - rl.MARGR - ...
                   rl.PANBORDERW * 2;
               
            bott = rl.PADDINGB + rl.MARGEB;
            
            rl.pos = uicontrol(pan, 'Style', 'popupmenu', ...
                                    'String', 'TEMP');
            rl.pos.Position = [rl.MARGL, bott, width, rl.pos.Extent(4)];
            
            bott = bott + rl.MARGET + rl.pos.Position(4) + rl.MARGTB;
            
            u = uicontrol(pan, 'Style', 'Text', ...
                               'String', rl.TPOS, ...
                               'HorizontalAlign', 'left');
            u.Position = [rl.MARGL, bott, width, ...
                          ceil(u.Extent(3)/width)*u.Extent(4)];
            uistack(u, 'bottom');
            
            bott = bott + rl.MARGTT + u.Position(4);
            
            bott = dracon.gui.util.netselect(rl, @rl.onNetSelect, ...
                                             bott, width);
            
            bott = bott + rl.PADDINGT;
            
            pan.Position(4) = bott;
            bott = bott + rl.bSpace;
            
            rl.dlg.Position(2) = screen(4) - rl.MARGT - bott;
            rl.dlg.Position(4) = bott;
            
            pan.Children(1:3) = pan.Children(3:-1:1);
        end
        
        function onOk(rl)
            rl.drcn.rmLayer(rl.x, rl.y, rl.pos.Value - 1);
            
            onOk@dracon.gui.dialog(rl);
        end
        
        function onNetSelect(rl, x, y)
            rl.net = rl.drcn.nets{x}{y};
            rl.x = x;
            rl.y = y;
            
            if(rl.net.layers < 2)
                rl.pos.String = rl.DELTEXT;
                rl.pos.Value = 1;
                rl.pos.Enable = 'off';
            else
                text = cell(rl.net.layers+1, 1);
                text{1} = rl.INLAYTEXT;
                for i = 1:rl.net.layers
                    text{i+1} = [rl.LAYSTEXT, dec2base(i, 10)];
                end
                rl.pos.String = text;
                rl.pos.Value = min(rl.pos.Value, rl.net.layers+1);
                rl.pos.Enable = 'on';
            end
        end
    end
    
    % Used if only nets with multiple layers should be selectable
    %methods (Static)
    %    function select = selectCond(net)
    %        select = (net.layers > 1);
    %    end
    %end
end
