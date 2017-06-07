classdef netdata < event.EventData
	properties
		netX;           % Net position x
		netY;           % Net position y
		layPos;         % Layer position
		nodePos;        % Node position or number of nodes (in ADDLAYERS)
		num;            % Number of nodes or layers
						% Also set -1 to indicate the last net in a column
		net;            % Referenced net in addNet and rmNet

		type;           % What happened
	end

	properties (Constant, Transient)
		ADDNET      = 1;
		ADDLAYERS   = 2;
		ADDNODES    = 3;

		RMNET       = -1;
		RMLAYER     = -2;
		RMNODE      = -3;
		
		MVNET		= 0;
		MVLAYERS	= 4;
		MVNODES		= 5;
		
		CHVALUES	= 6;
	end

	methods
		function nd = netdata(type, netX, netY, layPos, nodePos, num, net)
			nd.type = type;
			if(nargin > 1)
				nd.netX = netX;
				if(nargin > 2)
					nd.netY = netY;
					if(nargin > 3)
						nd.layPos = layPos;
						if(nargin > 4)
							nd.nodePos = nodePos;
							if(nargin > 5)
								nd.num = num;
								if(nargin > 6)
									nd.net = net;
								end
							end
						end
					end
				end
			end
		end

		function n = copy(nd)
			k = length(nd);
			n = nd.empty(0, k);
			for k = 1:k
				n(k) = dracon.util.netdata(nd(k).type, nd(k).netX, ...
										   nd(k).netY, nd(k).layPos, ...
										   nd(k).nodePos, nd(k).num, ...
										   nd(k).net);
			end
		end

		function invertType(nd)
			if(nd.type < 4)
				nd.type = -nd.type;
			end
		end
	end
end

