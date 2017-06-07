function open(drcn)
    % OPEN Allows to select a file to open.
    
    [file, path] = uigetfile(drcn.FILETYPES, 'Select File to Open', ...
							drcn.pref.svpath);
    if(file)
        if(dracon.gui.menu.file.close(drcn))
            drcn.openFile(file, path);
        end
    end
end

