function bott = netselect(sd, cb, bott, width)
% NETSELECT Adds menus to select a network.
% NETSELECT(SD, CB, BOTT, WIDTH) adds menus to the ScrollDialog SD,
% to allow the selection of a network.
% CB will be called, when the selection changes. 
% BOTT is the bottom margin of the lower menu.
% WIDTH is the width of the menus and the text.
% The constants 
%   MARGL
%   MARGR
%   
%   MARGTT
%   MARGTB
%   
%   MARGET
%   MARGEB
%
%   MARGEE
% are expected to be set. See "dracon.gui.dialogs.addlayers"
% for clarification.
% The property 'nsUpdate' of SD will be set to a function handle,
% which should be called in the 'show' function of SD.
% The popupmenus will be saved in the properties 'nsPosX'
% and 'nsPosY' of SD.
% Returns BOTT plus the height of the menus and margins.

    text = 'Select Network';

    pan = sd.scroll.panel;

    bott = bott + sd.MARGEB;
    sd.nsPosY = uicontrol(pan, 'Style', 'popupmenu', 'String', 'temp');
    sd.nsPosY.Position = [sd.MARGL, bott, width, sd.nsPosY.Extent(4)];

    bott = bott + sd.nsPosY.Position(4) + sd.MARGEE;
    
    sd.nsPosX = uicontrol(pan, 'Style', 'popupmenu', 'String', 'temp');
    sd.nsPosX.Position = [sd.MARGL, bott, width, sd.nsPosX.Extent(4)];

    bott = bott + sd.MARGET + sd.nsPosX.Position(4) + sd.MARGTB;

    u = uicontrol(pan, 'Style', 'Text', ...
                       'String', text, ...
                       'HorizontalAlign', 'left');
    u.Position = [sd.MARGL, bott, width, ...
                  ceil(u.Extent(3)/width)*u.Extent(4)];
    uistack(u, 'bottom');
    
    bott = bott + sd.MARGTT + sd.nsPosY.Position(4);
    
    sd.nsUpdate = @()updatePosX(sd);
    sd.nsPosX.Callback = @(~,~)updatePosY(sd);
    sd.nsPosY.Callback = @(~,~)netSelect(sd, cb);
end

function updatePosX(sd)
    posXtext = 'In column ';
    
    num = length(sd.drcn.nets);
    text = cell(num, 1);
    for i = 1:num
        text{i} = [posXtext, dec2base(i, 10)];
    end
    sd.nsPosX.String = text;
    sd.nsPosX.Value = min(sd.nsPosX.Value, num);
    
    if(num > 1)
        sd.nsPosX.Enable = 'on';
    else
        sd.nsPosX.Enable = 'off';
    end
    
    sd.nsPosX.Callback();
end

function updatePosY(sd)
    posYtext = 'Net ';
    shownum = 1;
    showname = 1;
    
    num = length(sd.drcn.nets{sd.nsPosX.Value});
    text = cell(num, 1);
    for i = 1:num
        if(shownum)
            text{i} = [posYtext, dec2base(i, 10)];
        else
            text{i} = '';
        end
        if(showname)
            text{i} = [text{i}, ' (', ...
                       sd.drcn.nets{sd.nsPosX.Value}{i}.name, ')'];
        end
    end
    sd.nsPosY.String = text;
    sd.nsPosY.Value = min(sd.nsPosY.Value, num);
    
    if(num > 1)
        sd.nsPosY.Enable = 'on';
    else
        sd.nsPosY.Enable = 'off';
    end
    
    sd.nsPosY.Callback();
end

function netSelect(sd, cb)
    cb(sd.nsPosX.Value, sd.nsPosY.Value);
end