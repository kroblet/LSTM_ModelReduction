%% Initialization
proj = matlab.project.rootProject; % project root
scenarioDir = fullfile(proj.RootFolder, 'BraytonGasTurbSimplified_LSTMReduction', 'SimulationInput');
simOutDir = fullfile(proj.RootFolder, 'BraytonGasTurbSimplified_LSTMReduction', 'SimulationOutput');
modelName = 'turboShaft_Harness1';
simStopTimeLong = 1000; % Simulation stop time in s

train = true; % enable or disable network trainning

%% Scenarios



