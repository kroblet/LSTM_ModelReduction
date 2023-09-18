%% Initialization
gamma = 1.3;

mdot = 1; % kg/s
rho = 1.22; % air density
cp = 1005; % J/kgK 

P1 = 1e5; % MPa
T1 = 288.15; % K


T3 = 1800; % K
P4 = P1;

PRcomp = 8;
PRturb = 1/3;

isentropicTout = @(Tin,PR,k) Tin*(1/PR)^((1-k)/k)

%% Inlet burner
T2 = isentropicTout(T1, PRcomp, gamma)


%% Outlet turbine
T4 = isentropicTout(T1, PRturb, gamma)


%% Needed heat
Q = mdot*cp*(T3-T2);

%% Check turbine results
initialization

modelName = 'turboShaftGasTurbine.slx';
load_system(modelName);

engineOut = sim(modelName);

% Get entropies
s1_timeseries = engineOut.simlog.s1P1T1.Thermodynamic_Properties_Sensor_G.S.series.values;
s1 = s1_timeseries(end);

s2_timeseries = engineOut.simlog.s2P2T2.Thermodynamic_Properties_Sensor_G.S.series.values;
s2 = s2_timeseries(end);

s3_timeseries = engineOut.simlog.s3P3T3.Thermodynamic_Properties_Sensor_G.S.series.values;
s3 = s3_timeseries(end);

s4_timeseries = engineOut.simlog.s4P4T4.Thermodynamic_Properties_Sensor_G.S.series.values;
s4 = s4_timeseries(end);

s5_timeseries = engineOut.simlog.s5P5T5.Thermodynamic_Properties_Sensor_G.S.series.values;
s5 = s5_timeseries(end);

s = [s1, s2, s3, s4, s5];

% Get temperatures
t1_timeseries = engineOut.simlog.s1P1T1.Pressure_Temperature_Sensor_G.T.series.values;
t1 = t1_timeseries(end);

t2_timeseries = engineOut.simlog.s2P2T2.Pressure_Temperature_Sensor_G.T.series.values;
t2 = t2_timeseries(end);

t3_timeseries = engineOut.simlog.s3P3T3.Pressure_Temperature_Sensor_G.T.series.values;
t3 = t3_timeseries(end);

t4_timeseries = engineOut.simlog.s4P4T4.Pressure_Temperature_Sensor_G.T.series.values;
t4 = t4_timeseries(end);

t5_timeseries = engineOut.simlog.s5P5T5.Pressure_Temperature_Sensor_G.T.series.values;
t5 = t5_timeseries(end);

t = [t1, t2, t3, t4, t5];

% Get pressures
p1_timeseries = engineOut.simlog.s1P1T1.Pressure_Temperature_Sensor_G.Pa.series.values;
p1 = p1_timeseries(end);

p2_timeseries = engineOut.simlog.s2P2T2.Pressure_Temperature_Sensor_G.Pa.series.values;
p2 = p2_timeseries(end);

p3_timeseries = engineOut.simlog.s3P3T3.Pressure_Temperature_Sensor_G.Pa.series.values;
p3 = p3_timeseries(end);

p4_timeseries = engineOut.simlog.s4P4T4.Pressure_Temperature_Sensor_G.Pa.series.values;
p4 = p4_timeseries(end);

p5_timeseries = engineOut.simlog.s5P5T5.Pressure_Temperature_Sensor_G.Pa.series.values;
p5 = p5_timeseries(end);

p = [p1, p2, p3, p4, p5];


% Get specific volume
v1_timeseries = 1/engineOut.simlog.s1P1T1.Thermodynamic_Properties_Sensor_G.RHO.series.values;
v1 = v1_timeseries(end);

v2_timeseries = 1/engineOut.simlog.s2P2T2.Thermodynamic_Properties_Sensor_G.RHO.series.values;
v2 = v2_timeseries(end);

v3_timeseries = 1/engineOut.simlog.s3P3T3.Thermodynamic_Properties_Sensor_G.RHO.series.values;
v3 = v3_timeseries(end);

v4_timeseries = 1/engineOut.simlog.s4P4T4.Thermodynamic_Properties_Sensor_G.RHO.series.values;
v4 = v4_timeseries(end);

v5_timeseries = 1/engineOut.simlog.s5P5T5.Thermodynamic_Properties_Sensor_G.RHO.series.values;
v5 = v5_timeseries(end);

v = [v1, v2, v3, v4, v5];


% Visualize Brayton cycle
figure
axTS = subplot (3,1,1);
axPV = subplot (3,1,2);
axPT = subplot (3,1,3);
plot(axTS, s,t)
xlabel(axTS, "Entropy J/(kgK)")
ylabel(axTS,"Temperature (K)")

plot(axPV, v, p)
xlabel(axPV, "Specific volume (m3/kg)")
ylabel(axPV,"Pressure (Pa)")

plot(axPT, t, p)
xlabel(axPT, "Temperature (K)")
ylabel(axPT,"Pressure (Pa)")

% Pressure ratios

disp(['Compressor actual PR: ', num2str(p2/p1)])
disp(['Turbine actual PR: ', num2str(p3/p4)])
disp(['TET (K): ', num2str(t3)])

%% Investigate outlet conditions

cair = sqrt(1+t4/273.15)*331.3;
maux = engineOut.simlog.Turbine_G.mdot_A.series.values;
mdot4 = maux(end);
rhoaux = engineOut.simlog.s4P4T4.Thermodynamic_Properties_Sensor_G.RHO.series.values;
rho4 = rhoaux(end);

u = mdot4/rho4/turbine.outletArea;

M4 = u/cair

%% 

