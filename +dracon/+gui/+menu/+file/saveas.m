function saved = saveas(drcn)
    % SAVEAS Allows to select a new savepath and calls save.
    
    if(isempty(drcn.fname))
        tname = dracon.DEFAULT_FNAME;
        type = dracon.DEFAULT_FTYPE;
    else
        [~, tname, type] = fileparts(drcn.fname);
    end
    
    i = 1;
    name = tname;
    while(exist([drcn.pref.svpath, name, type], 'file'))
        i = i + 1;
        name = [tname, ' ', dec2base(i,10)];
    end
            
    [file, path] = uiputfile(drcn.FILETYPES, 'Select File to Open', ...
							[drcn.pref.svpath, name]);
    if(file)
        drcn.fname = file;
        drcn.pref.svpath = path;
        dracon.gui.menu.file.save(drcn);
        saved = 1;
    else
        saved = 0;
    end
end

