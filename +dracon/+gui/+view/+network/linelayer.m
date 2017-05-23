classdef linelayer < handle
    % LINELAYER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Hidden, Constant, Transient)
        % Line options
        WIDTH  = .5;           % Line width
        COLOR = [0 0 0];       % Line colour
        STYLE  = '-';          % Line style
    end
    
    properties (Hidden)
        lines = gobjects(0);
        net;
        
        layers = dracon.gui.view.network.layer.empty();;
    end
    
    methods
        function l = linelayer(net, layL, layR)
            l.net = net;
            l.layers(1) = layL;
            l.layers(2) = layR;
            
            yr = layR.nodeYC;
            x = [layL.nodeXR, layR.nodeXL];
            y = [layL.nodeYC, yr];
            nr = layR.numNodes;
            for k = 1:layL.numNodes
                for j = 1:nr
                    l.lines((k-1)*nr + j) = ...
                        net.dp.line(x, y, 'LineWidth', l.WIDTH, ...
                                          'LineStyle', l.STYLE, ...
                                          'Color', l.COLOR);
                    y(2) = y(2) + layR.VDIST;
                end
                y(1) = y(1) + layL.VDIST;
                y(2) = yr;
            end
        end
        
        function addNodes(l, lay, nn)
        end
        
        function rmNode(l, lay, nn)
        end
        
        function move(l, dx, dy)
            for k = 1:length(l.lines)
                l.net.dp.lineMove(l.lines(k), dx, dy);
            end
        end
        
        function moveTo(l, x, y)
            l.x = x;
            l.y = y;
            l.move(x - l.x, y - l.y);
        end
        
        function delete(l)
            delete(l.lines);
        end
    end
    
end

