function export(drcn)
    % EXPORT Saves the network as a MATLAB code file.
    % The current network is saved as MATLAB code file, that can be run
	% independently from this toolbox.
    
	try
		drcn.export();
	catch ex
		drcn.error(ex.identifier, 'Export ERROR', ex.message);
	end
end

