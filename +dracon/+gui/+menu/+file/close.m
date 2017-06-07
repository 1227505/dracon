function do = close(drcn)
    % CLOSE Closes the current network and opens a new one.
    % If the current network has not been saved, the user may
    % cancel the action.
    % Returns 0 if the users cancels, 1 otherwise.
    
    if(isempty(drcn.fname))
        name = [dracon.DEFAULT_FNAME, dracon.DEFAULT_FTYPE];
    else
        name = drcn.fname;
    end
    
    text = ['Save changes to ''', name, '''?'];
    title = 'Save Network?';
    
    do = 1;
    if(~drcn.isSaved())
        save = questdlg(text, title, 'Yes', 'No', 'Cancel', 'Cancel');
        switch save
            case 'Yes'
                if(~dracon.gui.menu.file.save(drcn))
                    do = 0;
                    return;
                end
                
            case 'Cancel'
                do = 0;
                return;
        end
    end
    
    drcn.reset();
end

