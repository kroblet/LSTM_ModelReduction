% initial conditions
initConditions.Temperature = 288.15; % K
initConditions.Pressure = 0.101325; % MPa
initConditions.rpm = 7000; % initial shaft speed

% inlet - environment
inlet.crossArea = 0.006;

% exhaust - environment
exhaust.crossArea = 0.005;

% compressor
compressor.areaRatio = 2; % fraction between inlet and outlet area
compressor.rpmDesign = 9000; % rpm
compressor.PR = 4;  % pressure ratio
compressor.massFlowDesign = 1; % kg/s
compressor.isentropicEffMax = 0.887; % maximum isentropic efficiency
compressor.isentropicEffMin = 0.5; % minimum isentropic efficiency
compressor.massFlowMaxEff = 3; % maximum mass flow in max efficiency kg/s
compressor.PRMaxEff = 4.5; % maximum PR in max efficiency 
compressor.isentropicEfficiency = 0.8; % constant isentropic efficiency
compressor.refPressure = initConditions.Pressure; % MPa
compressor.refTemperature = initConditions.Temperature; % K
compressor.mechanicalEff = 0.9; % mechanical efficiency
compressor.inletArea = inlet.crossArea; % inlet area m2
compressor.outletArea = compressor.inletArea/compressor.areaRatio; % outlet area m2
% compressor.outletArea = 0.005; % outlet area m2

% burner
burner.length = 0.5; % m
burner.crossArea = compressor.outletArea; % m2
burner.diameter = 2*sqrt(burner.crossArea/pi); % m
burner.hydrDiameter = burner.diameter; % cylindrical, same as diameter

% turbine
turbine.PR = 3; % pressure ratio
turbine.massFlowDesign = 1; % kg/s
turbine.isentropicEfficiency = 0.8; % constant isentropic efficiency
turbine.refPressure = initConditions.Pressure; % MPa
turbine.refTemperature = initConditions.Temperature; % K
turbine.mechanicalEff = 0.9; % mechanical efficiency
turbine.inletArea = burner.crossArea; % inlet area m2
turbine.outletArea = exhaust.crossArea; % outlet area m2

% shaft
shaft.inertia = 1e-4; % kg*m2
shaft.damping = 1e-5; % N*m*s*rad 
 





