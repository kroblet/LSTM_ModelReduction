%% Initialization
proj = matlab.project.rootProject; % project root
scenarioDir = fullfile(proj.RootFolder, 'BraytonGasTurbSimplified_LSTMReductionTrial', 'SimulationInput');
simOutDir = fullfile(proj.RootFolder, 'BraytonGasTurbSimplified_LSTMReductionTrial', 'SimulationOutput');
modelName = 'brayton_cycle_lstm_simplified';
simStopTimeShort = 300; % Simulation stop time in s
simStopTimeLong = 500; % Simulation stop time in s

train = true; % enable or disable network trainning

%% Generate Simulation Scenarios
shaftSpeedStates = {{[4e3:1e3:1e4],simStopTimeLong},
                    % {[ones(1,4).*4.2e3],simStopTimeShort}, 
                    % new additions
                    {[[4e3:1e3:8e3] [8e3:-1e3:4e3]] ,simStopTimeShort},
                    {[[5e3:1e3:9e3] [9e3:-1e3:5e3]] ,simStopTimeShort},
                    {[[6e3:1e3:10e3] [10e3:-1e3:6e3]] ,simStopTimeShort},
                    {[[7e3:1e3:12e3] [12e3:-1e3:7e3]] ,simStopTimeShort},
                    {[5e3:0.5e3:1.1e4], simStopTimeShort},
                    {[6e3:0.5e3:1.1e4], simStopTimeShort},
                    {[7e3:0.5e3:1.1e4], simStopTimeShort},
                    {[8e3:0.5e3:1.1e4], simStopTimeShort},
                    {[9e3:0.5e3:1.1e4], simStopTimeShort},

                    % end of new additions
                    {[4.2e3:1e3:1.2e4],simStopTimeShort},
                    {[4.5e3:1e3:1.2e4], simStopTimeShort},
                    % {[ones(1,4).*4.8e3],simStopTimeShort}, 
                    % {[4.8e3:2e3:1.2e4], simStopTimeShort}
                    };

for ix=1:numel(shaftSpeedStates)
    generateShaftSpeedInputs(scenarioDir, shaftSpeedStates{ix}{1},...
    shaftSpeedStates{ix}{2}, 'stairOnly', ix)
end

%% Generate Simulink Simulation Inputs
clearvars simIn
fileList = listSimInpFiles(scenarioDir);
numCases = length(fileList);
scenario = {};
for ix=1:numCases
    fileName = split(fileList{ix},'.');
    scenario{ix} = load(fileList{ix});
    aux = split(fileName{1},'_');
    simStopTime = aux{end};
    simIn(ix) = Simulink.SimulationInput(modelName);

    simIn(ix) = simIn(ix).setModelParameter('StopTime', simStopTime);
    % Initialize compressor's RPM with respect to the Simulation scenarios
    rpm0 = aux{2};
    simIn(ix) = setVariable(simIn(ix), 'rpm0', str2num(rpm0), ...
        'Workspace', modelName);  
    simIn(ix) = setVariable(simIn(ix), 'rpm_setpoint', scenario{ix}.shaftSpeedRef{1}.Values.Data', ...
        'Workspace', modelName);    
    simIn(ix) = setVariable(simIn(ix),'time_setpoint', scenario{ix}.shaftSpeedRef{1}.Values.Time', ...
        'Workspace', modelName);
end

%% Simulate
out = parsim(simIn);

%% Save results
save(fullfile(simOutDir,'simOuts'),'out') 

%% Remove simulation outputs with errors
out = removeSimOutWithErrors(out);

%% Resample and configure data for trainning
resampleTimeStep = 0.1; % resample time step in (s)
scaleFactor = 1; % scale the input data
removeInitEffect = 1;
trainData = prepareTrainingData(out,resampleTimeStep, scaleFactor,removeInitEffect); 

%% Concat data
concatData = [];
% concatData = [trainData{1}];
for ix=1:numel(trainData)
 concatData = cat(2,concatData,trainData{ix}(:,:));
end

