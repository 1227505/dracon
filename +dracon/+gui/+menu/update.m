function update(drcn)
% UPDATE Updates the menu bar. 
% Enables and disables part of the menu,
% to fit the current state of the net.

    if(isempty(drcn.nets))
        drcn.menu.addlay.Enable = 'off';
        drcn.menu.addnod.Enable = 'off';
        drcn.menu.rmnet.Enable = 'off';
        drcn.menu.rmlay.Enable = 'off';
        drcn.menu.rmnod.Enable = 'off';
        drcn.menu.export.Enable = 'off';
    else
        drcn.menu.addlay.Enable = 'on';
        drcn.menu.addnod.Enable = 'on';
        drcn.menu.rmnet.Enable = 'on';
        drcn.menu.rmlay.Enable = 'on';
        drcn.menu.rmnod.Enable = 'on';
        drcn.menu.export.Enable = 'on';
    end
end

