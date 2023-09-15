close all; clc
%% Givens
gamma = 1.4;
gam_c = 1.4; % for temps through compressor,combustor
gam_t = 1.33; % for temps after the combuster -> turbine
c = 1005; % specific heat
cpc = 1004; % for temps in the compressor,combustor
cpt = 1156; % for temps in the turbine
hp2W = 0.7457*1000; % conversion from hp to W
lb2kg = 0.453592; % conversion from lb to kg
%T5=T9 == T0 (should be ambient for maximum)
%p5=p9=p0
%M = 0
% Ambient Values
M0 = 0; % Mach
[T0,a0,P0,rho0] = atmosisa(0); % Standard Atmospher [K,m/s,kg/m3,Pa]
mdot = 26*lb2kg; % Air mass flow rate [kg/s]
hpr = 42.8e6; % Fuel Heating value [J]
Tt4 = 1100+273.15; % Turbine Entry Temperatureb[K]
P = 4230*hp2W; % Power extracted to turboshaft
Pi_c =12;
%-------------------Efficiencies-------------------------------------------
ec = .92; % Polytropic Efficiency of Compressor
et = .92; % Polytropic Efficiency of Turbine
Eta_b = .96; % Efficiency of burner (combustor)
eta_c = .85; %power conversion losses, 1 = no loss
%%
tau_r = 1+.5*(gamma-1)*M0^2; % Tt0/T0 : stagnation to static Temp Ratio
tau_c = Pi_c^((gamma-1)/gamma); % Tt3/T2 : compressor
tau_lam = Tt4/T0; % ht4/ht0 = cpt*Tt4/cpc*T0
tau_tH = 1-(tau_r/tau_lam)*(tau_c-1);
%tau_tL, tau_t for a turboshaft
tau_tL = 1-(1/(tau_lam*tau_tH))*(P/(mdot*c*T0));
tau_t = tau_tH*tau_tL;
%tau_tL, tau_t for a turboprop
%{
tau_t = 1/(tau_r*tau_c)+(gamma-1)*M0^2/(2*tau_lam*eta_c^2);
tau_tL = tau_t/tau_tH;
%}
Sp = (a0*M0)^2*(1/eta_c-1) ...
     +cpc*T0*tau_lam*tau_tH*(1-tau_tL)*eta_c;
f = cpc*T0*(tau_lam-tau_r*tau_c)/hpr;
Spfc = f/Sp *3600*1000
eta_0 = Sp/(c*T0*(tau_lam-tau_r*tau_c));
eta_th = 1-(1/(tau_r*tau_c))
eta_P = eta_0/eta_th;
%% real cycle
tau_r = 1+.5*(gam_c-1)*M0^2; % Tt0/T0 : stagnation to static Temp Ratio
tau_c = Pi_c^((gam_c-1)/(ec*gam_c)); % Tt3/T2 : compressor
tau_lam = cpt*Tt4/(cpc*T0);
tau_tH = 1-tau_r/tau_lam*(tau_c-1);
%tau_tL, tau_t for a turboshaft
tau_tL = 1-(1/(tau_lam*tau_tH))*(P/(mdot*cpt*T0));
tau_t = tau_tH*tau_tL;
%tau_tL, tau_t for a turboprop
%{
tau_t = 1/(tau_r*tau_c)+(gamma-1)*M0^2/(2*tau_lam*eta_c^2);
tau_tL = tau_t/tau_tH;
%}
Sp = (a0*M0)^2*(1/eta_c-1) ...
 +cpc*T0*tau_lam*tau_tH*(1-tau_tL)*eta_c;
f = cpc*T0/(Eta_b*hpr)*(tau_lam-tau_r*tau_c);
Spfc_real = f/Sp *3600*1000
eta_0 = Sp/(gam_c*T0*(tau_lam-tau_r*tau_c));
eta_th = 1-(1/(tau_r*tau_c))
eta_P = eta_0/eta_th;