


% initial conditions
height = 0;
[T,a,P,rho,nu] = atmosisa(height);

initConditions.Temperature = T; % K
initConditions.Pressure = P; % Pa
initConditions.rho = rho; % air density kg/m3
initConditions.nu = nu; % kinematic viscocity m2/s
initConditions.SounSpeed = a; % sound speed

clear T a P rho nu;


initConditions.rpm = 20000; % initial shaft speed

% inlet - environment
inlet.crossArea = 0.3;

% exhaust - environment
exhaust.crossArea = 1*inlet.crossArea;

% compressor
compressor.areaRatio = 1; % fraction between inlet and outlet area
compressor.rpmDesign = 10000; % rpm
compressor.PR = 17.5;  % pressure ratio
compressor.massFlowDesign = 4; % kg/s
compressor.PRMaxEff = 4.5; % maximum PR in max efficiency 
compressor.isentropicEfficiency = 0.85; % constant isentropic efficiency
compressor.refPressure = initConditions.Pressure; % MPa
compressor.refTemperature = initConditions.Temperature; % K
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
burner.initTemp = 900; % K

% turbine GGT
turbine.areaRatio = 2; % fraction between inlet and outlet area
turbine.PR = 4; % pressure ratio
turbine.massFlowDesign = 4; % kg/s
turbine.isentropicEfficiency = 0.85; % constant isentropic efficiency
turbine.inletArea = burner.crossArea; % inlet area m2
turbine.outletArea = turbine.areaRatio*turbine.inletArea; % outlet area m2

turbine.refPressure = initConditions.Pressure; % MPa
turbine.refTemperature = initConditions.Temperature; % K
turbine.mechanicalEff = 0.99; % mechanical efficiency


% turbine FPT
turbineFPT.PR = 3.4; % pressure ratio
turbineFPT.massFlowDesign = 4; % kg/s
turbineFPT.isentropicEfficiency = 0.85; % constant isentropic efficiency
turbineFPT.refPressure = initConditions.Pressure; % MPa
turbineFPT.refTemperature = initConditions.Temperature; % K
turbineFPT.mechanicalEff = 0.99; % mechanical efficiency
turbineFPT.inletArea = turbine.outletArea; % inlet area m2
turbineFPT.outletArea = exhaust.crossArea; % outlet area m2

% shaft
shaft.inertia = 1e-4; % kg*m2
shaft.damping = 1e-5; % N*m*s*rad 
 





