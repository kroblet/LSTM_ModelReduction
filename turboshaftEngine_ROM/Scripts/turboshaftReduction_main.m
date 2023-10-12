%% Initialization
proj = matlab.project.rootProject; % project root
scenarioDir = fullfile(proj.RootFolder, 'BraytonGasTurbSimplified_LSTMReduction', 'SimulationInput');
simOutDir = fullfile(proj.RootFolder, 'BraytonGasTurbSimplified_LSTMReduction', 'SimulationOutput');
modelName = 'turboshaftEngine_toReduce';
simStopTimeLong = 1000; % Simulation stop time in s

train = true; % enable or disable network trainning

%% Wavelet analysis
load_system(modelName)

outSim = sim(modelName)

sensors{1} = outSim.simlog.turboShaft.s1_P1_T1;
sensors{2} = outSim.simlog.turboShaft.s2_P2_T2;
sensors{3} = outSim.simlog.turboShaft.s3_P3_T3;
sensors{4} = outSim.simlog.turboShaft.s4_P4_T4;
sensors{5} = outSim.simlog.turboShaft.s5_P5_T5;


