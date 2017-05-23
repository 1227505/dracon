classdef rmnode < dracon.gui.dialog
%RMNODE Dialog to remove a node from a layer.
    properties (Constant, Transient, Hidden)
        NAME = 'Delete Node';
        OKTEXT = 'Delete Node';
        CANCTEXT = 'Cancel';
        
        TPOSX = 'Layer';
        PPOSX_FIRST = 'Input layer';
        PPOSX = 'Layer ';
        
        TPOSY = 'Node';
        PPOSY = 'Node ';
        PPOSY_DELETE_LAY = 'Last node, delete layer';
        PPOSY_DELETE_NET = 'Last node & layers, delete net';
        
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
        posX;
        posY;
        nsPosX;
        nsPosY;
        x;
        y;
        net = [];
        nsUpdate;
    end
    
    methods
        function rn = rmnode(drcn)
            rn@dracon.gui.dialog(drcn);
        end
       
        function ok = show(rn, x, y, lp, np)
            if(nargin == 5)
                rn.nsPosX.Value = x;
                rn.nsPosY.Value = y;
                rn.posX.Value = lp + 1;
                rn.posY.Value = np;
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
               
            bott = rn.PADDINGB + rn.MARGEB;
            
            rn.posY = uicontrol(pan, 'Style', 'popupmenu', ...
                                     'String', 'TEMP');
            rn.posY.Position(1:3) = [rn.MARGL, bott, width];
            
            bott = bott + rn.MARGET + rn.posY.Position(4) + rn.MARGTB;
            
            u = uicontrol(pan, 'Style', 'Text', ...
                               'String', rn.TPOSY, ...
                               'HorizontalAlign', 'left');
            u.Position = [rn.MARGL, bott, width, ...
                          ceil(u.Extent(3)/width)*u.Extent(4)];
            uistack(u, 'bottom');
            
            bott = bott + rn.MARGTT + u.Position(4) + rn.MARGEB;
            
            rn.posX = uicontrol(pan, 'Style', 'popupmenu', ...
                                     'String', 'TEMP', ...
                                     'call', @(~,~)rn.onLayerSelect());
            rn.posX.Position = [rn.MARGL, bott, width, rn.posX.Extent(4)];
            
            bott = bott + rn.MARGET + rn.posX.Position(4) + rn.MARGTB;
            
            u = uicontrol(pan, 'Style', 'Text', ...
                               'String', rn.TPOSX, ...
                               'HorizontalAlign', 'left');
            u.Position = [rn.MARGL, bott, width, ...
                          ceil(u.Extent(3)/width)*u.Extent(4)];
            uistack(u, 'bottom');
            
            bott = bott + rn.MARGTT + u.Position(4);
            
            bott = dracon.gui.util.netselect(rn, @rn.onNetSelect, ...
                                             bott, width);
            
            bott = bott + rn.PADDINGT;
            
            pan.Position(4) = bott;
            bott = bott + rn.bSpace;
            
            rn.dlg.Position(2) = screen(4) - rn.MARGT - bott;
            rn.dlg.Position(4) = bott;
            
            pan.Children(1:4) = pan.Children(4:-1:1);
        end
        
        function onOk(rn)            
            rn.drcn.rmNode(rn.x, rn.y, rn.posX.Value - 1, rn.posY.Value);
            
            onOk@dracon.gui.dialog(rn);
        end
        
        function onNetSelect(rn, x, y)
            rn.net = rn.drcn.nets{x}{y};
            rn.x = x;
            rn.y = y;
            
            text = cell(rn.net.layers+1, 1);
            text{1} = rn.PPOSX_FIRST;
            for i = 1:rn.net.layers
                text{i+1} = [rn.PPOSX, dec2base(i, 10)];
            end
            rn.posX.String = text;
            rn.posX.Value = min(rn.posX.Value, rn.net.layers+1);
            
            rn.posX.Callback();
        end
        
        function onLayerSelect(rn)            
            num = rn.drcn.getLayerHeight(rn.net, rn.posX.Value-1);
            if(num == 1)
                if(rn.net.layers < 2)
                    rn.posY.String = rn.PPOSY_DELETE_NET;
                else
                    rn.posY.String = rn.PPOSY_DELETE_LAY;
                end
                rn.posY.Enable = 'off';
                rn.posY.Value = 1;
            else
                text = cell(num, 1);
                for i = 1:num
                    text{i} = [rn.PPOSY, dec2base(i, 10)];
                end
                rn.posY.Enable = 'on';
                rn.posY.String = text;
                rn.posY.Value = min(rn.posY.Value, num);
            end
        end
    end
    
    % Used if only nets with multiple nodes per layer should be selectable.
    %methods (Static)
    %    function select = selectCond(net)
    %        select = (net.layers > 1 || net.in > 1 || net.out > 1);
    %    end
    %end
end
