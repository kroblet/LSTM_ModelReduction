% initial conditions
fixedStepSize = 0.1; % s
sampleTime = 0.1; % s
height = 0; % m
initConditions.rho = 1.2250; 
g= 9.81; % m/s2 
Qin = [2000 2000 3100 3100 3600 3600 4100 4100 4600 4600 5100 5100 5100 5100]; % kW
Qin_time = [0 66.6667 83.3333 150.0000 166.6667 233.3333 250.0000 316.6667 333.3333 400.0000 416.6667 483.3333 500.0000 566.6667]; % s


% inlet - environment
inlet.crossArea = 0.08;

% exhaust - environment
exhaust.crossArea = inlet.crossArea;

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
    (95891/compressor.refPressure); % kg/s
compressor.rpmDesign = 44700; % rpm
compressor.rpmDesignCorrected = compressor.rpmDesign/sqrt((289.44+717.99)/2/compressor.refTemperature);
compressor.mechanicalEff = 0.99; % mechanical efficiency
compressor.inletArea = inlet.crossArea; % inlet area m2
compressor.outletArea = compressor.inletArea/compressor.areaRatio; % outlet area m2
compressor.isentropicEffMax = 0.887; % maximum isentropic efficiency
compressor.isentropicEffMin = 0.5; % minimum isentropic efficiency
compressor.massFlowMaxEff = 3; % maximum mass flow in max efficiency kg/s

% burner
burner.length = 0.5; % m
burner.crossArea = compressor.outletArea; % m2
burner.diameter = 2*sqrt(burner.crossArea/pi); % m
burner.hydrDiameter = burner.diameter; % cylindrical, same as diameter
burner.initTemp = 1479; % K
burner.initPress = 1591629; % Pa
burner.eff = 0.9850; % combustion efficiency
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
    ((burner.initPress+371631)/2/turbine.refPressure); % kg/s

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
    ((371631+109636)/2/turbine.refPressure); % kg/s

% nozzle
nozzle.PR = 1.0142; % nozzle pressure ratio
nozzle.massFlowDesign = turbineFPT.massFlowDesign; % kg/s
nozzle.isentropicEfficiency = 0.9;
nozzle.refPressure = compressor.refPressure; % MPa
nozzle.refTemperature = compressor.refTemperature; % K
nozzle.inletArea = turbineFPT.outletArea; % inlet area m2
nozzle.outletArea = exhaust.crossArea; % outlet area m2
nozzle.massFlowCorrected = nozzle.massFlowDesign*sqrt(884.09/turbine.refTemperature)/...
    ((109636+108105)/2/turbine.refPressure); % kg/s
nozzle.damping = 1e-3; % kg*m^2


rotorDamping = 1e-3; % kg*m^2

% shaft GGT
shaft.inertia = 1e-4; % kg*m2
shaft.damping = 1e-3; % N*m*s*rad 
shaftDamping = 1e-5; % N*m*s*rad 
initConditions.rpm = 44700; % initial shaft speed at design point

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
rotor.rpm = 257; % RPM
rotor.area = pi*rotor.diameter^2/4; % m^2

% chassis
chassis.mass = 6000; % kg

% LSTM rom
load meanTrain.mat
load stdTrain.mat
rom.mean.h = meanTrain.Altitude;
rom.mean.Qin = meanTrain.Qin;
rom.mean.AirMassFlow = meanTrain.AirMassFlow;
rom.mean.fptRPM = meanTrain.("FTP RPM");
rom.mean.ggtRPM = meanTrain.("GGT RPM");
rom.mean.power =  meanTrain.Power;
rom.mean.T3 = meanTrain.T3;
rom.mean.p2 = meanTrain.P2;

rom.std.h = stdTrain.Altitude;
rom.std.Qin = stdTrain.Qin;
rom.std.AirMassFlow = stdTrain.AirMassFlow;
rom.std.fptRPM = stdTrain.("FTP RPM");
rom.std.ggtRPM = stdTrain.("GGT RPM");
rom.std.power = stdTrain.Power;
rom.std.T3 = stdTrain.T3;
rom.std.p2 = stdTrain.P2;

rom.init.timeColdStart = 20;
rom.init.h = -0.883502305729634;
rom.init.Qin = -1.756277954474450;
rom.init.AirMassFlow = -1.822791999032473;
rom.init.fptRPM = -1.889570395699298;
rom.init.ggtRPM = -1.937268901463669;
rom.init.power = -1.651109114035745;
rom.init.T3 = -1.807116699384182;
rom.init.p2 = -1.831956246134835;


