%% Initialization
proj = matlab.project.rootProject; % project root
trainDir = fullfile(proj.RootFolder, 'simplified_LSTMRedcuction', 'SimulationInput');
modelName = 'simpleModel';
simStopTime = 2; % Simulation stop time in s
train = false; % enable oor disable trainning procedure

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
    sequenceInputLayer(3,Normalization="rescale-zero-one")
    fullyConnectedLayer(200)
    reluLayer
    % lstmLayer(200)
    lstmLayer(200)
    reluLayer
    fullyConnectedLayer(2)
    regressionLayer];

%% Partition trainning data
trainPercentage = 0.8; % the percentage of the data that they will be used for training
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

%% Train LSTM Network
options = trainingOptions("adam", ...
    MaxEpochs=10000, ...
    GradientThreshold=1, ...
    InitialLearnRate=5e-3, ...
    LearnRateSchedule="piecewise", ...
    LearnRateDropPeriod=1e4, ...
    LearnRateDropFactor=0.6, ...
    Verbose=0, ...
    Plots="training-progress");

if train
net = trainNetwork(XTrain,TTrain,layers,options);
end
%% Test LSTM Network
for n = 1:numel(dataTest)
    X = dataTest{n};
    XTest{n} = X(:,1:end-1);
    TTest{n} = X(2:3,2:end);
end

results = predict(net,XTest,SequencePaddingDirection="left");

%% Inspect NN response
inspectPredData(results)
