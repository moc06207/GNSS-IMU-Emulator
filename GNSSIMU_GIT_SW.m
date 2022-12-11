%clearvars -global
clear all;
format short;
clc;

%%%% CONFIGURATION %%%%
I = eye(3,3);

Hz = 50; % [Hz] (max: 50Hz)

g = 9.8; % [m/s^2]

wgs84 = wgs84Ellipsoid;

cnt = 1;

%%%% IMU Noise Configuration %%%%
%%% Accelerometer Noise Configuration %%%

S_aL = 1000e-6; % [] Linear error of scale factor

b_a = 5000e-6*g; % [m/s^2] turn-on to turn-on bias of the sensor
b_aM = 15e-6*g; % [m/s^2] bias in-run stability of the sensor.
tau_a = 0.5/3600; % [sec] correlration time
n_a = 60e-6*g; % [m/s^2/sqrt(Hz)(1-sigma)] zero-mean Gauss distributed white noise that gives rise to the VRW.
%%% Gyroscope Noise Configuration %%%
S_gL = 1500e-6; % [] Linear error of scale factor
b_g = 700; % [deg/h] turn-on to turn-on bias of the sensor
b_gM = 10; % [deg/h] bias in-run stability of the sensor.
tau_g = 0.5/3600; % [sec] correlration time
n_g = 1; % [deg/h/sqrt(Hz)] zero-mean Gauss distributed white noise that gives rise to the ARW.
N_gG = 0; % gyro g-sensitivity matrix, which is skew symmetric, with random Gaussian distributed component

%%%% GPS Noise Configuration %%%%
CM = 1; % Correction Mode (1 = SA, 2 = DGPS, 3 = RTK)
JS = 20; % Jamming to Signal Ratio [dB] max value : 40 [dB]
jamming_option = 1; % 1: jamming on, 0 = jamming off;

switch CM
    case 1
        var_CM = 10;
    case 2
        var_CM = 1;
    case 3
        var_CM = 0.01;
end

if jamming_option == 1
    JS = min(40,JS);
    var_JS = max(0.2*JS-1,0.01);
else
    var_JS = 0;
end

%%%% UDP Port Settings %%%%
u_gps = udpport("byte",LocalPort=1234,Timeout=2); %% GPS destination port
u_imu = udpport("byte",LocalPort=1236,Timeout=2); %% IMU destination poit


while 1
    tic
    imu = read(u_imu,107); %% read IMU data
    GPRMC = readline(u_gps); %% read GPS GPRMC data
    GPGGA = readline(u_gps); %% read GPS GPGGA data
    gps = split(GPGGA,','); %% split GPGGA data

    if cnt>=2
        axer_prev = ax_er;
        ayer_prev = ay_er;
        azer_prev = az_er;
        wxer_prev = wx_er;
        wyer_prev = wy_er;
        wzer_prev = wz_er;
        ax_prev = ax;
        ay_prev = ay;
        az_prev = az;
        wx_prev = wx;
        wy_prev = wy;
        wz_prev = wz;
        time_prev = time;
    end
    %%% GPGGA Data Parsing %%%
    Lat = floor(str2double(gps(3)) / 100) + mod(str2double(gps(3)), 100) / 60; %% Lattitude
    lon = floor(str2double(gps(5)) / 100) + mod(str2double(gps(5)), 100) / 60; %% longitude
    hgt = str2double(gps(10)); %% height
    UTC = str2double(gps(2)); %% UTC time
    time = floor(UTC/1e4)*3600 + floor((UTC-floor(UTC/1e4)*1e+4)/100)*60 + ...
        (UTC - floor(UTC/1e4)*1e+4 - floor((UTC-floor(UTC/1e4)*1e+4)/100)*100); %% GPS time [sec]

    wx = typecast(uint8(imu(58:65)),'double'); %% angluar velocity x
    wy = typecast(uint8(imu(66:73)),'double'); %% angluar velocity y
    wz = typecast(uint8(imu(74:81)),'double'); %% angluar velocity z
    ax = typecast(uint8(imu(82:89)),'double'); %% acceleration x
    ay = typecast(uint8(imu(90:97)),'double'); %% acceleration y
    az = typecast(uint8(imu(98:105)),'double'); %% acceleration z

    %%%% IMU Error Modeling %%%%
    if cnt == 1
        time0 = time;
        %%% Accelerometer Error Modeling %%%
        ax_er = (1 + S_aL)*ax + b_a + n_a*sqrt(Hz)*randn(); 
        ay_er = (1 + S_aL)*ay + b_a + n_a*sqrt(Hz)*randn();
        az_er = (1 + S_aL)*az + b_a + n_a*sqrt(Hz)*randn();
        %%% Gyroscpe Error Modeling %%%
        wx_er = (1 + S_gL)*wx + deg2rad(b_g)/3600 + deg2rad(n_g)/3600*sqrt(Hz)*randn();
        wy_er = (1 + S_gL)*wy + deg2rad(b_g)/3600 + deg2rad(n_g)/3600*sqrt(Hz)*randn();
        wz_er = (1 + S_gL)*wz + deg2rad(b_g)/3600 + deg2rad(n_g)/3600*sqrt(Hz)*randn();
    else
        %%% Accelerometer Error Modeling %%%
        ax_er = (1 + S_aL)*ax + b_a + axer_prev*exp(-1/Hz/tau_a) + b_aM*randn() + n_a*sqrt(Hz)*randn();
        ay_er = (1 + S_aL)*ay + b_a + ayer_prev*exp(-1/Hz/tau_a) + b_aM*randn() + n_a*sqrt(Hz)*randn();
        az_er = (1 + S_aL)*az + b_a + azer_prev*exp(-1/Hz/tau_a) + b_aM*randn() + n_a*sqrt(Hz)*randn();
        %%% Gyroscpe Error Modeling %%%
        wx_er = (1 + S_gL)*wx + deg2rad(b_g)/3600 + wxer_prev*exp(-1/Hz/tau_g) + deg2rad(b_gM)/3600*randn() + deg2rad(n_g)/3600*sqrt(Hz)*randn();
        wy_er = (1 + S_gL)*wy + deg2rad(b_g)/3600 + wyer_prev*exp(-1/Hz/tau_g) + deg2rad(b_gM)/3600*randn() + deg2rad(n_g)/3600*sqrt(Hz)*randn();
        wz_er = (1 + S_gL)*wz + deg2rad(b_g)/3600 + wzer_prev*exp(-1/Hz/tau_g) + deg2rad(b_gM)/3600*randn() + deg2rad(n_g)/3600*sqrt(Hz)*randn();
    end

    [N,E,D]=geodetic2ned(Lat,lon,hgt,37.23944667,126.77335,29,wgs84); %% Llh to NED
    %%%% GPS Error Modeling %%%%
    pos_ned = [N,E,D] + var_CM*rand(1,3) + var_JS*randn(1,3);
        
    [modeled_Lat,modeled_lon,modeled_hgt]=ned2geodetic(N,E,D,37.23944667,126.77335,29,wgs84); %% NED to Llh
    %%%% Print Output Data %%%%
    fprintf('modeled_output : [time : %f, Lat : %f, lon : %f, h : %f, A_x : %f, A_y : %f, A_z : %f, W_x : %f, W_y : %f, W_z : %f]\n', ...
            time-time0,modeled_Lat,modeled_lon,modeled_hgt,ax_er,ay_er,az_er,wx_er,wy_er,wz_er);

    T = toc;
    flush(u_gps) %% clear buffer
    pause(1/Hz-T) 

    cnt = cnt+1;
    
end
