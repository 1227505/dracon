function bott = condnetselect(sd, cb, bott, width, cond)
% CONDNETSELECT Adds menus to select a network.
% CONDNETSELECT(drcn, sd, bott, width, cond) adds menus to the ScrollDialog sd,
% to allow the selection of a network for which cond holds true.
% cb(posX, posY) will be called, when the selection changes. 
% bott is the bottom margin of the lower menu.
% width is the width of the menus and the text.
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
% The property 'nsUpdate' of sd will be set to a function handle,
% which should be called without arguments in the 'show' function of sd.
% cond must take one argument of type 'dracon.nn' and
% must have a single return value.
% Returns bott plus the height of the menus and margins.

    text = 'Select Network';

    pan = sd.scroll.panel;

    bott = bott + sd.MARGEB;
    posY = uicontrol(pan, 'Style', 'popupmenu', 'String', 'temp');
    posY.Position = [sd.MARGL, bott, width, posY.Extent(4)];

    bott = bott + posY.Position(4) + sd.MARGEE;
    
    posX = uicontrol(pan, 'Style', 'popupmenu', 'String', 'temp');
    posX.Position = [sd.MARGL, bott, width, posX.Extent(4)];

    bott = bott + sd.MARGET + posX.Position(4) + sd.MARGTB;

    u = uicontrol(pan, 'Style', 'Text', ...
                       'String', text, ...
                       'HorizontalAlign', 'left');
    u.Position = [sd.MARGL, bott, width, ...
                  ceil(u.Extent(3)/width)*u.Extent(4)];
    uistack(u, 'bottom');
    
    bott = bott + sd.MARGTT + posY.Position(4);
    
    sd.nsUpdate = @()updatePosX(sd,posX,cond);
    posX.Callback = @(~,~)updatePosY(posX,posY);
    posY.Callback = @(~,~)netSelect(cb,posX,posY);
end

function updatePosX(sd, posX, cond)
    posXtext = 'In column ';
    posYtext = 'Net ';
    shownum = 1;
    showname = 1;
    
    %#ok<*UNRCH>
    %#ok<*AGROW>
    
    num = length(sd.drcn.nets);
    xtext = {}; 
    posX.UserData = {};
    for x = 1:num
        ytext = {};
        for y = 1:length(sd.drcn.nets{x})
            if(cond(sd.drcn.nets{x}{y}))
                if(shownum)
                    text = [posYtext, dec2base(y, 10)];
                else
                    text = '';
                end
                if(showname)
                    text = [text, ' (', sd.drcn.nets{x}{y}.name, ')'];
                end
                ytext = [ytext, {text}];
            end
        end
        if(~isempty(ytext))
            xtext = [xtext, {[posXtext, dec2base(x, 10)]}];
            posX.UserData = [posX.UserData, {ytext}];
        end
    end
    posX.String = xtext;
    num = size(xtext, 2);
    posX.Value = min(posX.Value, num);
    
    if(num > 1)
        posX.Enable = 'on';
    else
        posX.Enable = 'off';
    end
    
    posX.Callback();
end

function updatePosY(posX, posY)
    posY.String = posX.UserData{posX.Value};
    num = size(posY.String, 1);
    posY.Value = min(posY.Value, num);
    
    if(num > 1)
        posY.Enable = 'on';
    else
        posY.Enable = 'off';
    end
    
    posY.Callback();
end

function netSelect(cb, posX, posY)
    cb(posX.Value, posY.Value);
end
