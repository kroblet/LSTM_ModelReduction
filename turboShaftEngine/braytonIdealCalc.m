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