%% Load model
modelName = 'brayton_cycle_lstm_simplified';

load_system(modelName)

simInTest = Simulink.SimulationInput(modelName);
outSim = sim(simInTest)


%% resample timestep
resampleTimeStep = 0.1; % (s)

scaleFactor = 1; % rescale the date
trainData = prepareTrainingData(out, resampleTimeStep, scaleFactor,1); 

%% Singnals of interest

sigNames = {'RPMref', 'Phi', 'RPM', 'Power', 'T2', "T3", "P3"};


for iy =1 :size(trainData{1},1)
    figure()
    
    cwt(trainData{1}(iy,:),1/resampleTimeStep)
    title(sigNames{iy})
end