%% Visualize concat data
figure
T = array2table([concatData'], VariableNames=["Reference RPM","Phi","RPM","Mech Power","T3"]);

stackedplot(T)

%% 1.2. Prepare training and validation data
clear XTrainNormalized YTrainNormalized normTrain normVal
holdOut = 0.2;
X = concatData;
percentValidation = round(length(X)*holdOut);
XTrain = X(:,1:end-percentValidation);
XVal = X(:,end-percentValidation+1:end);

YTrain = X(2:end, 1:end-percentValidation);
YVal = X(2:end, end-percentValidation+1:end);

% Normalize training and validation data
for ix=1:size(XTrain,1)
    meanTrain(ix) = mean(XTrain(ix,:));
    meanVal(ix) = mean(XVal(ix,:));
    stdTrain(ix) = std(XTrain(ix,:));
    stdVal(ix) = std(XVal(ix,:));

end

normalize = @(x,mu,sigma) (x - mu) ./ sigma;
for ix=1:size(XTrain,1)
    normTrain(ix,:) = normalize(XTrain(ix,:),meanTrain(ix), stdTrain(ix));
    normVal(ix,:) = normalize(XVal(ix,:),meanVal(ix), stdVal(ix));
end
XTrainNormalized = normTrain;
YTrainNormalized = normTrain(2:end,:);

XValNormalized = normVal;
YValNormalized = normVal(2:end,:);

chunksize = 500;
numFeatures = size(XTrainNormalized,1);
[XTrainNormalized_cell, YTrainNormalized_cell] = helper.setupData(XTrainNormalized, YTrainNormalized, chunksize, numFeatures);

% %% Inspect resampled data
signalNames = {'Nref','Phi','N', 'MechPower', 'T3'};
visualizeTrainData(trainData(:),signalNames, 'Resampled Data')

%% Data normalize per scenario

% Partition trainning data
trainPercentage = 0.8; % the percentage of the data that they will be used for training
                       % the rest will be used for test

[dataTrain, dataTest] = trainPartitioning(trainData, trainPercentage);

% Normalize train scenarios
for iy=1:size(dataTrain,2)
    normTrainSep = [];
    % Normalize train data
    for ix=1:size(dataTrain{iy},1)
        normTrainSep(ix,:) = normalize(dataTrain{iy}(ix,:),meanTrain(ix), stdTrain(ix));
    end
    dataTrainNorm{iy} = normTrainSep;
end

% Normalize test scenarios
for iy=1:size(dataTest,2)
    normValSep = [];
    for ix=1:size(dataTest{iy},1)
        normValSep(ix,:) = normalize(dataTest{iy}(ix,:),meanVal(ix), stdVal(ix));
    end
    dataValNorm{iy} = normValSep;
end

% Preprocess
[XTrainSep, TTrainSep] = preprocessTrainData(dataTrainNorm, outStartIdx);
[XTestSep, TTestSep] = preprocessTrainData(dataValNorm, outStartIdx);



%% Inputs outputs
sigNumIn = numFeatures;
sigNumOut = numFeatures-1;
numResponses = sigNumOut;
outStartIdx = 2;
numHiddenUnits = 150;
dropoutProbability = 0.2;

% Define input dataset
% XTrainData = XTrainNormalized_cell;
% XTestData = XValNormalized;
% YTrainData = YTrainNormalized_cell;
% YTestData = YValNormalized;

XTrainData = XTrainSep;
XTestData = XTestSep;
YTrainData = TTrainSep;
YTestData = TTestSep;

%% LSTM Architecture - Normalized
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
    "ValidationData",{XTestData,YTestData},...
    "Plots","training-progress");
if train
    [net, traininfo] = trainNetwork(XTrainData,YTrainData,layers,opts);
end


%% Check response
results = predict(net,XTrainNormalized,SequencePaddingDirection="left");

%% Save NN architecture
save(fullfile(proj.RootFolder, 'BraytonGasTurbSimplified_LSTMReductionTrial','braytonLSTMNetThermoNormLong'), 'net')

%% Inspect NN response
dev = compareResponses(TTest, results, signalNames(outStartIdx:end), 'NN Response');
mean(dev{1})
std(dev{1})



%% Open loop prediction - Update States
X = XTestSep{2};
TY = TTestSep{2};

net = resetState(net);
offset = 1;
[net,~] = predictAndUpdateState(net,X(:,1:offset));

numTimeSteps = size(X,2);
numPredictionTimeSteps = numTimeSteps - offset;
Y = zeros(sigNumOut,numPredictionTimeSteps);


for t = 2:numPredictionTimeSteps
    Xt = [X(1,t-1);Y(:,t-1)];
    [net,Y(:,t)] = predictAndUpdateState(net,Xt);
end

net = resetState(net);
save(fullfile(proj.RootFolder, 'BraytonGasTurbSimplified_LSTMReduction','braytonLSTMNetThermoStateUpdateWithNrefNorm'), 'net')


inspSig = 3;
for inspSig=1:numResponses
figure
plot(Y(inspSig,:)'*stdVal(inspSig)+meanVal(inspSig))
hold on
plot(TY(inspSig,:)'*stdVal(inspSig)+meanVal(inspSig))
hold off
end

%% Set normalization properties
open_system('brayton_cycle_LSTM_ROM')

hws = get_param(bdroot, 'modelworkspace');

hws.assignin('RPM_refMean', meanTrain(1));
hws.assignin('phiMean', meanTrain(2));
hws.assignin('rpmMean', meanTrain(3));
hws.assignin('powerMean', meanTrain(4));
hws.assignin('t3Mean', meanTrain(5));

hws.assignin('RPM_refStd', stdTrain(1));
hws.assignin('phiStd', stdTrain(2));
hws.assignin('rpmStd', stdTrain(3));
hws.assignin('powerStd', stdTrain(4));
hws.assignin('t3Std', stdTrain(5));


hws.assignin('samplTime', resampleTimeStep);

% hws.reload;
% get_param(bdroot, 'modelworkspace');
