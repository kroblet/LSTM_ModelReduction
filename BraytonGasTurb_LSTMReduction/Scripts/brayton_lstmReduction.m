%% Initialization
proj = matlab.project.rootProject; % project root
scenarioDir = fullfile(proj.RootFolder, 'BraytonGasTurb_LSTMReduction', 'SimulationInput');
modelName = 'brayton_cycle_lstm';
simStopTime = 1000; % Simulation stop time in s
train = false; % enable or disable network trainning

%% Generate Simulation Scenarios
shaftSpeedStates = [4e3:1e3:1.2e4];
generateShaftSpeedInputs(scenarioDir, shaftSpeedStates, simStopTime)

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
resampleTimeStep = 0.01;
trainData = prepareTrainingData(out,resampleTimeStep);

% %% Inspect resampled data
% inspectTrainData(trainData)

%% LSTM Architecture
layers = [
    sequenceInputLayer(16,Normalization="rescale-zero-one")
    fullyConnectedLayer(200)
    reluLayer
    lstmLayer(120)
    % lstmLayer(200)
    reluLayer
    fullyConnectedLayer(16)
    regressionLayer];

%% Partition trainning data
trainPercentage = 1; % the percentage of the data that they will be used for training
                       % the rest will be used for test

[dataTrain, dataTest] = trainPartitioning(trainData, trainPercentage);

%% Preprocess
XTrain = {};
TTrain = {};

for n = 1:numel(dataTrain)
    X = dataTrain{n};
    XTrain{n} = X(:,1:end-1);
    TTrain{n} = X(2:3,2:end);
end

%% Test LSTM Network
for n = 1:numel(dataTest)
    X = dataTest{n};
    XTest{n} = X(:,1:end-1);
    TTest{n} = X(2:3,2:end);
end

%% Train LSTM Network
options = trainingOptions("adam", ...
    MaxEpochs=10000, ...
    GradientThreshold=1, ...
    InitialLearnRate=5e-3, ...
    LearnRateSchedule="piecewise", ...
    LearnRateDropPeriod=1e4, ...
    LearnRateDropFactor=0.6, ...
    Verbose=0, ...
    Plots="training-progress",...
    ValidationData={XTest,TTest});

if train
    net = trainNetwork(XTrain,TTrain,layers,options);
end

%% Check response

results = predict(net,XTest,SequencePaddingDirection="left");
save('lstmNet', 'net')
%% Inspect NN response
inspectPredData(results)
