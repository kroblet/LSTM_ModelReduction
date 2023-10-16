% initial conditions
% height = 465;
fixedStepSize = 0.1;
height = 0;
g= 9.81; % m/s2 
[T,a,P,rho,nu] = atmosisa(height);

initConditions.Temperature = T; % K
initConditions.Pressure = P; % Pa
initConditions.rho = rho; % air density kg/m3
initConditions.nu = nu; % kinematic viscocity m2/s
initConditions.SounSpeed = a; % sound speed

clear T a P rho nu;

initConditions.rpm = 44700; % initial shaft speed

% inlet - environment
inlet.crossArea = 0.08;

% exhaust - environment
exhaust.crossArea = 1*inlet.crossArea;

% Global specs
coreArea = 0.3;
coreDiameter = 2*sqrt(coreArea/pi); % m
coreHydrDiameter = coreDiameter; % cylindrical, same as diameter

% compressor
compressor.areaRatio = 1; % fraction between inlet and outlet area
compressor.PR = 17.5;  % pressure ratio
compressor.PRMaxEff = 4.5; % maximum PR in max efficiency 
compressor.isentropicEfficiency = 0.8210; % constant isentropic efficiency
compressor.refPressure = 101325; % Pa
compressor.refTemperature = 288.15; % K
compressor.massFlowDesign = 4.6122; % kg/s
compressor.massFlowCorrected = compressor.massFlowDesign*sqrt((289.44+717.99)/2/compressor.refTemperature)/...
    (95891/compressor.refPressure);
compressor.rpmDesign = 44700; % rpm
compressor.rpmDesignCorrected = compressor.rpmDesign/sqrt((289.44+717.99)/2/compressor.refTemperature);


compressor.mechanicalEff = 0.99; % mechanical efficiency
compressor.inletArea = inlet.crossArea; % inlet area m2
compressor.outletArea = compressor.inletArea/compressor.areaRatio; % outlet area m2

compressor.isentropicEffMax = 0.887; % maximum isentropic efficiency
compressor.isentropicEffMin = 0.5; % minimum isentropic efficiency
compressor.massFlowMaxEff = 3; % maximum mass flow in max efficiency kg/s

% compressor.outletArea = 0.005; % outlet area m2

% burner
burner.length = 0.5; % m
burner.crossArea = compressor.outletArea; % m2
burner.diameter = 2*sqrt(burner.crossArea/pi); % m
burner.hydrDiameter = burner.diameter; % cylindrical, same as diameter
burner.initTemp = 1479; % K
burner.initPress = 1591629; % Pa
burner.eff = 0.9850; % combustion efficiency
burner.pressureloss = 0.04*initConditions.Pressure;
burner.HHV = 43100; % Higher heating value kJ/kg
burner.mfDesign = 0.1004; % design fuel flow kg/s
burner.heatDesign = burner.eff*burner.mfDesign*burner.HHV; % heat required for the design point

% turbine GGT
turbine.areaRatio = 1; % fraction between inlet and outlet area
turbine.PR = 4; % pressure ratio
turbine.isentropicEfficiency = 0.85; % constant isentropic efficiency
turbine.inletArea = burner.crossArea; % inlet area m2
turbine.outletArea = turbine.areaRatio*turbine.inletArea; % outlet area m2
turbine.refPressure = compressor.refPressure; % MPa
turbine.refTemperature = compressor.refTemperature; % K
turbine.mechanicalEff = 0.99; % mechanical efficiency
turbine.massFlowDesign = 1.025*compressor.massFlowDesign; % kg/s
turbine.massFlowCorrected = compressor.massFlowDesign*sqrt((burner.initTemp+1125.08)/2/turbine.refTemperature)/...
    ((burner.initPress+371631)/2/turbine.refPressure);

