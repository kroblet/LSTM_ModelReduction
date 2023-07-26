%% Initialization
proj = matlab.project.rootProject; % project root
trainDir = fullfile(proj.RootFolder, 'simplified_LSTMRedcuction', 'SimulationInput');
modelName = 'simpleModel';
simStopTime = 2; % Simulation stop time in s

%% Generate simulation inputs
trainTqs = [0.2:0.1:1.5];
nameList = {};
numCases = length(trainTqs);

for ix=1:numCases
    nameList{ix} = append('tqInp_',num2str(ix));
    generateDatasetTq(trainTqs(ix), nameList{ix}, trainDir)
    simIn(ix) = Simulink.SimulationInput(modelName);
    dataFile = [nameList{ix} '.mat'];
    simIn(ix) = simIn(ix).setBlockParameter([modelName,'/Signal Editor'], 'Filename', dataFile);
    simIn(ix) = simIn(ix).setModelParameter('StopTime', num2str(simStopTime));    
end

%% Simulate
out = parsim(simIn);

%% Configure trainning data format
resampleTimeStep = 0.01;
trainData = trainningDataConv(out,resampleTimeStep);

%% Inspect resampled data
inspectTrainData(trainData)

%% LSTM Architecture

layers = [
    sequenceInputLayer(1)
    lstmLayer(128)
    fullyConnectedLayer(1)
    regressionLayer];


