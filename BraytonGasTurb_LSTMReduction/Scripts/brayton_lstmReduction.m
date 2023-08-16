%% Initialization
proj = matlab.project.rootProject; % project root
scenarioDir = fullfile(proj.RootFolder, 'BraytonGasTurb_LSTMReduction', 'SimulationInput');
modelName = 'brayton_cycle_lstm';
simStopTime = 800; % Simulation stop time in s
train = false; % enable or disable network trainning

%% Generate Simulation Scenarios
shaftSpeedStates1 = [4e3:1e3:1.1e4];
shaftSpeedStates2 = [4.5e3:0.5e3:1.1e4];
shaftSpeedStates3 = [3.8e3:0.5e3:1.1e4];
shaftSpeedStates4 = [3.85e3:2e3:1.1e4];

generateShaftSpeedInputs(scenarioDir, shaftSpeedStates1, simStopTime, 'all');
generateShaftSpeedInputs(scenarioDir, shaftSpeedStates2, simStopTime, 'all');
generateShaftSpeedInputs(scenarioDir, shaftSpeedStates3, simStopTime, 'stairOnly');
generateShaftSpeedInputs(scenarioDir, shaftSpeedStates4, simStopTime, 'stairOnly');


%% Generate Simulink Simulation Inputs
fileList = listSimInpFiles(scenarioDir);
numCases = length(fileList);

for ix=1:numCases
    simIn(ix) = Simulink.SimulationInput(modelName);
    simIn(ix) = simIn(ix).setBlockParameter([modelName,'/System Inputs/Varied Shaft Speed','/Signal Editor'], 'Filename', fileList{ix});
    simIn(ix) = simIn(ix).setModelParameter('StopTime', num2str(simStopTime));    
end

%% Simulate
out = parsim(simIn);

%% Configure trainning data format
resampleTimeStep = 0.1;
trainData = prepareTrainingData(out,resampleTimeStep);

%% Inspect resampled data
% inspectTrainData(trainData)

%% LSTM Architecture
layers = [
    sequenceInputLayer(7,Normalization="rescale-zero-one")
    fullyConnectedLayer(200)
    reluLayer
    lstmLayer(200)
    % lstmLayer(200)
    reluLayer
    dropoutLayer
    fullyConnectedLayer(3)
    regressionLayer];

%% Partition trainning data
trainPercentage = 0.9; % the percentage of the data that they will be used for training
                       % the rest will be used for test

[dataTrain, dataTest] = trainPartitioning(trainData, trainPercentage);

%% Preprocess
XTrain = {};
TTrain = {};

for n = 1:numel(dataTrain)
    X = dataTrain{n};
    XTrain{n} = X(:,1:end-1);
    TTrain{n} = X(5:end,2:end);
end

%% Test LSTM Network
for n = 1:numel(dataTest)
    X = dataTest{n};
    XTest{n} = X(:,1:end-1);
    TTest{n} = X(5:end,2:end);
end

%% Train LSTM Network
options = trainingOptions("adam", ...
    MaxEpochs=10000, ...
    GradientThreshold=1, ...
    InitialLearnRate=1e-1, ...
    LearnRateSchedule="piecewise", ...
    LearnRateDropPeriod=1000, ...
    LearnRateDropFactor=0.6, ...
    Verbose=0, ...
    Plots="training-progress",...
    ValidationData={XTest,TTest});

if train
    net = trainNetwork(XTrain,TTrain,layers,options);
end

%% Check response

results = predict(net,XTest,SequencePaddingDirection="left");
save('braytonLSTMNet', 'net')
%% Inspect NN response
inspectPredData(results)
