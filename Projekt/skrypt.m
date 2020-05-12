% Room dimensions
init_temp = 0;
%length [m]
length = 8;
%width [m]
width = 6;
%height [m]
height = 2.5;
% radiany na stopnie
%r2d = 180/pi;
%nachylenie dachu
%roof_pitch = 40/r2d; 

% window area
win_num = 6;
% Height of windows = 1 m
win_height = 1;
% Width of windows = 1 m
win_width = 1;
win_area = win_num * win_height * win_width;


% wall area 
wall_area = 2 * length * height + 2 * width * height + 2 * length * width  - win_area;

       
% wall resistance            
% (włokno szklane do ocieplenia budynku)
% hour is the time unit
% [k] = J/s/m/C 
wall_lambda = 0.038;   
wall_d = 0.2;
wall_res = wall_d/(wall_lambda * 3600 * wall_area);

% window resistance
win_lambda = 0.78;  
win_d = 0.01;        
win_res = win_d /(win_lambda * 3600 * win_area);


% Heat flux density q [W/m^2]
% q = U(Ti-Te)   U - material conductivity [W/(K*m^2)])

%convective heat transfer  
U = 1/win_res + 1/wall_res; 

%density of air [kg/m^3]
dens_air = 1.2250;
%air mass
M = length * width * height * dens_air;
%cp of air (273 K) [J/kgK]
c = 1005.4;
%air flow rate [kg/hr]
air_flow = 3600;

% 1 kW-hr = 3.6e6 J
% cost = 0.27 zl / 3.6e6 J
cost = 0.27/3.6e6;


open('model');
sim('model');



