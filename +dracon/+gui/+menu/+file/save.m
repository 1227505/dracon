function saved = save(drcn)
    % SAVE Saves the current network(s).
    % If no savepath is known, saveas is called.
    
    if(isempty(drcn.fname))
        saved = dracon.gui.menu.file.saveas(drcn);
    else
        eval([drcn.SAVE_VNAME, '= drcn.nets;']);
        save([drcn.pref.svpath, drcn.fname], drcn.SAVE_VNAME);
        
        drcn.setSaved(1);
        saved = 1;
    end
end

