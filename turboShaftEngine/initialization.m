% initial conditions
initConditions.Temperature = 288.15; % K
initConditions.Pressure = 0.101325; % MPa
initConditions.rpm = 12000; % initial shaft speed

% burner
burner.length = 0.5; % m
burner.diameter = 2e-2; % m
burner.hydrDiameter = burner.diameter; % cylindrical, same as diameter
burner.crossArea = pi*burner.diameter^2/4; % m2

% compressor
compressor.rpmDesign = 10000; % rpm
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
compressor.inletArea = 0.01; % inlet area m2
compressor.outletArea = burner.crossArea; % outlet area m2

% turbine
turbine.PR = 4; % pressure ratio
turbine.massFlowDesign = 1; % kg/s
turbine.isentropicEfficiency = 0.8; % constant isentropic efficiency
turbine.refPressure = initConditions.Pressure; % MPa
turbine.refTemperature = initConditions.Temperature; % K
turbine.mechanicalEff = 0.9; % mechanical efficiency
turbine.inletArea = burner.crossArea; % inlet area m2
turbine.outletArea = 0.01; % outlet area m2

% inlet - environment
inlet.crossArea = compressor.inletArea;


% exhaust - environment
exhaust.crossArea = turbine.outletArea;

% shaft
shaft.inertia = 0.01 ; % kg*m2

 