% turbine FPT
turbineFPT.PR = 4.3750; % pressure ratio
turbineFPT.isentropicEfficiency = 0.85; % constant isentropic efficiency
turbineFPT.refPressure = compressor.refPressure; % MPa
turbineFPT.refTemperature = compressor.refTemperature; % K
turbineFPT.mechanicalEff = 0.99; % mechanical efficiency
turbineFPT.inletArea = turbine.outletArea; % inlet area m2
turbineFPT.outletArea = turbineFPT.inletArea; % outlet area m2
turbineFPT.RPMDesign = 20900; % design RPM for FTP 
turbineFPT.RotorDamping = 10; % kg*m^2
turbineFPT.massFlowDesign = 1.025*compressor.massFlowDesign;
turbineFPT.massFlowCorrected = turbineFPT.massFlowDesign*sqrt((884.09+1125.08)/2/turbine.refTemperature)/...
    ((371631+109636)/2/turbine.refPressure);

% nozzle
nozzle.PR = 1.0142; % nozzle pressure ratio
nozzle.massFlowDesign = turbineFPT.massFlowDesign; % kg/s
nozzle.isentropicEfficiency = 0.9;
nozzle.refPressure = compressor.refPressure; % MPa
nozzle.refTemperature = compressor.refTemperature; % K
nozzle.inletArea = turbineFPT.outletArea; % inlet area m2
nozzle.outletArea = exhaust.crossArea; % outlet area m2
nozzle.massFlowCorrected = nozzle.massFlowDesign*sqrt(884.09/turbine.refTemperature)/...
    ((109636+108105)/2/turbine.refPressure);
nozzle.damping = 1e-3; % kg*m^2


rotorDamping = 1e-3; % kg*m^2

% shaft GGT
shaft.inertia = 1e-4; % kg*m2
shaft.damping = 1e-3; % N*m*s*rad 
shaftDamping = 1e-5; % N*m*s*rad 

% shaft FTP
shaftFTP.GearRatio = 80.5;

% rotor
rotor.mass = 907 ; % kg rotor mass estimate of UH-60A
rotor.diameter = 8.178; % m
rotor.bladeNum = 4; % number of rotor blades
rotor.inertia2blades = ...
    2*rotor.mass/rotor.bladeNum*rotor.diameter^2/12;
rotor.inertia = rotor.bladeNum/2 * rotor.inertia2blades;
rotor.powerCoeff = 0.43; % rotor's power coefficient
rotor.thrustCoeff = 0.8; % rotor's torque coefficient
rotor.rpm = 257;
rotor.area = pi*rotor.diameter^2/4;

% chassis
chassis.mass = 6000; % kg

% LSTM rom
rom.mean.h = 0.0025e6;
rom.mean.Qin = 0.0041e6;
rom.mean.T3 = 1.3422e+03;
rom.mean.AirMassFlow = 5.0812;
rom.mean.fptRPM = 1.9787e+04;
rom.mean.ggtRPM = 3.2837e+04;
rom.mean.power = 1.4191e+03;
rom.mean.p2 = 1.1921e+06;

rom.std.h = 1.5811e+03;
rom.std.Qin = 1.3988e+03;
rom.std.T3 = 163.9369;
rom.std.AirMassFlow = 1.0090;
rom.std.fptRPM = 3.0767e+03;
rom.std.ggtRPM = 1.3064e+03;
rom.std.power = 600.6312;
rom.std.p2 = 2.9221e+05;

rom.init.h = (0-rom.mean.h)/rom.std.h;
rom.init.Qin = (2e3-rom.mean.Qin)/rom.std.Qin;
rom.init.T3 = (1.0293e+03-rom.mean.T3)/rom.std.T3;
rom.init.AirMassFlow = (3.9257-rom.mean.AirMassFlow)/rom.std.AirMassFlow;
rom.init.fptRPM = (1.4053e+04-rom.mean.fptRPM)/rom.std.fptRPM;
rom.init.ggtRPM = (3.0467e+04-rom.mean.ggtRPM)/rom.std.ggtRPM;
rom.init.power = (474.5508-rom.mean.power)/rom.std.power;
rom.init.p2 = (8.0535e+05-rom.mean.p2)/rom.std.p2;


