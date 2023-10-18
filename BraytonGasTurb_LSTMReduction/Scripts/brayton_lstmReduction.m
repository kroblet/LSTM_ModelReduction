%% Initialization
proj = matlab.project.rootProject; % project root
scenarioDir = fullfile(proj.RootFolder, 'BraytonGasTurb_LSTMReduction', 'SimulationInput');
modelName = 'brayton_cycle_lstm';
simStopTimeShort = 300; % Simulation stop time in s
simStopTimeLong = 1000; % Simulation stop time in s

train = false; % enable or disable network trainning

%% Generate Simulation Scenarios
shaftSpeedStates = {{[4e3:1e3:1.1e4],simStopTimeLong},
                    {[4e3:0.5e3:6.2e3],simStopTimeShort},
                    {[3.8e3:0.5e3:7.1e3], simStopTimeShort},
                    {[7e3:0.5e3:1.1e4], simStopTimeShort},
                    {[4.1e3:1e3:11.1e3], simStopTimeLong}};

for ix=1:numel(shaftSpeedStates)
    generateShaftSpeedInputs(scenarioDir, shaftSpeedStates{ix}{1},...
    shaftSpeedStates{ix}{2}, 'all')
end



%% Generate Simulink Simulation Inputs
clearvars simIn
fileList = listSimInpFiles(scenarioDir);
numCases = length(fileList);
for ix=1:numCases
    fileName = split(fileList{ix},'.');
    aux = split(fileName{1},'_');
    simStopTime = aux{end};
    simIn(ix) = Simulink.SimulationInput(modelName);
    simIn(ix) = simIn(ix).setBlockParameter([modelName,'/System Inputs/Varied Shaft Speed','/Signal Editor'], 'Filename', fileList{ix});
    simIn(ix) = simIn(ix).setModelParameter('StopTime', simStopTime);
    % Initialize compressor's RPM with respect to the Simulation scenarios

    rpm0 = aux{2};
    simIn(ix) = simIn(ix).setVariable('rpm0', str2num(rpm0), ...
        'Workspace', modelName);  
end

%% Simulate
out = parsim(simIn);

%% Clean simulation outputs
idx = 1;
aux = length(out);
while idx <= aux
    if ~isempty(out(idx).ErrorMessage)
        out(idx) = [];
    else
        idx=idx+1;
    end
    aux = length(out);
end

%% Configure trainning data format
resampleTimeStep = 0.1;
trainData = prepareTrainingData(out,resampleTimeStep);

%% Inspect resampled data
signalNames = {'APU_w', 'Phi','VN', 'VN_APU', 'SM', 'T3', 'N'};
visualizeTrainData(trainData(:),signalNames )

%% LSTM Architecture
layers = [
    sequenceInputLayer(5,Normalization="rescale-zero-one")
    fullyConnectedLayer(200)
    reluLayer
    lstmLayer(200)
    % lstmLayer(100)
    reluLayer
    dropoutLayer
    fullyConnectedLayer(3)
    regressionLayer];

%% Partition trainning data
trainPercentage = 0.8; % the percentage of the data that they will be used for training
                       % the rest will be used for test

[dataTrain, dataTest] = trainPartitioning(trainData, trainPercentage);

%% Preprocess
[XTrain, TTrain] = preprocessTrainData(dataTrain, 3);
[XTest, TTest] = preprocessTrainData(dataTest, 3);

%% Train LSTM Network
options = trainingOptions("sgdm", ...
    MaxEpochs=10000, ...
    GradientThreshold=1, ...
    MiniBatchSize=64, ...
    InitialLearnRate=0.5e-1, ...
    LearnRateSchedule="piecewise", ...
    LearnRateDropPeriod=1.5e3, ...
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
% inspectPredData(results)
save('braytonLSTMNetThermo', 'net')
%% Inspect NN response
% inspectPredData(results)

%% Train LSTM Network for mechanical part

trainDataMech = prepareTrainingData(out,resampleTimeStep);
[dataTrainMech, dataTestMech] = trainPartitioning(trainDataMech, trainPercentage);

[XTrainMech, TTrainMech] = preprocessTrainData(dataTrainMech, 7);
[XTest, TTest] = preprocessTrainData(dataTestMech, 7);

% layers
layersMech = [
    sequenceInputLayer(7,Normalization="rescale-zero-one")
    fullyConnectedLayer(200)
    reluLayer
    lstmLayer(200)
    % lstmLayer(200)
    reluLayer
    dropoutLayer
    fullyConnectedLayer(1)
    regressionLayer];

% layers
options = trainingOptions("adam", ...
    MaxEpochs=10000, ...
    GradientThreshold=1, ...
    InitialLearnRate=5e-3, ...
    LearnRateSchedule="piecewise", ...
    LearnRateDropPeriod=1e4, ...
    LearnRateDropFactor=0.5, ...
    L2Regularization = 0.0001, ...
    Verbose=0, ...
    Plots="training-progress",...
    ValidationData={XTest,TTest});

netMech = trainNetwork(XTrainMech,TTrainMech,layersMech,options);

