%% Initialization
proj = matlab.project.rootProject; % project root
scenarioDir = fullfile(proj.RootFolder, 'BraytonGasTurbSimplified_LSTMReduction', 'SimulationInput');
simOutDir = fullfile(proj.RootFolder, 'BraytonGasTurbSimplified_LSTMReduction', 'SimulationOutput');
modelName = 'turboshaftEngine_toReduce';
simStopTimeLong = 1000; % Simulation stop time in s

train = true; % enable or disable network trainning

%% Wavelet analysis
load_system(modelName)
outSim = sim(modelName);
sampleTime = 1; % s
[resampledData, sigNames] = resampleSimulationData(outSim,sampleTime);


for iy =1:length(sigNames{:})
    figure()
    
    cwt(resampledData{1}(iy,:),1/sampleTime)
    title(sigNames{1}{iy})
end


%% Scenarios
% run several operation points at several altitudes
altitude = [0:10:500];

numCases = length(altitude);
simIn(1:numCases) = Simulink.SimulationInput(modelName);

for ix=1:numCases
    simIn(ix) = simIn(ix).setBlockParameter([modelName,'/Altitude'],'Value', num2str(altitude(ix)));
end

%% Simulate
simOut = parsim(simIn);


%% Resample results
sampleTime = 1; % s
[resampledData, sigNames] = resampleSimulationData(simOut,sampleTime);


%% Visualize
visualizeTrainData(resampledData,sigNames{1}, 'Resampled Data')

%% Partition
trainPercentage = 1; % the percentage of the data that they will be used for training
                       % the rest will be used for test

[dataTrain, dataTest] = trainPartitioning(resampledData, trainPercentage);

%% Concat

concatDataTrain = [];
for ix=1:numel(dataTrain)
    concatDataTrain = cat(2,concatDataTrain,dataTrain{ix}(:,:));
end

concatDataTest = [];
for ix=1:numel(dataTest)
    concatDataTest = cat(2,concatDataTest,dataTest{ix}(:,:));
end

%% Prepare
XTrain = concatDataTrain;
XVal = concatDataTest;

if not(isempty(concatDataTest))
YTrain = XTrain(2:end,:);
YVal = XVal(2:end,:);
end

% Normalize training and validation data
for ix=1:size(XTrain,1)
    meanTrain(ix) = mean(XTrain(ix,:));
    stdTrain(ix) = std(XTrain(ix,:));
if not(isempty(concatDataTest))    
    meanVal(ix) = mean(XVal(ix,:));
    stdVal(ix) = std(XVal(ix,:));
end

end

%% Normalize
normalize = @(x,mu,sigma) (x - mu) ./ sigma;
dataTrainNorm = [];
for iy=1:size(dataTrain,2)
    normTrainSep = [];
    % Normalize train data
    for ix=1:size(dataTrain{iy},1)
        normTrainSep(ix,:) = normalize(dataTrain{iy}(ix,:),meanTrain(ix), stdTrain(ix));
    end
    dataTrainNorm{iy} = normTrainSep;
end


dataValNorm=[];
for iy=1:size(dataTest,2)
    normValSep = [];
    for ix=1:size(dataTest{iy},1)
        normValSep(ix,:) = normalize(dataTest{iy}(ix,:),meanVal(ix), stdVal(ix));
    end
    dataValNorm{iy} = normValSep;
end


%%

numFeatures = 10;
numResponses = 9;
outStartIdx = 2;
numHiddenUnits = 150;
dropoutProbability = 0.2;


[XTrainSep, TTrainSep] = preprocessTrainData(dataTrainNorm, outStartIdx);

layers = [
    sequenceInputLayer(numFeatures,"Name","input")
    lstmLayer(numHiddenUnits,"Name","lstm","OutputMode","sequence")
    dropoutLayer(dropoutProbability,"Name","drop")
    fullyConnectedLayer(numHiddenUnits,"Name","fc_1")
    reluLayer("Name","relu")
    fullyConnectedLayer(numResponses,"Name","fc_2")
    regressionLayer("Name","regressionoutput")
    ];

opts = trainingOptions("adam",...
    "ExecutionEnvironment","auto",...
    "InitialLearnRate",0.01,...
    "MaxEpochs",1000,...
    "Shuffle","every-epoch",... 
    "LearnRateSchedule","piecewise",...
    "LearnRateDropPeriod",200,...
    "LearnRateDropFactor",0.1,...
    "ValidationFrequency",10,...
    "Plots","training-progress");

if train
    [net, traininfo] = trainNetwork(XTrainSep,TTrainSep,layers,opts);
    net = resetState(net);
end


%%

idx = 1;
X = XTrainSep{idx};
TY = TTrainSep{idx};

net = resetState(net);
offset = 1;
[net,~] = predictAndUpdateState(net,X(:,1:offset));

numTimeSteps = size(X,2);
numPredictionTimeSteps = numTimeSteps - offset;
Y = zeros(numResponses,numPredictionTimeSteps);
Y(:,1) = X(2:end,1);
for t = 2:numPredictionTimeSteps
    Xt = [X(1,t-1);Y(:,t-1)];
    [net,Y(:,t)] = predictAndUpdateState(net,Xt);
   hiddenState(t,:) = net.Layers(2,1).HiddenState;
   cellState(t,:) = net.Layers(2,1).CellState;
end

for inspSig=1:numResponses
figure
plot(Y(inspSig,:)'*stdTrain(inspSig)+meanTrain(inspSig))
hold on
plot(TY(inspSig,:)'*stdTrain(inspSig)+meanTrain(inspSig))
hold off
end