%% Initialization
proj = matlab.project.rootProject; % project root
scenarioDir = fullfile(proj.RootFolder, 'BraytonGasTurb_LSTMReduction', 'SimulationInput');
modelName = 'brayton_cycle_lstm';
simStopTime = 300; % Simulation stop time in s
train = false; % enable or disable network trainning

%% Generate Simulation Scenarios
shaftSpeedStates1 = [4e3:1e3:1.1e4];
shaftSpeedStates2 = [4e3:0.5e3:6.2e3];
shaftSpeedStates3 = [3.8e3:0.5e3:7.1e3];
shaftSpeedStates4 = [7e3:0.5e3:1.1e4];
shaftSpeedStates5 = [4.1:1e3:11.1e3];

generateShaftSpeedInputs(scenarioDir, shaftSpeedStates1, 1000, 'stairOnly');
generateShaftSpeedInputs(scenarioDir, shaftSpeedStates2, simStopTime, 'all');
generateShaftSpeedInputs(scenarioDir, shaftSpeedStates3, simStopTime, 'all');
generateShaftSpeedInputs(scenarioDir, shaftSpeedStates4, simStopTime, 'all');
generateShaftSpeedInputs(scenarioDir, shaftSpeedStates5, 1000, 'stairOnly');


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

%% Clean simulation outputs
idx = 1;
aux = length(out);
while idx <= aux
    if ~isempty(out(ix).ErrorMessage)
        out(idx) = [];
    end
    idx=idx+1;
    aux = length(out);
end

%% Configure trainning data format
resampleTimeStep = 0.1;
trainData = prepareTrainingData(out,resampleTimeStep);

%% Inspect resampled data
inspectTrainData(trainData)

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
    InitialLearnRate=5e-2, ...
    LearnRateSchedule="piecewise", ...
    LearnRateDropPeriod=1e4, ...
    LearnRateDropFactor=0.5, ...
    L2Regularization = 0.0001, ...
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
