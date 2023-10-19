%% Initialization
proj = matlab.project.rootProject; % project root
scenarioDir = fullfile(proj.RootFolder, 'turboshaftEngine', 'SimulationInput');
simOutDir = fullfile(proj.RootFolder, 'turboshaftEngine', 'SimulationOutput');
modelName = 'simpleHelicopter_toReduce';
simStopTime = 500; % Simulation stop time in s

train = true; % enable or disable network trainning

%% Wavelet analysis
% load_system(modelName)
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



%% Generate Simulation Scenarios
initialScenarioVector = [2e3:0.5e3:5e3];
referenceHeatStates = {{initialScenarioVector,simStopTime},
                    {[initialScenarioVector(1), initialScenarioVector(2:end)+150],simStopTime},                       
                    {[initialScenarioVector(1), initialScenarioVector(2:end)+300],simStopTime},
                    {[initialScenarioVector(1), initialScenarioVector(2:end)+450], simStopTime},
                    {[initialScenarioVector(1), initialScenarioVector(2:end)+600],simStopTime}, 
                    {[initialScenarioVector(1), initialScenarioVector(2:end)+650], simStopTime}};

for ix=1:numel(referenceHeatStates)
    generateInputs(scenarioDir, referenceHeatStates{ix}{1},...
    referenceHeatStates{ix}{2}, ix, 'heatIn')
end


%% Generate Simulink Simulation Inputs
load_system(modelName)
clearvars simIn
fileList = listSimInpFiles(scenarioDir);
numCases = length(fileList);
scenario = {};
simIn(1:numCases) = Simulink.SimulationInput(modelName);

for ix=1:numCases
    fileName = split(fileList{ix},'.');
    scenario{ix} = load(fileList{ix});
    aux = split(fileName{1},'_');
    scenarioSimStopTime = aux{end};

    simIn(ix) = simIn(ix).setModelParameter('StopTime', scenarioSimStopTime);
    simIn(ix) = setVariable(simIn(ix), 'Qin', scenario{ix}.stateVecRef{1}.Values.Data', ...
        'Workspace', modelName);    
    simIn(ix) = setVariable(simIn(ix),'Qin_time', scenario{ix}.stateVecRef{1}.Values.Time', ...
        'Workspace', modelName);
end

%% Simulate
simOut = parsim(simIn);

%% Resample results
sampleTime = 1; % s
commandSignals = [{'Altitude', 'Qin'}];
[resampledData, sigNames] = resampleSimulationData(simOut,sampleTime,commandSignals);

%% Visualize
visualizeTrainData(resampledData,sigNames, 'Resampled Data')


%% Prepare data normalization
trainPercentage = 1; % the percentage of the data that they will be used for training
                       % the rest will be used for test
[dataTrain, dataTest, meanTrain, stdTrain] = prepareDataNormalization(resampledData, trainPercentage);


%% Normalize
normalize = @(x,mu,sigma) (x - mu) ./ sigma;
dataTrainNorm = normalizeData(normalize, dataTrain, meanTrain, stdTrain);
%% Inspect Normalized Train Data
visualizeTrainData(dataTrainNorm(:),sigNames, 'Train Data')


%% NN Architecture
numFeatures = length(sigNames);
numResponses = length(sigNames)-length(commandSignals);
outStartIdx = length(commandSignals)+1;
numHiddenUnits = 150;
dropoutProbability = 0.2;
initLearnRate = 1e-2;
learnDropPeriod = 200;

[XTrainSep, TTrainSep] = preprocessTrainData(dataTrainNorm, outStartIdx);

layers = [
    sequenceInputLayer(numFeatures,"Name","input")
    lstmLayer(numHiddenUnits,"Name","lstm","OutputMode","sequence")
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


%% Compare reduced/original model
referenceModel = 'simpleHelicopter_reference';
open_system(referenceModel)
refSim = sim(referenceModel);
refRunID = Simulink.sdi.Run.getLatest;

reducedModel = 'simpleHelicopter_ROM';
open_system(reducedModel)
romSim = sim(reducedModel);
romRunID = Simulink.sdi.Run.getLatest;


%% Accuracy comparison
import matlab.unittest.TestCase
import Simulink.sdi.constraints.MatchesSignal
import Simulink.sdi.constraints.MatchesSignalOptions
% Create a test case:
testCase = TestCase.forInteractiveUse;    

% Set accepted tolerance
relTol = 1e-1;

% Compare different signals between ROM LSTM model and original model.
for ix=1:length(sigNames)
    basselineSig = refSim.logsout.getElement(sigNames{ix});
    romSig = romSim.logsout.getElement(sigNames{ix});
    testCase.verifyThat(romSig,MatchesSignal({basselineSig},'RelTol',relTol))
end


%% Visualize

for ix=1:length(sigNames)
% basselineSig = refSim.logsout.getElement(sigNames{ix});
% romSig = romSim.logsout.getElement(sigNames{ix});

refSigID = getSignalIDsByName(refRunID,sigNames{ix});
romSigID = getSignalIDsByName(romRunID,sigNames{ix});
sigNames{ix}
diffResult = Simulink.sdi.compareSignals(refSigID,romSigID);

Simulink.sdi.view

end


%% Performance comparison
compareSimulationPerformance(refSim, romSim)

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