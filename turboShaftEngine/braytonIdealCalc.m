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

s = [s1, s2, s3, s4];

% Get temperatures
t1_timeseries = engineOut.simlog.s1P1T1.Pressure_Temperature_Sensor_G.T.series.values;
t1 = t1_timeseries(end);

t2_timeseries = engineOut.simlog.s2P2T2.Pressure_Temperature_Sensor_G.T.series.values;
t2 = t2_timeseries(end);

t3_timeseries = engineOut.simlog.s3P3T3.Pressure_Temperature_Sensor_G.T.series.values;
t3 = t3_timeseries(end);

t4_timeseries = engineOut.simlog.s4P4T4.Pressure_Temperature_Sensor_G.T.series.values;
t4 = t4_timeseries(end);

t = [t1, t2, t3, t4];

% Visulaize Brayton cycle
figure
plot(s,t)
xlabel("Entropy J/(kgK)")
ylabel("Temperature (K)")
