%% Initialization
proj = matlab.project.rootProject; % project root
trainDir = fullfile(proj.RootFolder, 'simplified_LSTMRedcuction', 'SimulationInput');
modelName = 'simpleModel';
simStopTime = 5; % Simulation stop time in s
train = true; % enable or disable network trainning

%% Generate simulation scenarios
trainTqs = [0.2:0.1:1.2];
nameList = {};
numTqCases = length(trainTqs);

for ix=1:numTqCases
    nameList{ix} = append('tqInp_',num2str(ix));
    generateDatasetTq(trainTqs(ix), nameList{ix}, trainDir, simStopTime)
end

% filelist of trainning MAT files
aux = dir(trainDir); 
fileList={};
ik = 1;
for ix=1:length(aux)
    if contains(aux(ix).name, '.mat')
        fileList{ik} = aux(ix).name;
        ik = ik+1;
    end
end

%% Generate Simulation Inputs
for ix=1:length(fileList)
    simIn(ix) = Simulink.SimulationInput(modelName);
    simIn(ix) = simIn(ix).setBlockParameter([modelName,'/Signal Editor'], 'Filename', fileList{ix});
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
    lstmLayer(120)
    % lstmLayer(200)
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
