classdef MNIST < dracon.input
	%IDX Summary of this class goes here
	%   Detailed explanation goes here
	
	properties (Hidden, Constant, Transient)
		INIT = { ...
			... % Source File
			{'Source File', 'F', ...
			{'*.idx3-ubyte; *.idx1-ubyte', 'MNIST'}}, ...
			... % Mode
			{'Mode', ...
			{'Image, 0 - 1', 'Image, 0 - 255', ...
			'Label, decimal', 'Label, position vector', 'Label, binary';...
			... % Tooltips for the popupmenu
			['<html>Size and width are read from the file. ', ...
			'Each image will ', ...
			'be represented as a column vector of length height * ', ...
			'width and with values from 0 to 1.<br>', ...
			'Colours are inverted for the display, ', ...
			'small images are magnified.</html>'], ...
			['<html>Size and width are read from the file. ', ...
			'Each image will ', ...
			'be represented as a column vector of length height * ', ...
			'width and with values from 0 to 255.<br>', ...
			'Colours are inverted for the display, ', ...
			'small images are magnified.</html>'], ...
			'Each label is represented as a decimal scalar.', ...
			['Each label is represented as a column vector with 10 ', ...
			'entries and a 1 at the appropriate position. E.g. 5 ', ...
			'would be [0 0 0 0 0 1 0 0 0 0]''.'], ...
			['Each label is represented as a binary value in a column', ...
			'vector with 4 entries. E.g. 5 would be [1 0 1 0]''.']}, ...
			... % Tooltip for the text
			'Choose how the MNIST file should be interpreted.'}};
		
		NAME = 'MNIST (IDX)';
		DESC = ['Open file of the IDX format, ' ...
				'used in the MNIST handwritten digit database.'];
			
		MIN_SIZE	= 140;
		
		IMG_MAGIC	= 2051;
		LAB_MAGIC	= 2049;
	end
	
	properties (Hidden)
		mode;		% 1: image, 0 - 1
					% 2: image, 0 - 255
					% 3: label, decimal
					% 4: label, position vector (10)
					% 5: label, binary
					
		dispData;
		imH = 0;
		imW = 0;
	end
	
	methods
		function m = MNIST(path, mode)
			if(iscell(path))
				path = path{1};
			end
			m.mode = mode;
			[~, source, ~] = fileparts(path);
			
			f = fopen(path,'rb');
			type = fread(f, 1, 'int32', 'b');
			if(mode < 3)
				if(type ~= m.IMG_MAGIC)
					throw(MException('dracon:invalidMagic',...
						'Expected magic number to be %d.', ...
						m.IMG_MAGIC));
				end
				fread(f, 1, 'int32', 'b');
				m.imH = fread(f, 1, 'int32', 'b');
				m.imW = fread(f, 1, 'int32', 'b');
				m.data = fread(f, 'uchar', 'b');
				m.data = permute(reshape(m.data, m.imH, m.imW, []), ...
					[2,1,3]);
				m.dispData = 255 - m.data;
				if(mode == 1)
					m.source = ['MNIST (Image 0-1): ', source];
					m.data = m.data / 255;
				else
					m.source = ['MNIST (Image 0-255): ', source];
				end
				m.data = reshape(m.data, m.imH * m.imW, []);
			else
				if(type ~= m.LAB_MAGIC)
					throw(MException('dracon:invalidMagic',...
						'Expected magic number to be %d.', ...
						m.LAB_MAGIC));
				end
				fread(f,1,'int32',0,'b');
				m.data = fread(f,'uchar','b').';
				m.dispData = m.data;
				if(m.mode == 4)
					m.source = ['MNIST (Label position vector): ', source];
					ndata = zeros(10, length(m.data));
					for k = 1:10
						ndata(k, m.data == k-1) = 1;
					end
					m.data = ndata;
				elseif(mode == 5)
					m.source = ['MNIST (Label binary): ', source];
					m.data = flip((dec2bin(m.data, 4)-48).');
				else
					m.source = ['MNIST (Label decimal): ', source];
				end
			end
			fclose(f);
			
			m.dataSize = size(m.data, 1);
			m.dataNum = size(m.data, 2);
			
			m.text = cell(m.dataNum, 1);
			if(m.mode < 3)
				for k=1:m.dataNum
					m.text{k} = ...
						sprintf('%d (%s) | Image %d x %d x 1', ...
						k, source, m.imW, m.imH);
				end
			elseif(m.mode == 3)
				for k=1:m.dataNum
					m.text{k} = sprintf('%d (%s) | %d',...
								k, source, m.dispData(k));
				end
			else
				v = num2str(m.data.');
				for k=1:m.dataNum
					m.text{k} = sprintf('%d (%s) | %s (%d)',...
								k, source, v(k, :), m.dispData(k));
				end
			end
		end
		
		function select(m, pan, which)
			if(m.mode < 3)
				mul = 1;
				ma = max(m.imW, m.imH);
				if(ma < m.MIN_SIZE)
					mul = m.MIN_SIZE / ma;
				end
				pan.Position(3) = m.imW * mul;
				pan.Position(4) = m.imH * mul;
				a = axes('Parent', pan, ...
						'XColor','none', ...
						'YColor','none', ...
						'Units', 'normal', ...
						'YDir','reverse', ...
						'Position', [0 0 1 1]);
				colormap(a, 'gray');
				image('CData', m.dispData(:,:,which), 'Parent', a);
			end
		end
		
		function deselect(~, pan, ~)
			delete(pan.Children);
		end
	end
end

