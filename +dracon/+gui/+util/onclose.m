function onclose(drcn)
    % Executes when user attempts to close dracon.
    
    if(dracon.gui.menu.file.close(drcn))
        views = fieldnames(drcn.view);
        for i = 1:length(views)
            drcn.pref.view.(views{i}).pos = ...
				drcn.view.(views{i}).fig.OuterPosition;
            drcn.pref.view.(views{i}).show = ...
				drcn.view.(views{i}).fig.Visible;
            delete(drcn.view.(views{i}).fig);
        end
        
        eval([drcn.SAVE_VNAME, '= drcn.pref;']);
        save([drcn.dpath, drcn.PREF_FNAME], drcn.SAVE_VNAME);
        
        delete(drcn);
    end
end