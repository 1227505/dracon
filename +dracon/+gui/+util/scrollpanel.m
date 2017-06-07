classdef scrollpanel < handle
    %SCROLLPANEL Scrollable panel.
    
    properties (Constant, Transient)
        SLIDERWIDTH = 16;             % In pixel
        XSTEPSIZE   = 8;
        YSTEPSIZE   = 13;
    end
    
    properties
        window;
        panel;
        xSlider;
        ySlider;
        
        % 1 to stick, -1 to stick to the other side, 0 to center.
        stickLeft = 1;
        stickUp = -1;
    end
    
    methods
        function sc = scrollpanel(varargin)
            sc.window = uipanel(varargin{:}, 'BorderType', 'none');
            sc.panel = uipanel(sc.window, 'BorderType', 'none', ...
                                          'Units', 'pixels');
            sc.xSlider = uicontrol(sc.window, 'Style', 'slider', ...
                                              'Visible', 'off', ...
                                              'Callback', @(sl,~)sc.slideX(sl.Value));
            sc.xSlider.Position(1) = 1;
            sc.xSlider.Position(2) = 1;
            sc.ySlider = uicontrol(sc.window, 'Style', 'slider', ...
                                              'Visible', 'off', ...
                                              'Value', 0, ...
                                              'Callback', @(sl,~)sc.slideY(sl.Value));
            sc.ySlider.Position(2) = 1;
            sc.setSliderWidth(sc.SLIDERWIDTH);
            sc.updateOnResize(1);
        end
        
        function updateOnResize(sc, yes)
            if(yes)
                sc.window.SizeChangedFcn = @(~,~)sc.onResize();
                sc.panel.SizeChangedFcn = @(~,~)sc.onResize();
                sc.onResize();
            else
                sc.window.SizeChangedFcn = '';
                sc.panel.SizeChangedFcn = '';
            end
        end
        
        function setSliderWidth(sc, val)
            sc.xSlider.Position(4) = val;
            sc.ySlider.Position(3) = val;
            sc.onResize();
        end
        
        function setPosX(sc, pos)
            sc.xSlider.Value = pos;
            sc.slideX(pos);
        end
        
        function setPosY(sc, pos)
            sc.ySlider.Value = pos;
            sc.slideY(pos);
        end
        
        function moveX(sc, steps)
            sc.setPosX(max(min(sc.xSlider.SliderStep(1)*steps+sc.xSlider.Value,1),0));
        end
        
        function moveY(sc, steps)
            sc.setPosY(max(min(sc.ySlider.SliderStep(1)*steps+sc.ySlider.Value,1),0));
        end
    end
    
    methods (Hidden)
        function onResize(sc)
            winUnits = sc.window.Units;
            sc.window.Units = 'pixels';
            
            winX = sc.window.Position(3);
            winY = sc.window.Position(4);
            panX = sc.panel.Position(3);
            panY = sc.panel.Position(4);
            xsW = sc.xSlider.Position(4);
            ysW = sc.ySlider.Position(3);
            
            if(winY < panY || ...
                (winY-xsW < panY && winX < panX))
                winX = winX - ysW;
                sc.ySlider.Position([1,4]) = [winX+1 winY+1];
                if(winX < panX)
                    stepMin = min(sc.YSTEPSIZE/(panY-winY+xsW),1);
                    stepMax = min((winY-xsW)/(panY-winY+xsW),1);
                else
                    stepMin = min(sc.YSTEPSIZE/(panY-winY),1);
                    stepMax = min(winY/(panY-winY),1);
                end
                sc.ySlider.SliderStep = [stepMin, max(stepMin,stepMax)];
                if(strcmp(sc.ySlider.Visible,'off'))
                    if(sc.stickUp == 1)
                        sc.ySlider.Value = 1;
                    elseif(sc.stickUp == -1)
                        sc.ySlider.Value = 0;
					else
						sc.ySlider.Value = 0.5;
                    end
                    sc.ySlider.Visible = 'on';
                end
                if(sc.stickUp == 1)
                    sc.panel.Position(2) = winY-panY+1;
				elseif(sc.stickUp ~= -1)
					if(strcmp(sc.xSlider.Visible,'on'))
						sc.panel.Position(2) = (winY-panY+1 - ...
											sc.xSlider.Position(4))/2;
					else
						sc.panel.Position(2) = (winY-panY+1)/2;
					end
                end
            elseif(strcmp(sc.ySlider.Visible,'on'))
                sc.panel.Position(2) = winY-panY+1;
                sc.ySlider.Visible = 'off';
            elseif(sc.stickUp == 1)
                sc.panel.Position(2) = winY-panY+1;
            elseif(sc.stickUp == -1)
                if(strcmp(sc.xSlider.Visible,'on'))
                    sc.panel.Position(2) = sc.xSlider.Position(4) + 1;
                else
                    sc.panel.Position(2) = 1;
				end
			else
                if(strcmp(sc.xSlider.Visible,'on'))
                    sc.panel.Position(2) = (winY-panY+1 - ...
										sc.xSlider.Position(4))/2;
                else
                    sc.panel.Position(2) = (winY-panY+1)/2;
				end
            end
            
            if(winX < panX)
                winY = winY - xsW;
                sc.xSlider.Position(3) = winX;
                stepMin = min(sc.XSTEPSIZE/(panX-winX),1);
                stepMax = min(winY/(panX-winX),1);
                sc.xSlider.SliderStep = [stepMin, max(stepMin,stepMax)];
                if(strcmp(sc.xSlider.Visible,'off'))
                    if(sc.stickLeft == 1)
                        sc.xSlider.Value = 0;
                    elseif(sc.stickLeft == -1)
                        sc.xSlider.Value = 1;
					else
                        sc.xSlider.Value = 0.5;
                    end
                    sc.xSlider.Visible = 'on';
                end
            elseif(strcmp(sc.xSlider.Visible,'on'))
                sc.panel.Position(1) = 1;
                sc.xSlider.Visible = 'off';
            elseif(sc.stickLeft == -1)
                if(strcmp(sc.xSlider.Visible,'on'))
                    sc.panel.Position(1) = winX - panX - ...
										sc.ySlider.Position(3) + 1;
                else
                    sc.panel.Position(1) = winX - panX + 1;
                end
            elseif(sc.stickLeft == 1)
                sc.panel.Position(1) = 1;
			else
                if(strcmp(sc.xSlider.Visible,'on'))
                    sc.panel.Position(1) = (winX - panX - ...
										sc.ySlider.Position(3) + 1)/2;
                else
                    sc.panel.Position(1) = (winX - panX + 1)/2;
                end
            end

            
            sc.slideX(sc.xSlider.Value);
            sc.slideY(sc.ySlider.Value);
            
            sc.window.Units = winUnits;
        end
        
        function slideX(sc, val)
            winUnits = sc.window.Units;
            sc.window.Units = 'pixels';

            pos = sc.window.Position(3) - sc.panel.Position(3);
            if(strcmp(sc.ySlider.Visible,'on'))
                pos = pos - sc.ySlider.Position(3);
            end
            if(pos <= 0)
                sc.panel.Position(1) = val*pos + 1;
            end

            sc.window.Units = winUnits;
        end
        
        function slideY(sc, val)
            winUnits = sc.window.Units;
            sc.window.Units = 'pixels';

            pos = sc.window.Position(4) - sc.panel.Position(4);
            if(strcmp(sc.xSlider.Visible,'on'))
                sl = sc.xSlider.Position(4);
            else
                sl = 0;
            end
            if(pos <= 0)
                sc.panel.Position(2) = val*(pos-sl) + sl + 1;
            end

            sc.window.Units = winUnits;
        end
        
        function onScroll(sc, ev, modif)
            slx = strcmp(sc.xSlider.Visible, 'on');
            sly = strcmp(sc.ySlider.Visible, 'on');
            if(slx && ~sly)
                sc.moveX(ev.VerticalScrollCount * ...
					ev.VerticalScrollAmount);
            elseif(~slx && sly)
                sc.moveY(-ev.VerticalScrollCount * ...
					ev.VerticalScrollAmount);
            elseif(slx && sly)
                if(ismember('shift', modif))
                    sc.moveX(ev.VerticalScrollCount * ...
						ev.VerticalScrollAmount);
                else
                    sc.moveY(-ev.VerticalScrollCount * ...
						ev.VerticalScrollAmount);
                end
            end 
        end
        
        function onKey(sc, ev)
            if(strcmp(sc.xSlider.Visible,'on'))
                if(strcmp(ev.Key,'leftarrow'))
                    sc.moveX(-1);
                elseif(strcmp(ev.Key,'rightarrow'))
                    sc.moveX(1);
                end
            end
            if(strcmp(sc.ySlider.Visible,'on'))
                if(strcmp(ev.Key,'downarrow'))
                    sc.moveY(-1);
                elseif(strcmp(ev.Key,'uparrow'))
                    sc.moveY(1);
                end
            end 
        end
    end
end

