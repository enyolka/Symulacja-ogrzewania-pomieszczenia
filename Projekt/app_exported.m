classdef app_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                       matlab.ui.Figure
        Menu                           matlab.ui.container.Menu
        TempAxes                       matlab.ui.control.UIAxes
        CostAxes                       matlab.ui.control.UIAxes
        PowerAxes                      matlab.ui.control.UIAxes
        PropertiesPanel                matlab.ui.container.Panel
        RoomLabel                      matlab.ui.control.Label
        WindowsLabel                   matlab.ui.control.Label
        lengthEditFieldLabel           matlab.ui.control.Label
        RoomLength                     matlab.ui.control.NumericEditField
        WallCheckBox                   matlab.ui.control.CheckBox
        widthEditFieldLabel            matlab.ui.control.Label
        RoomWidth                      matlab.ui.control.NumericEditField
        lengthEditField_2Label         matlab.ui.control.Label
        WallLength                     matlab.ui.control.NumericEditField
        widthEditField_2Label          matlab.ui.control.Label
        WallWidth                      matlab.ui.control.NumericEditField
        NumberofwindowsSpinnerLabel    matlab.ui.control.Label
        WindowsNum                     matlab.ui.control.Spinner
        heightEditField_2Label         matlab.ui.control.Label
        WindowsHeight                  matlab.ui.control.NumericEditField
        heightEditFieldLabel           matlab.ui.control.Label
        RoomHeight                     matlab.ui.control.NumericEditField
        widthEditField_3Label          matlab.ui.control.Label
        WindowsWidth                   matlab.ui.control.NumericEditField
        WallmaterialDropDownLabel      matlab.ui.control.Label
        WallMaterial                   matlab.ui.control.DropDown
        InsulationDropDownLabel        matlab.ui.control.Label
        Insulation                     matlab.ui.control.DropDown
        RoomAboveCheckBox              matlab.ui.control.CheckBox
        FloorSpinnerLabel              matlab.ui.control.Label
        Floor                          matlab.ui.control.Spinner
        StartButton                    matlab.ui.control.Button
        OutdoortemperatureSliderLabel  matlab.ui.control.Label
        OutdoorTempSlider              matlab.ui.control.Slider
        PlotsPanel                     matlab.ui.container.Panel
        ShowplotLabel                  matlab.ui.control.Label
        TempCheckBox                   matlab.ui.control.CheckBox
        CostsCheckBox                  matlab.ui.control.CheckBox
        PowerCheckBox                  matlab.ui.control.CheckBox
        TimePanel                      matlab.ui.container.Panel
        fromEditFieldLabel             matlab.ui.control.Label
        LowerFrom                      matlab.ui.control.NumericEditField
        LowerLabel                     matlab.ui.control.Label
        toEditFieldLabel               matlab.ui.control.Label
        LowerTo                        matlab.ui.control.NumericEditField
        EverydayCheckBox               matlab.ui.control.CheckBox
        DurationSliderLabel            matlab.ui.control.Label
        DurationSlider                 matlab.ui.control.Slider
        LowerLabel_2                   matlab.ui.control.Label
        LowerTempSlider                matlab.ui.control.Slider
        RoomTempSlider                 matlab.ui.control.Slider
    end

    
    methods (Access = private)
        
        
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.TempAxes.Visible = 'off';
            app.CostAxes.Visible = 'off';
            app.PowerAxes.Visible = 'off';

        end

        % Button pushed function: StartButton
        function StartButtonPushed(app, event)
            
            % Set temperature
            
            if(app.EverydayCheckBox.Value == 1)
                assignin('base','modulo',24);
            else 
                assignin('base','modulo',app.DurationSlider.Value);
            end
            
            assignin('base','set_room',app.RoomTempSlider.Value);
            assignin('base', 'set_lower', app.LowerTempSlider.Value);
            
            assignin('base', 'lower_from', app.LowerFrom.Value);
            assignin('base', 'lower_to', app.LowerTo.Value);
            
            
            % Room dimensions
            
            %length [m]
            length = app.RoomLength.Value;
            %width [m]
            width = app.RoomWidth.Value;
            %height [m]
            height = app.RoomHeight.Value;
            % radians to degrees
            %r2d = 180/pi;
            %roof pitch
            %roof_pitch = 40/r2d; 
            
            % window area
            win_num = app.WindowsNum.Value;
            % Height of windows = 1 m
            win_height = app.WindowsHeight.Value;
            % Width of windows = 1 m
            win_width = app.WindowsWidth.Value;
            win_area = win_num * win_height * win_width;
            
            
            % wall area 
            wall_area = 2 * length * height + 2 * width * height + 2 * length * width  - win_area;
            
            % window resistance
            win_lambda = 0.78;  
            win_d = 0.01;        
            win_res = win_d /(win_lambda * 3600 * win_area);
                   
            % wall resistance            
            % (wÿokno szklane do ocieplenia budynku)
            % hour is the time unit
            % [k] = J/s/m/C 
            lambda = app.WallMaterial.Value;
            if(strcmp(lambda,"Cegÿa"))
                wall_lambda = 0.77;
            elseif(strcmp(lambda,"Pustak"))
                wall_lambda = 0.4;
            elseif(strcmp(lambda,"ÿelbet"))
                wall_lambda = 1.7;
            else
                wall_lambda = 0.2;
            end
            
            wall_d = 0.2;
            wall_res = wall_d/wall_lambda;
            
            lambda_i = app.Insulation.Value;
            if(strcmp(lambda_i,"Brak"))
                ins_lambda = 0;
            elseif(strcmp(lambda_i,"Styropian"))
                ins_lambda = 0.04;
            elseif(strcmp(lambda_i,"Weÿna mineralna"))
                ins_lambda = 0.18;
            else
                ins_lambda = 0.17;
            end
            
            % Heat flux density q [W/m^2]
            % q = U(Ti-Te)   U - material conductivity [W/(K*m^2)
            
            %convective heat transfer  
            if(ins_lambda ~= 0)
                ins_d = 0.1;
                ins_res = ins_d/ins_lambda;
                total_wall_res = (wall_res + ins_res)/(3600 * wall_area);
            else
                 total_wall_res = wall_res /(3600 * wall_area);
            end

            
            U = 1/win_res + 1/total_wall_res;
            assignin('base','U',U);
            

            %density of air [kg/m^3]
            dens_air = 1.2250;
            %air mass
            M = length * width * height * dens_air;
            assignin('base','M',M);
            %cp of air (273 K) [J/kgK]
            c = 1005.4;
            assignin('base','c',c);
            %air flow rate [kg/hr]
            air_flow = 3600;
            assignin('base','air_flow',air_flow);
            
            % 1 kW-hr = 3.6e6 J
            % cost = 0.27 zl / 3.6e6 J
            cost = 0.27/3.6e6;
            assignin('base',"cost",cost);
            
            
            % Draw plots 
            assignin('base','init_temp', app.OutdoorTempSlider.Value);
            simout = sim('model','StopTime',num2str(app.DurationSlider.Value));
            
            % Plot of temperature outisde and inside the room
            if(app.TempCheckBox.Value == 1)
                app.TempAxes.Visible = 'on';
                plot(app.TempAxes,simout.temp);
                hold(app.TempAxes,'on');
                plot(app.TempAxes, simout.temp2);
                hold(app.TempAxes,'off');
                app.TempAxes.YLim = [-inf,25];
            else 
                app.TempAxes.Visible = 'off';
                app.TempAxes.cla;
            end
            
            % Consumption cost plot
            if(app.CostsCheckBox.Value == 1)
                app.CostAxes.Visible = 'on';
                plot(app.CostAxes,simout.cost);
            else 
                app.CostAxes.Visible = 'off';
                app.CostAxes.cla;
            end
            
            % Plot of produced energy
            if(app.PowerCheckBox.Value == 1)
                app.PowerAxes.Visible = 'on';
                plot(app.PowerAxes, simout.power);
            else
                app.PowerAxes.Visible = 'off';
                app.PowerAxes.cla;
            end
            
       
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 1143 777];
            app.UIFigure.Name = 'UI Figure';

            % Create Menu
            app.Menu = uimenu(app.UIFigure);
            app.Menu.Text = 'Menu';

            % Create TempAxes
            app.TempAxes = uiaxes(app.UIFigure);
            title(app.TempAxes, 'Temperature')
            xlabel(app.TempAxes, 'Time')
            ylabel(app.TempAxes, 'Temp')
            app.TempAxes.BackgroundColor = [0.9412 0.9412 0.9412];
            app.TempAxes.Position = [749 549 369 214];

            % Create CostAxes
            app.CostAxes = uiaxes(app.UIFigure);
            title(app.CostAxes, 'Cost')
            xlabel(app.CostAxes, 'Time')
            ylabel(app.CostAxes, 'Expense')
            app.CostAxes.Position = [749 320 365 208];

            % Create PowerAxes
            app.PowerAxes = uiaxes(app.UIFigure);
            title(app.PowerAxes, 'Energy consumption')
            xlabel(app.PowerAxes, 'Time')
            ylabel(app.PowerAxes, 'Power')
            app.PowerAxes.Position = [749 90 372 211];

            % Create PropertiesPanel
            app.PropertiesPanel = uipanel(app.UIFigure);
            app.PropertiesPanel.Title = 'Properties';
            app.PropertiesPanel.Position = [18 338 484 425];

            % Create RoomLabel
            app.RoomLabel = uilabel(app.PropertiesPanel);
            app.RoomLabel.FontSize = 13;
            app.RoomLabel.Position = [23 304 110 22];
            app.RoomLabel.Text = 'Room dimensions';

            % Create WindowsLabel
            app.WindowsLabel = uilabel(app.PropertiesPanel);
            app.WindowsLabel.FontSize = 13;
            app.WindowsLabel.Position = [302 170 128 22];
            app.WindowsLabel.Text = 'Windows dimensions';

            % Create lengthEditFieldLabel
            app.lengthEditFieldLabel = uilabel(app.PropertiesPanel);
            app.lengthEditFieldLabel.HorizontalAlignment = 'right';
            app.lengthEditFieldLabel.Position = [65 278 38 22];
            app.lengthEditFieldLabel.Text = 'length';

            % Create RoomLength
            app.RoomLength = uieditfield(app.PropertiesPanel, 'numeric');
            app.RoomLength.Position = [118 278 43 22];

            % Create WallCheckBox
            app.WallCheckBox = uicheckbox(app.PropertiesPanel);
            app.WallCheckBox.Text = 'Partition wall';
            app.WallCheckBox.FontSize = 13;
            app.WallCheckBox.Position = [23 249 96 22];

            % Create widthEditFieldLabel
            app.widthEditFieldLabel = uilabel(app.PropertiesPanel);
            app.widthEditFieldLabel.HorizontalAlignment = 'right';
            app.widthEditFieldLabel.Position = [192 278 34 22];
            app.widthEditFieldLabel.Text = 'width';

            % Create RoomWidth
            app.RoomWidth = uieditfield(app.PropertiesPanel, 'numeric');
            app.RoomWidth.Position = [241 278 43 22];

            % Create lengthEditField_2Label
            app.lengthEditField_2Label = uilabel(app.PropertiesPanel);
            app.lengthEditField_2Label.HorizontalAlignment = 'right';
            app.lengthEditField_2Label.Position = [65 220 38 22];
            app.lengthEditField_2Label.Text = 'length';

            % Create WallLength
            app.WallLength = uieditfield(app.PropertiesPanel, 'numeric');
            app.WallLength.Position = [118 220 43 22];

            % Create widthEditField_2Label
            app.widthEditField_2Label = uilabel(app.PropertiesPanel);
            app.widthEditField_2Label.HorizontalAlignment = 'right';
            app.widthEditField_2Label.Position = [187 220 34 22];
            app.widthEditField_2Label.Text = 'width';

            % Create WallWidth
            app.WallWidth = uieditfield(app.PropertiesPanel, 'numeric');
            app.WallWidth.Position = [236 220 43 22];

            % Create NumberofwindowsSpinnerLabel
            app.NumberofwindowsSpinnerLabel = uilabel(app.PropertiesPanel);
            app.NumberofwindowsSpinnerLabel.HorizontalAlignment = 'right';
            app.NumberofwindowsSpinnerLabel.Position = [24 157 111 22];
            app.NumberofwindowsSpinnerLabel.Text = 'Number of windows';

            % Create WindowsNum
            app.WindowsNum = uispinner(app.PropertiesPanel);
            app.WindowsNum.Position = [138 157 63 22];

            % Create heightEditField_2Label
            app.heightEditField_2Label = uilabel(app.PropertiesPanel);
            app.heightEditField_2Label.HorizontalAlignment = 'right';
            app.heightEditField_2Label.Position = [225 136 38 22];
            app.heightEditField_2Label.Text = 'height';

            % Create WindowsHeight
            app.WindowsHeight = uieditfield(app.PropertiesPanel, 'numeric');
            app.WindowsHeight.Position = [278 136 43 22];

            % Create heightEditFieldLabel
            app.heightEditFieldLabel = uilabel(app.PropertiesPanel);
            app.heightEditFieldLabel.HorizontalAlignment = 'right';
            app.heightEditFieldLabel.Position = [334 278 38 22];
            app.heightEditFieldLabel.Text = 'height';

            % Create RoomHeight
            app.RoomHeight = uieditfield(app.PropertiesPanel, 'numeric');
            app.RoomHeight.Position = [387 278 43 22];

            % Create widthEditField_3Label
            app.widthEditField_3Label = uilabel(app.PropertiesPanel);
            app.widthEditField_3Label.HorizontalAlignment = 'right';
            app.widthEditField_3Label.Position = [363 136 34 22];
            app.widthEditField_3Label.Text = 'width';

            % Create WindowsWidth
            app.WindowsWidth = uieditfield(app.PropertiesPanel, 'numeric');
            app.WindowsWidth.Position = [412 136 43 22];

            % Create WallmaterialDropDownLabel
            app.WallmaterialDropDownLabel = uilabel(app.PropertiesPanel);
            app.WallmaterialDropDownLabel.HorizontalAlignment = 'right';
            app.WallmaterialDropDownLabel.FontSize = 13;
            app.WallmaterialDropDownLabel.Position = [26 85 80 22];
            app.WallmaterialDropDownLabel.Text = 'Wall material';

            % Create WallMaterial
            app.WallMaterial = uidropdown(app.PropertiesPanel);
            app.WallMaterial.Items = {'Cegÿa', 'Pustak', 'ÿelbet', 'Bloczek z betonu komórkowego'};
            app.WallMaterial.FontSize = 13;
            app.WallMaterial.Position = [121 85 100 22];
            app.WallMaterial.Value = 'Cegÿa';

            % Create InsulationDropDownLabel
            app.InsulationDropDownLabel = uilabel(app.PropertiesPanel);
            app.InsulationDropDownLabel.HorizontalAlignment = 'right';
            app.InsulationDropDownLabel.FontSize = 13;
            app.InsulationDropDownLabel.Position = [45 50 61 22];
            app.InsulationDropDownLabel.Text = 'Insulation';

            % Create Insulation
            app.Insulation = uidropdown(app.PropertiesPanel);
            app.Insulation.Items = {'Brak', 'Styropian', 'Styropian grafitowy', 'Weÿna mineralna'};
            app.Insulation.FontSize = 13;
            app.Insulation.Position = [121 50 100 22];
            app.Insulation.Value = 'Brak';

            % Create RoomAboveCheckBox
            app.RoomAboveCheckBox = uicheckbox(app.PropertiesPanel);
            app.RoomAboveCheckBox.Text = 'There is a heated room above';
            app.RoomAboveCheckBox.FontSize = 13;
            app.RoomAboveCheckBox.Position = [269 11 196 22];

            % Create FloorSpinnerLabel
            app.FloorSpinnerLabel = uilabel(app.PropertiesPanel);
            app.FloorSpinnerLabel.HorizontalAlignment = 'right';
            app.FloorSpinnerLabel.FontSize = 13;
            app.FloorSpinnerLabel.Position = [26 353 35 22];
            app.FloorSpinnerLabel.Text = 'Floor';

            % Create Floor
            app.Floor = uispinner(app.PropertiesPanel);
            app.Floor.Limits = [0 20];
            app.Floor.FontSize = 13;
            app.Floor.Position = [76 353 100 22];

            % Create StartButton
            app.StartButton = uibutton(app.UIFigure, 'push');
            app.StartButton.ButtonPushedFcn = createCallbackFcn(app, @StartButtonPushed, true);
            app.StartButton.Position = [548 123 183 54];
            app.StartButton.Text = 'Start';

            % Create OutdoortemperatureSliderLabel
            app.OutdoortemperatureSliderLabel = uilabel(app.UIFigure);
            app.OutdoortemperatureSliderLabel.HorizontalAlignment = 'right';
            app.OutdoortemperatureSliderLabel.FontSize = 13;
            app.OutdoortemperatureSliderLabel.Position = [544 367 76 30];
            app.OutdoortemperatureSliderLabel.Text = {'Outdoor'; 'temperature'};

            % Create OutdoorTempSlider
            app.OutdoorTempSlider = uislider(app.UIFigure);
            app.OutdoorTempSlider.Limits = [-30 15];
            app.OutdoorTempSlider.Orientation = 'vertical';
            app.OutdoorTempSlider.Position = [638 370 3 202];

            % Create PlotsPanel
            app.PlotsPanel = uipanel(app.UIFigure);
            app.PlotsPanel.Title = 'Plots';
            app.PlotsPanel.Position = [531 617 160 146];

            % Create ShowplotLabel
            app.ShowplotLabel = uilabel(app.PlotsPanel);
            app.ShowplotLabel.FontSize = 14;
            app.ShowplotLabel.Position = [17 95 86 22];
            app.ShowplotLabel.Text = 'Show plot of:';

            % Create TempCheckBox
            app.TempCheckBox = uicheckbox(app.PlotsPanel);
            app.TempCheckBox.Text = 'Temperature';
            app.TempCheckBox.Position = [17 67 89 22];

            % Create CostsCheckBox
            app.CostsCheckBox = uicheckbox(app.PlotsPanel);
            app.CostsCheckBox.Text = 'Costs';
            app.CostsCheckBox.Position = [17 46 53 22];

            % Create PowerCheckBox
            app.PowerCheckBox = uicheckbox(app.PlotsPanel);
            app.PowerCheckBox.Text = 'Power';
            app.PowerCheckBox.Position = [17 25 56 22];

            % Create TimePanel
            app.TimePanel = uipanel(app.UIFigure);
            app.TimePanel.Title = 'Time';
            app.TimePanel.Position = [18 9 493 297];

            % Create fromEditFieldLabel
            app.fromEditFieldLabel = uilabel(app.TimePanel);
            app.fromEditFieldLabel.HorizontalAlignment = 'right';
            app.fromEditFieldLabel.Position = [209 98 29 22];
            app.fromEditFieldLabel.Text = 'from';

            % Create LowerFrom
            app.LowerFrom = uieditfield(app.TimePanel, 'numeric');
            app.LowerFrom.Position = [253 98 29 22];

            % Create LowerLabel
            app.LowerLabel = uilabel(app.TimePanel);
            app.LowerLabel.FontSize = 13;
            app.LowerLabel.Position = [209 146 133 22];
            app.LowerLabel.Text = 'Set lower temperature';

            % Create toEditFieldLabel
            app.toEditFieldLabel = uilabel(app.TimePanel);
            app.toEditFieldLabel.HorizontalAlignment = 'right';
            app.toEditFieldLabel.Position = [283 98 25 22];
            app.toEditFieldLabel.Text = 'to';

            % Create LowerTo
            app.LowerTo = uieditfield(app.TimePanel, 'numeric');
            app.LowerTo.Position = [323 98 29 22];

            % Create EverydayCheckBox
            app.EverydayCheckBox = uicheckbox(app.TimePanel);
            app.EverydayCheckBox.Text = 'Everyday';
            app.EverydayCheckBox.FontSize = 11;
            app.EverydayCheckBox.Position = [212 60 68 22];

            % Create DurationSliderLabel
            app.DurationSliderLabel = uilabel(app.TimePanel);
            app.DurationSliderLabel.HorizontalAlignment = 'right';
            app.DurationSliderLabel.FontSize = 13;
            app.DurationSliderLabel.Position = [8 236 55 22];
            app.DurationSliderLabel.Text = 'Duration';

            % Create DurationSlider
            app.DurationSlider = uislider(app.TimePanel);
            app.DurationSlider.Limits = [0 168];
            app.DurationSlider.MajorTicks = [0 24 48 72 96 120 144 168];
            app.DurationSlider.MinorTicks = [12 36 60 84 108 132 156];
            app.DurationSlider.Position = [87 246 378 3];

            % Create LowerLabel_2
            app.LowerLabel_2 = uilabel(app.TimePanel);
            app.LowerLabel_2.FontSize = 13;
            app.LowerLabel_2.Position = [8 124 84 49];
            app.LowerLabel_2.Text = {'Set room'; 'temperature'};

            % Create RoomTempSlider
            app.RoomTempSlider = uislider(app.TimePanel);
            app.RoomTempSlider.Limits = [5 30];
            app.RoomTempSlider.Orientation = 'vertical';
            app.RoomTempSlider.Position = [124 13 3 155];
            app.RoomTempSlider.Value = 5;

            % Create LowerTempSlider
            app.LowerTempSlider = uislider(app.TimePanel);
            app.LowerTempSlider.Limits = [5 30];
            app.LowerTempSlider.Orientation = 'vertical';
            app.LowerTempSlider.Position = [407 13 3 155];
            app.LowerTempSlider.Value = 5;

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = app_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end