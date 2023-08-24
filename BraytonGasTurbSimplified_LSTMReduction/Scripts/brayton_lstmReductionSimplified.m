%% Initialization
proj = matlab.project.rootProject; % project root
scenarioDir = fullfile(proj.RootFolder, 'BraytonGasTurbSimplified_LSTMReduction', 'SimulationInput');
simOutDir = fullfile(proj.RootFolder, 'BraytonGasTurbSimplified_LSTMReduction', 'SimulationOutput');
modelName = 'brayton_cycle_lstm_simplified';
simStopTimeShort = 300; % Simulation stop time in s
simStopTimeLong = 1000; % Simulation stop time in s

train = true; % enable or disable network trainning

%% Generate Simulation Scenarios
shaftSpeedStates = {{[4e3:1e3:1.1e4],simStopTimeShort},
                    {[ones(1,4).*4.2e3],simStopTimeShort},                       
                    {[4.2e3:1e3:1.2e4],simStopTimeShort},
                    {[4.5e3:1e3:1.2e4], simStopTimeShort},
                    {[ones(1,4).*4.8e3],simStopTimeShort}, 
                    {[4.8e3:2e3:1.2e4], simStopTimeShort}};

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
resampleTimeStep = 1;
trainData = prepareTrainingData(out,resampleTimeStep);

%% Inspect resampled data
signalNames = {'Phi','N', 'MechPower'};
visualizeTrainData(trainData(:),signalNames, 'Resampled Data')

%% Inputs outputs
sigNumIn = 3;
sigNumOut = 2;
outStartIdx = 2;

%% LSTM Architecture
layers = [
    sequenceInputLayer(sigNumIn,Normalization="rescale-zero-one")
    fullyConnectedLayer(200)
    reluLayer
    lstmLayer(200)
    % lstmLayer(100)
    reluLayer
    dropoutLayer
    fullyConnectedLayer(sigNumOut)
    regressionLayer];

%% Partition trainning data
trainPercentage = 0.5; % the percentage of the data that they will be used for training
                       % the rest will be used for test

[dataTrain, dataTest] = trainPartitioning(trainData, trainPercentage);

%% Preprocess
[XTrain, TTrain] = preprocessTrainData(dataTrain, outStartIdx);
[XTest, TTest] = preprocessTrainData(dataTest, outStartIdx);

%% Inspect Train Data
visualizeTrainData(XTrain(:),signalNames, 'Train Data')

%% Inspect Test Data
visualizeTrainData(XTest(:),signalNames, 'Test Data')

%% Train LSTM Network
options = trainingOptions("adam", ...
    MaxEpochs=5000, ...
    GradientThreshold=1, ...
    MiniBatchSize=8, ...
    InitialLearnRate=0.3e-1, ...
    LearnRateSchedule="piecewise", ...
    LearnRateDropPeriod=1.5e3, ...
    LearnRateDropFactor=0.5, ...
    L2Regularization = 0.0001, ...
    Verbose=0, ...
    Plots="training-progress",...
    ExecutionEnvironment='gpu', ...
    ValidationData={XTest,TTest});
    
if train
    net = trainNetwork(XTrain,TTrain,layers,options);
end

%% Check response
results = predict(net,XTest,SequencePaddingDirection="left");

%% Save NN architecture
save(fullfile(proj.RootFolder, 'BraytonGasTurbSimplified_LSTMReduction','braytonLSTMNetThermo'), 'net')

%% Inspect NN response
dev = compareResponses(TTest, results, signalNames(outStartIdx:end), 'NN Response');
mean(dev{1})
std(dev{1})
% %% Compare responses
% 
% 
% import matlab.unittest.TestCase
% import Simulink.sdi.constraints.MatchesSignal
% import Simulink.sdi.constraints.MatchesSignalOptions
% 
% testCase = TestCase.forInteractiveUse;    
% % Compare different signal response
% for ix=1:numel(results)
%         testCase.verifyThat(results{ix}(1,:),MatchesSignal(TTest{ix}(1,:),'RelTol',1e-1))
% end

