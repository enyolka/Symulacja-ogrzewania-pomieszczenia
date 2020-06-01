classdef app_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                     matlab.ui.Figure
        TempAxes                     matlab.ui.control.UIAxes
        CostAxes                     matlab.ui.control.UIAxes
        PowerAxes                    matlab.ui.control.UIAxes
        PropertiesPanel              matlab.ui.container.Panel
        RoomLabel                    matlab.ui.control.Label
        WindowsLabel                 matlab.ui.control.Label
        lengthEditFieldLabel         matlab.ui.control.Label
        RoomLength                   matlab.ui.control.NumericEditField
        PWallCheckBox                matlab.ui.control.CheckBox
        widthEditFieldLabel          matlab.ui.control.Label
        RoomWidth                    matlab.ui.control.NumericEditField
        lengthEditField_2Label       matlab.ui.control.Label
        PWallLength                  matlab.ui.control.NumericEditField
        NumberofwindowsSpinnerLabel  matlab.ui.control.Label
        WindowsNum                   matlab.ui.control.Spinner
        heightEditField_2Label       matlab.ui.control.Label
        WindowsHeight                matlab.ui.control.NumericEditField
        heightEditFieldLabel         matlab.ui.control.Label
        RoomHeight                   matlab.ui.control.NumericEditField
        widthEditField_3Label        matlab.ui.control.Label
        WindowsWidth                 matlab.ui.control.NumericEditField
        WallmaterialDropDownLabel    matlab.ui.control.Label
        WallMaterial                 matlab.ui.control.DropDown
        InsulationDropDownLabel      matlab.ui.control.Label
        Insulation                   matlab.ui.control.DropDown
        RoomAboveCheckBox            matlab.ui.control.CheckBox
        FloorSpinnerLabel            matlab.ui.control.Label
        Floor                        matlab.ui.control.Spinner
        StartButton                  matlab.ui.control.Button
        PlotsPanel                   matlab.ui.container.Panel
        ShowplotLabel                matlab.ui.control.Label
        TempCheckBox                 matlab.ui.control.CheckBox
        CostsCheckBox                matlab.ui.control.CheckBox
        PowerCheckBox                matlab.ui.control.CheckBox
        TimePanel                    matlab.ui.container.Panel
        fromEditFieldLabel           matlab.ui.control.Label
        LowerFrom                    matlab.ui.control.NumericEditField
        LowerLabel                   matlab.ui.control.Label
        toEditFieldLabel             matlab.ui.control.Label
        LowerTo                      matlab.ui.control.NumericEditField
        EverydayCheckBox             matlab.ui.control.CheckBox
        DurationSliderLabel          matlab.ui.control.Label
        DurationSlider               matlab.ui.control.Slider
        LowerLabel_2                 matlab.ui.control.Label
        RoomTempSlider               matlab.ui.control.Slider
        LowerTempSlider              matlab.ui.control.Slider
        ShowsummaryButton            matlab.ui.control.Button
        SaveButton                   matlab.ui.control.Button
        Weather                      matlab.ui.container.Panel
        StationDropDownLabel         matlab.ui.control.Label
        Station                      matlab.ui.control.DropDown
        DateDatePickerLabel          matlab.ui.control.Label
        DateDatePicker               matlab.ui.control.DatePicker
        DateDatePicker_2Label        matlab.ui.control.Label
        DateDatePicker_2             matlab.ui.control.DatePicker
        TryLongTerm                  matlab.ui.control.CheckBox
    end

    
    properties (Access = public)
        costs 
        uit 
        fig 
        size
        wsize
        power
        sum_temp
        how_long
       
        % Description
    end
    
    methods (Access = private)
        
        
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            % Visibility of plots
            app.TempAxes.Visible = 'off';
            app.CostAxes.Visible = 'off';
            app.PowerAxes.Visible = 'off';
            
            app.PWallLength.Visible = 'off';
            app.lengthEditField_2Label.Visible = 'off';
            app.DateDatePicker_2.Visible = 'off';
            app.DateDatePicker_2Label.Visible = 'off';
            
            % Set initial values for temperature
            app.RoomTempSlider.Value = 21;
            app.LowerTempSlider.Value = 21;
            
            % Create summarization table
            app.fig = figure('Visible',"off");
            app.fig.Position = [800 800 950 330];
            app.uit = uitable(app.fig);
            app.uit.ColumnName = {'City','Outside temp','Room temp','Lower temp', 'Duration(h)','Size (partitional)','Windows', 'W. size','Wall material','Insulation','Time(h)','Power(kJ)','Cost(zl)'};
            app.uit.ColumnWidth = {'auto',70,70,70,70,80,50,50,'auto','auto','auto',65, 'auto'};
            app.uit.RowName = 'numbered';
            app.uit.Position = [15 20 900 300];
            
            % Limits for picking date from weather history
            app.DateDatePicker.Limits = [datetime([2008 1 1]) datetime('yesterday')];
            app.DateDatePicker_2.Limits = [datetime([2008 1 1]) datetime('yesterday')];

        end

        % Button pushed function: StartButton
        function StartButtonPushed(app, event)
            
            app.CostAxes.cla;
            app.PowerAxes.cla;
            
            % Set temperature
            lower_from = app.LowerFrom.Value;
            lower_to = app.LowerTo.Value;
            
            % Check regularity
            if(app.EverydayCheckBox.Value == 1)
                assignin('base','modulo',24);
            else 
                assignin('base','modulo',app.DurationSlider.Value);
            end
            
            % Set lower temperature 
            if(lower_from <= lower_to)
                assignin('base', 'lower_from', lower_from);
                assignin('base', 'lower_to', lower_to);
                assignin('base',"set_room", app.RoomTempSlider.Value);
                assignin('base',"set_lower", app.LowerTempSlider.Value);
                if(lower_from == lower_to)
                    assignin('base',"set_lower", app.RoomTempSlider.Value);
                end
            else
                assignin('base', 'lower_to', lower_from);
                assignin('base', 'lower_from', lower_to);
                assignin('base',"set_room", app.LowerTempSlider.Value);
                assignin('base',"set_lower", app.RoomTempSlider.Value);
            end

        
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
            
            if(length == 0 || width == 0 || height == 0)
                errordlg('Enter room dimensions');
                return
            end
            
            plength = app.PWallLength.Value;
            
            % window area
            win_num = app.WindowsNum.Value;
            % Height of windows = 1 m
            win_height = app.WindowsHeight.Value;
            % Width of windows = 1 m
            win_width = app.WindowsWidth.Value;
            win_area = win_num * win_height * win_width;
            
            app.size = char(append(num2str(length) ,'x', num2str(width) ,'x', num2str(height), ' (' , num2str(plength), ')'));
            app.wsize = char(append(num2str(win_height) ,'x', num2str(win_width)));
            
            % wall area 
            wall_area = 2 * length * height + 2 * width * height - win_area - plength * height;
            
            
            % window resistance
            win_lambda = 0.78;  
            win_d = 0.01;        
            win_res = win_d /(win_lambda * 3600 * win_area);
                   
            % wall resistance            
            % hour is the time unit
            % [k] = J/s/m/C 
            lambda = app.WallMaterial.Value;	
			
            if(strcmp(lambda,"brick"))
                wall_lambda = 0.77;
            elseif(strcmp(lambda,"airbrick"))
                wall_lambda = 0.4;
            elseif(strcmp(lambda,"reinforced concrete"))
                wall_lambda = 1.7;
            else
                wall_lambda = 0.2;
            end
            
            wall_d = 0.2;
            wall_res = wall_d/wall_lambda;
            
            % insulation resistance
            
            lambda_i = app.Insulation.Value;
            if(strcmp(lambda_i,"absence"))
                ins_lambda = 0;
            elseif(strcmp(lambda_i,"styrofoam"))
                ins_lambda = 0.04;
            elseif(strcmp(lambda_i,"mineral wool"))
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
            
            % Check if the room loses heat through the ceiling and the
            % ground
            if(app.RoomAboveCheckBox.Value == 0)
                ceiling_res = 0.3/(0.5 * 3600 * length*width);
                U = U + 1/ceiling_res; 
            end
            
            if(app.Floor.Value == 0)
                floor_res = 0.5/(1.5 * 3600 * length*width);
                U = U + 1/floor_res;
            end
            
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
            
            
            
            %Weather
            %{ 
                Krakow: 12566 
                Warszawa: 12375
                Gdansk: 12150
                Wroclaw: 12424
                Poznan: 12330
            %}
            
            % Choose wheather station
            which_station = app.Station.Value;
            if(strcmp(which_station,"Warsaw"))
                station = '12375';
            elseif(strcmp(which_station,"Gdansk"))
                station = '12150';
            elseif(strcmp(which_station,"Wroclaw"))
                station = '12424';
            elseif(strcmp(which_station,"Poznan"))
                station = '12330';
            else
                station = '12566';
            end
            
            
            % Pick a day
            formatOut = 'yyyy-mm-dd';
            start = app.DateDatePicker.Value;
            start_day = datestr(start, formatOut);
            
            if(app.TryLongTerm.Value == 1)
               stop = app.DateDatePicker_2.Value;
               end_day = datestr(stop,formatOut);
               app.how_long = 24*(datenum(end_day) - datenum(start_day)) + 24;
            else
               app.how_long = app.DurationSlider.Value; 
               if(mod(app.how_long,24)==0)
                add_days = fix(app.how_long/24);
               else 
                add_days = fix(app.how_long/24)+1;
               end  
            
               date = datenum(start_day);
               date = addtodate(date, add_days-1, 'day');
            
               if(date>=datenum(datetime('today')))
                date = datetime('yesterday');
                end_day = datestr(date,formatOut);
                app.how_long = 24*(datenum(end_day) - datenum(start_day)) + 24;
                warndlg('Cannot predict the weather. Simulation shortened.', 'Warning!');
               else
                 end_day = datestr(date,formatOut);
               end
            end
            
            key = 'db57U7X7';
            options = weboptions('ContentType','json','Timeout',15);
               
            temp_start = start_day;
            temp_end = end_day;
            next_start = app.how_long;
            x = 0;
            app.costs = 0;
            app.power = 0;
                
            while true   
                
                app.how_long = next_start;
                start_day = temp_start;
                 
                if app.how_long > 1344
                    next_start = app.how_long - 1344;
                    app.how_long = 1344;
                end
                
                temp_end = datestr(addtodate(datenum(temp_start), fix(app.how_long/24), 'day'), formatOut);                
                end_day = temp_end; 
                
                url = ['https://api.meteostat.net/v1/history/hourly?station=', station, '&start=', start_day, '&end=', end_day, '&time_zone=Europe/Warsaw&time_format=Y-m-d%20H:i&key=',key];
                Current_Data = webread(url, options);
                
                ti = [0:app.how_long-2]';
                temp = [Current_Data.data.temperature]';
                temperature = [ti,temp(1:fix(app.how_long)-1,:)];
                assignin('base', 'temperature', temperature);
                app.sum_temp = mean(temperature,1);
                %dlmwrite('temp.csv',temperature,'-append');


                % Draw plots 
                %simout = sim('model','StopTime',num2str(app.DurationSlider.Value));
                simout = sim('model','StopTime',num2str(app.how_long));

                % Plot of temperature outisde and inside the room
                if(app.TempCheckBox.Value == 1)
                    app.TempAxes.Visible = 'on';
                    a = plot(app.TempAxes, simout.temp.Time + x,simout.temp.Data,'r');
                    new_y1 = get(a,'YData');
                    b = plot(app.TempAxes, simout.temp2.Time + x, simout.temp2.Data,'b');
                    ax = get(b,'XData');
                    new_x = ax ./ 24;
                    new_y2 = get(b,'YData');
                    delete(a); delete(b);
                    plot(app.TempAxes,new_x,new_y1,'r');
                    hold(app.TempAxes,'on');
                    plot(app.TempAxes,new_x,new_y2,'b');
                    app.TempAxes.YLim = [-inf,30];
                else 
                    app.TempAxes.Visible = 'off';
                    app.TempAxes.cla;
                end

                % Consumption cost plot
                if(app.CostsCheckBox.Value == 1)
                    app.CostAxes.Visible = 'on';
                    hold(app.CostAxes,'on');
                    a = plot(app.CostAxes,simout.cost.Time + x, simout.cost.Data + app.costs, 'g');
                    ax = get(a,'XData');
                    new_x = ax ./ 24;
                    new_y = get(a,'YData');
                    delete(a);
                    plot(app.CostAxes,new_x,new_y,'g');
                else 
                    app.CostAxes.Visible = 'off';
                    app.CostAxes.cla;
                end

                % Plot of produced energy
                if(app.PowerCheckBox.Value == 1)
                    app.PowerAxes.Visible = 'on';
                    hold(app.PowerAxes,'on');
                    a = plot(app.PowerAxes, simout.power.Time + x,simout.power.Data + app.power,'m');
                    ax = get(a,'XData');
                    new_x = ax ./ 24;
                    new_y = get(a,'YData');
                    delete(a);
                    plot(app.PowerAxes,new_x,new_y,'m');
                else
                    app.PowerAxes.Visible = 'off';
                    app.PowerAxes.cla;
                end
                 
                 app.costs = app.costs + simout.cost.Data(end);
                 app.power = app.power + simout.power.Data(end);   
                    
                 if(app.how_long < 1344)
                     break;         
                 end
                 
                temp_start = datestr(addtodate(datenum(end_day),1,'day'), formatOut); 
                x = x + 1344;
                %temp = [];
                %ti = [];
                clear Current_Data;
                                           
            end
      
          
            hold(app.TempAxes,'off'); 
            hold(app.CostAxes,'off'); 
            hold(app.PowerAxes,'off'); 
            
        end

        % Value changed function: PWallCheckBox
        function PWallCheckBoxValueChanged(app, event)
            % Check if the room has the partitional wall 
            value = app.PWallCheckBox.Value;
            if(value == 1)
                app.PWallLength.Visible = 'on';
                app.lengthEditField_2Label.Visible = 'on';
            else 
                app.PWallLength.Visible = 'off';
                app.lengthEditField_2Label.Visible = 'off';
                app.PWallLength.Value = 0;
            end
                   
        end

        % Button pushed function: ShowsummaryButton
        function ShowsummaryButtonPushed(app, event)
            
            %t = sortrows(t,'Cost');
            openfig('newout.fig','new','visible')
            
        end

        % Button pushed function: SaveButton
        function SaveButtonPushed(app, event)
            %{
            start_day = datestr(app.DateDatePicker.Value);
            how_long = app.DurationSlider.Value;
            if(mod(how_long,24)==0)
                add_days = fix(how_long/24);
            else 
                add_days = fix(how_long/24)+1;
            end  
            date = datenum(start_day);
            date = addtodate(date, add_days-1, 'day');
            
            if(date>=datenum(datetime('today')))
                date = datetime('yesterday');
                end_day = datestr(date);
                how_long = 24*(datenum(end_day) - datenum(start_day)) + 24;
            end
            %}
            
            time = round(app.how_long);
            %time = round(app.DurationSlider.Value);
            
            % Time to set lower temperature
            if(app.LowerFrom.Value <= app.LowerTo.Value)
                time_diff = app.LowerTo.Value - app.LowerFrom.Value;
            else
                time_diff = 24 - app.LowerFrom.Value + app.LowerTo.Value;
            end
	    time_diff_str = char(append(num2str(app.LowerFrom.Value),'-',num2str(app.LowerTo.Value), ' (' , num2str(time_diff), 'h)'));

            % Insert data into the table and refresh 
            cData = {app.Station.Value, app.sum_temp(2), app.RoomTempSlider.Value, app.LowerTempSlider.Value, time_diff_str, app.size, app.WindowsNum.Value, app.wsize, app.WallMaterial.Value, app.Insulation.Value, time, app.power, app.costs};
            old = get(app.uit, 'data');
            new = [old ; cData];
            set(app.uit, 'data', new);
            saveas(app.fig,'newout','fig');
            
        end

        % Value changed function: TryLongTerm
        function TryLongTermValueChanged(app, event)
            value = app.TryLongTerm.Value;
            if(value == 1)
                app.DateDatePicker_2.Visible = 'on';
                app.DateDatePicker_2Label.Visible = 'on';
            else
                app.DateDatePicker_2.Visible = 'off';
                app.DateDatePicker_2Label.Visible = 'off';
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 1143 763];
            app.UIFigure.Name = 'UI Figure';

            % Create TempAxes
            app.TempAxes = uiaxes(app.UIFigure);
            title(app.TempAxes, 'Temperature ')
            xlabel(app.TempAxes, 'Time (days)')
            ylabel(app.TempAxes, 'Temp (*C)')
            app.TempAxes.BackgroundColor = [0.9412 0.9412 0.9412];
            app.TempAxes.Position = [749 532 369 214];

            % Create CostAxes
            app.CostAxes = uiaxes(app.UIFigure);
            title(app.CostAxes, 'Cost')
            xlabel(app.CostAxes, 'Time (days)')
            ylabel(app.CostAxes, 'Expense (zl)')
            app.CostAxes.Position = [749 295 365 208];

            % Create PowerAxes
            app.PowerAxes = uiaxes(app.UIFigure);
            title(app.PowerAxes, 'Energy consumption')
            xlabel(app.PowerAxes, 'Time (days)')
            ylabel(app.PowerAxes, 'Power (J)')
            app.PowerAxes.Position = [749 46 372 211];

            % Create PropertiesPanel
            app.PropertiesPanel = uipanel(app.UIFigure);
            app.PropertiesPanel.Title = 'Properties';
            app.PropertiesPanel.Position = [18 348 489 401];

            % Create RoomLabel
            app.RoomLabel = uilabel(app.PropertiesPanel);
            app.RoomLabel.FontSize = 13;
            app.RoomLabel.Position = [23 280 110 22];
            app.RoomLabel.Text = 'Room dimensions';

            % Create WindowsLabel
            app.WindowsLabel = uilabel(app.PropertiesPanel);
            app.WindowsLabel.FontSize = 13;
            app.WindowsLabel.Position = [302 146 128 22];
            app.WindowsLabel.Text = 'Windows dimensions';

            % Create lengthEditFieldLabel
            app.lengthEditFieldLabel = uilabel(app.PropertiesPanel);
            app.lengthEditFieldLabel.HorizontalAlignment = 'right';
            app.lengthEditFieldLabel.Position = [65 254 38 22];
            app.lengthEditFieldLabel.Text = 'length';

            % Create RoomLength
            app.RoomLength = uieditfield(app.PropertiesPanel, 'numeric');
            app.RoomLength.Limits = [0 Inf];
            app.RoomLength.Position = [118 254 43 22];

            % Create PWallCheckBox
            app.PWallCheckBox = uicheckbox(app.PropertiesPanel);
            app.PWallCheckBox.ValueChangedFcn = createCallbackFcn(app, @PWallCheckBoxValueChanged, true);
            app.PWallCheckBox.Text = 'Partition wall';
            app.PWallCheckBox.FontSize = 13;
            app.PWallCheckBox.Position = [26 209 96 22];

            % Create widthEditFieldLabel
            app.widthEditFieldLabel = uilabel(app.PropertiesPanel);
            app.widthEditFieldLabel.HorizontalAlignment = 'right';
            app.widthEditFieldLabel.Position = [192 254 34 22];
            app.widthEditFieldLabel.Text = 'width';

            % Create RoomWidth
            app.RoomWidth = uieditfield(app.PropertiesPanel, 'numeric');
            app.RoomWidth.Limits = [0 Inf];
            app.RoomWidth.Position = [241 254 43 22];

            % Create lengthEditField_2Label
            app.lengthEditField_2Label = uilabel(app.PropertiesPanel);
            app.lengthEditField_2Label.HorizontalAlignment = 'right';
            app.lengthEditField_2Label.Position = [192 209 38 22];
            app.lengthEditField_2Label.Text = 'length';

            % Create PWallLength
            app.PWallLength = uieditfield(app.PropertiesPanel, 'numeric');
            app.PWallLength.Limits = [0 Inf];
            app.PWallLength.HandleVisibility = 'callback';
            app.PWallLength.Position = [245 209 43 22];

            % Create NumberofwindowsSpinnerLabel
            app.NumberofwindowsSpinnerLabel = uilabel(app.PropertiesPanel);
            app.NumberofwindowsSpinnerLabel.HorizontalAlignment = 'right';
            app.NumberofwindowsSpinnerLabel.Position = [26 146 111 22];
            app.NumberofwindowsSpinnerLabel.Text = 'Number of windows';

            % Create WindowsNum
            app.WindowsNum = uispinner(app.PropertiesPanel);
            app.WindowsNum.Limits = [0 Inf];
            app.WindowsNum.Position = [140 146 63 22];

            % Create heightEditField_2Label
            app.heightEditField_2Label = uilabel(app.PropertiesPanel);
            app.heightEditField_2Label.HorizontalAlignment = 'right';
            app.heightEditField_2Label.Position = [225 112 38 22];
            app.heightEditField_2Label.Text = 'height';

            % Create WindowsHeight
            app.WindowsHeight = uieditfield(app.PropertiesPanel, 'numeric');
            app.WindowsHeight.Limits = [0 Inf];
            app.WindowsHeight.Position = [278 112 43 22];

            % Create heightEditFieldLabel
            app.heightEditFieldLabel = uilabel(app.PropertiesPanel);
            app.heightEditFieldLabel.HorizontalAlignment = 'right';
            app.heightEditFieldLabel.Position = [334 254 38 22];
            app.heightEditFieldLabel.Text = 'height';

            % Create RoomHeight
            app.RoomHeight = uieditfield(app.PropertiesPanel, 'numeric');
            app.RoomHeight.Limits = [0 Inf];
            app.RoomHeight.Position = [387 254 43 22];

            % Create widthEditField_3Label
            app.widthEditField_3Label = uilabel(app.PropertiesPanel);
            app.widthEditField_3Label.HorizontalAlignment = 'right';
            app.widthEditField_3Label.Position = [363 112 34 22];
            app.widthEditField_3Label.Text = 'width';

            % Create WindowsWidth
            app.WindowsWidth = uieditfield(app.PropertiesPanel, 'numeric');
            app.WindowsWidth.Limits = [0 Inf];
            app.WindowsWidth.Position = [412 112 43 22];

            % Create WallmaterialDropDownLabel
            app.WallmaterialDropDownLabel = uilabel(app.PropertiesPanel);
            app.WallmaterialDropDownLabel.HorizontalAlignment = 'right';
            app.WallmaterialDropDownLabel.FontSize = 13;
            app.WallmaterialDropDownLabel.Position = [26 61 80 22];
            app.WallmaterialDropDownLabel.Text = 'Wall material';

            % Create WallMaterial
            app.WallMaterial = uidropdown(app.PropertiesPanel);
            app.WallMaterial.Items = {'brick', 'airbrick', 'reinforced concrete', 'autoclaved aerated concrete (AAC)'};
            app.WallMaterial.FontSize = 13;
            app.WallMaterial.Position = [121 61 100 22];
            app.WallMaterial.Value = 'brick';

            % Create InsulationDropDownLabel
            app.InsulationDropDownLabel = uilabel(app.PropertiesPanel);
            app.InsulationDropDownLabel.HorizontalAlignment = 'right';
            app.InsulationDropDownLabel.FontSize = 13;
            app.InsulationDropDownLabel.Position = [45 26 61 22];
            app.InsulationDropDownLabel.Text = 'Insulation';

            % Create Insulation
            app.Insulation = uidropdown(app.PropertiesPanel);
            app.Insulation.Items = {'absence', 'styrofoam', 'graphite foam', 'mineral wool'};
            app.Insulation.FontSize = 13;
            app.Insulation.Position = [121 26 100 22];
            app.Insulation.Value = 'absence';

            % Create RoomAboveCheckBox
            app.RoomAboveCheckBox = uicheckbox(app.PropertiesPanel);
            app.RoomAboveCheckBox.Text = 'There is a heated room above';
            app.RoomAboveCheckBox.FontSize = 13;
            app.RoomAboveCheckBox.Position = [241 329 196 22];

            % Create FloorSpinnerLabel
            app.FloorSpinnerLabel = uilabel(app.PropertiesPanel);
            app.FloorSpinnerLabel.HorizontalAlignment = 'right';
            app.FloorSpinnerLabel.FontSize = 13;
            app.FloorSpinnerLabel.Position = [26 329 35 22];
            app.FloorSpinnerLabel.Text = 'Floor';

            % Create Floor
            app.Floor = uispinner(app.PropertiesPanel);
            app.Floor.Limits = [0 20];
            app.Floor.FontSize = 13;
            app.Floor.Position = [76 329 100 22];

            % Create StartButton
            app.StartButton = uibutton(app.UIFigure, 'push');
            app.StartButton.ButtonPushedFcn = createCallbackFcn(app, @StartButtonPushed, true);
            app.StartButton.FontSize = 15;
            app.StartButton.FontWeight = 'bold';
            app.StartButton.FontColor = [0.2157 0.3137 0.5098];
            app.StartButton.Position = [544 107 177 54];
            app.StartButton.Text = 'Start';

            % Create PlotsPanel
            app.PlotsPanel = uipanel(app.UIFigure);
            app.PlotsPanel.Title = 'Plots';
            app.PlotsPanel.Position = [531 603 160 146];

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
            app.TimePanel.Position = [18 25 493 297];

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

            % Create ShowsummaryButton
            app.ShowsummaryButton = uibutton(app.UIFigure, 'push');
            app.ShowsummaryButton.ButtonPushedFcn = createCallbackFcn(app, @ShowsummaryButtonPushed, true);
            app.ShowsummaryButton.FontWeight = 'bold';
            app.ShowsummaryButton.FontColor = [0.2157 0.3137 0.5098];
            app.ShowsummaryButton.Position = [605 66 116 32];
            app.ShowsummaryButton.Text = 'Show summary';

            % Create SaveButton
            app.SaveButton = uibutton(app.UIFigure, 'push');
            app.SaveButton.ButtonPushedFcn = createCallbackFcn(app, @SaveButtonPushed, true);
            app.SaveButton.FontWeight = 'bold';
            app.SaveButton.FontColor = [0.2157 0.3137 0.5098];
            app.SaveButton.Position = [544 66 58 32];
            app.SaveButton.Text = 'Save';

            % Create Weather
            app.Weather = uipanel(app.UIFigure);
            app.Weather.Title = 'Weather';
            app.Weather.Position = [531 391 160 183];

            % Create StationDropDownLabel
            app.StationDropDownLabel = uilabel(app.Weather);
            app.StationDropDownLabel.HorizontalAlignment = 'right';
            app.StationDropDownLabel.Position = [1 124 47 22];
            app.StationDropDownLabel.Text = 'Station';

            % Create Station
            app.Station = uidropdown(app.Weather);
            app.Station.Items = {'Cracow', 'Warsaw', 'Gdansk', 'Wroclaw', 'Poznan', ''};
            app.Station.Position = [59 124 78 22];
            app.Station.Value = 'Cracow';

            % Create DateDatePickerLabel
            app.DateDatePickerLabel = uilabel(app.Weather);
            app.DateDatePickerLabel.HorizontalAlignment = 'right';
            app.DateDatePickerLabel.Position = [6 82 27 22];
            app.DateDatePickerLabel.Text = 'Date';

            % Create DateDatePicker
            app.DateDatePicker = uidatepicker(app.Weather);
            app.DateDatePicker.Limits = [datetime([2008 1 1]) datetime([2020 12 31])];
            app.DateDatePicker.Position = [41 82 109 22];

            % Create DateDatePicker_2Label
            app.DateDatePicker_2Label = uilabel(app.Weather);
            app.DateDatePicker_2Label.HorizontalAlignment = 'right';
            app.DateDatePicker_2Label.Position = [8 18 27 22];
            app.DateDatePicker_2Label.Text = 'Date';

            % Create DateDatePicker_2
            app.DateDatePicker_2 = uidatepicker(app.Weather);
            app.DateDatePicker_2.Limits = [datetime([2008 1 1]) datetime([2020 12 31])];
            app.DateDatePicker_2.Position = [43 18 109 22];

            % Create TryLongTerm
            app.TryLongTerm = uicheckbox(app.Weather);
            app.TryLongTerm.ValueChangedFcn = createCallbackFcn(app, @TryLongTermValueChanged, true);
            app.TryLongTerm.Text = 'Try long term';
            app.TryLongTerm.Position = [14 48 92 22];

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