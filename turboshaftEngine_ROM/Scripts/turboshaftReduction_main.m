%% Initialization
proj = matlab.project.rootProject; % project root
scenarioDir = fullfile(proj.RootFolder, 'turboshaftEngine_ROM', 'SimulationInput');
simOutDir = fullfile(proj.RootFolder, 'turboshaftEngine_ROM', 'SimulationOutput');
modelName = 'simpleHelicopter_toReduce';
simStopTime = 500; % Simulation stop time in s

train = true; % enable or disable network trainning

%% Wavelet analysis
load_system(modelName)
% Qin = scenario{1}.shaftSpeedRef{1}.Values.Data;
% Qin_time = scenario{1}.shaftSpeedRef{1}.Values.Time;
% outSim = sim(modelName);
% sampleTime = 1; % s
% [resampledDataCell, sigNamesCell] = resampleSimulationData(outSim,sampleTime);
% 
% 
% for iy =1:length(sigNamesCell)
%     figure()
%     cwt(resampledDataCell{1}(iy,:),1/sampleTime)
%     title(sigNames{1}{iy})
% end


%% Scenarios
% run several operation points at several altitudes
% load_system(modelName)
% altitude = [0:500:5000];
% 
% numCases = length(altitude);
% simIn(1:numCases) = Simulink.SimulationInput(modelName);
% 
% for ix=1:numCases
%     simIn(ix) = simIn(ix).setBlockParameter([modelName,'/Altitude'],'Value', num2str(altitude(ix)));
% end

%% Generate Simulation Scenarios
initialScenarioVector = [2e3:0.5e3:5e3];
shaftSpeedStates = {{initialScenarioVector,simStopTime},
                    {[initialScenarioVector(1), initialScenarioVector(2:end)+150],simStopTime},                       
                    {[initialScenarioVector(1), initialScenarioVector(2:end)+300],simStopTime},
                    {[initialScenarioVector(1), initialScenarioVector(2:end)+450], simStopTime},
                    {[initialScenarioVector(1), initialScenarioVector(2:end)+600],simStopTime}, 
                    {[initialScenarioVector(1), initialScenarioVector(2:end)+650], simStopTime}};

for ix=1:numel(shaftSpeedStates)
    generateShaftSpeedInputs(scenarioDir, shaftSpeedStates{ix}{1},...
    shaftSpeedStates{ix}{2}, 'stairOnly', ix)
end


%% Generate Simulink Simulation Inputs
load_system(modelName)

clearvars simIn
% run several operation points at several altitudes
% altitude = [0:500:2000];

fileList = listSimInpFiles(scenarioDir);
numCases = length(fileList);
% totCases = numCases*length(altitude);
scenario = {};


for ix=1:numCases
    fileName = split(fileList{ix},'.');
    scenario{ix} = load(fileList{ix});
    aux = split(fileName{1},'_');
    simStopTime = aux{end};
    simIn(ix) = Simulink.SimulationInput(modelName);

    simIn(ix) = simIn(ix).setModelParameter('StopTime', simStopTime);
    % Initialize compressor's RPM with respect to the Simulation scenarios
    simIn(ix) = setVariable(simIn(ix), 'Qin', scenario{ix}.shaftSpeedRef{1}.Values.Data', ...
        'Workspace', modelName);    
    simIn(ix) = setVariable(simIn(ix),'Qin_time', scenario{ix}.shaftSpeedRef{1}.Values.Time', ...
        'Workspace', modelName);
end


%% Slope scenarios
% clear simIn
% qin_slope = [1:10];
% numCases = length(qin_slope);
% simIn(1:numCases) = Simulink.SimulationInput(modelName);
% for ix=1:numCases
%     simIn(ix) = simIn(ix).setModelParameter('StopTime', simStopTime);
%     simIn(ix) = simIn(ix).setBlockParameter([modelName, '/Ramp'], 'Slope', num2str(qin_slope(ix)));
% end

%% Simulate
simOut = parsim(simIn);

%% Resample results
sampleTime = 1; % s
[resampledData, sigNamesCell] = resampleSimulationData(simOut,0.1);
sigNames = sigNamesCell{1};

%% Reorder data
firstNames = [{'Altitude', 'Qin'}];
[reorderedData, reorderedNames] = reorderData(resampledData, sigNames, firstNames);

%% Visualize
visualizeTrainData(reorderedData,reorderedNames, 'Resampled Data')


%% Partition
trainPercentage = 1; % the percentage of the data that they will be used for training
                       % the rest will be used for test

[dataTrain, dataTest] = trainPartitioning(reorderedData, trainPercentage);

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

%% Inspect Normalized Train Data
visualizeTrainData(dataTrainNorm(:),reorderedNames, 'Train Data')


%% NN Architecture

numFeatures = length(sigNames);
numResponses = length(sigNames)-length(firstNames);
outStartIdx = length(firstNames)+1;
numHiddenUnits = 150;
dropoutProbability = 0.2;
initLearnRate = 1e-2;
learnDropPeriod = 200;

[XTrainSep, TTrainSep] = preprocessTrainData(dataTrainNorm, outStartIdx);

layers = [
    sequenceInputLayer(numFeatures,"Name","input")
    lstmLayer(numHiddenUnits,"Name","lstm","OutputMode","sequence")
    % lstmLayer(numHiddenUnits,"Name","lstm","OutputMode","sequence")
    dropoutLayer(dropoutProbability,"Name","drop")
    fullyConnectedLayer(numHiddenUnits,"Name","fc_1")
    % reluLayer("Name","relu")
    fullyConnectedLayer(numResponses,"Name","fc_2")
    regressionLayer("Name","regressionoutput")
    ];

opts = trainingOptions("adam",...
    "ExecutionEnvironment","auto",...
    "InitialLearnRate",initLearnRate,...
    "MaxEpochs",1000,...
    "Shuffle","every-epoch",... 
    "LearnRateSchedule","piecewise",...
    "LearnRateDropPeriod",learnDropPeriod,...
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
% [net,~] = predictAndUpdateState(net,X(:,1:offset));

numTimeSteps = size(X,2);
numPredictionTimeSteps = numTimeSteps - offset;
Y = zeros(numResponses,numPredictionTimeSteps);
Y(:,1) = X(3:end,1);
for t = 2:numPredictionTimeSteps
   Xt = [X(1:2,t-1);Y(:,t-1)];
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

%% save net
net = resetState(net);
save("turboshaftEngine_ROM\turboshaft_ROM_short.mat","net")