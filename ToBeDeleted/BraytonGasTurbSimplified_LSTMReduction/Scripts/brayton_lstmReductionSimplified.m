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
                    % {[ones(1,4).*4.2e3],simStopTimeShort},                       
                    {[4.2e3:1e3:1.2e4],simStopTimeShort},
                    {[4.5e3:1e3:1.2e4], simStopTimeShort},
                    % {[ones(1,4).*4.8e3],simStopTimeShort} 
                    % {[4.8e3:2e3:1.2e4], simStopTimeShort}
                    }
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
resampleTimeStep = 1; % resample time step in (s)
scaleFactor = 1000; % scale the input data
trainData = prepareTrainingData(out,resampleTimeStep, scaleFactor); 

%% Inspect resampled data
signalNames = {'Nref','Phi','N', 'MechPower', 'T3'};
visualizeTrainData(trainData(:),signalNames, 'Resampled Data')

%% Inputs outputs
sigNumIn = 5;
sigNumOut = 4;
outStartIdx = 2;

%% LSTM Architecture
layers = [
    sequenceInputLayer(sigNumIn,Normalization="rescale-zero-one")
    fullyConnectedLayer(200)
    reluLayer
    lstmLayer(200)
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
    MiniBatchSize=20, ...
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

%% Open loop prediction - Update States
X = XTest{1};
TY = TTest{1};

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
save(fullfile(proj.RootFolder, 'BraytonGasTurbSimplified_LSTMReduction','braytonLSTMNetThermoStateUpdateWithNref'), 'net')

figure
plot(Y')

% Quick inspect
hold on 
plot(TY')
hold off

%% Simulate ROM model
modelROM = 'brayton_cycle_LSTM_ROM';
clearvars simInROM
scenarioIdx = 9;
testScenario = scenario{scenarioIdx};  
simInROM = Simulink.SimulationInput(modelROM);

% Initialize compressor's RPM with respect to the Simulation scenarios
rpm0 = testScenario.shaftSpeedRef{1}.Values.Data(1);
simInROM = setVariable(simInROM, 'rpm0', rpm0, ...
    'Workspace', modelName);  
simInROM = setVariable(simInROM, 'rpm_setpoint', testScenario.shaftSpeedRef{1}.Values.Data', ...
    'Workspace', modelName);    
simInROM = setVariable(simInROM,'time_setpoint', testScenario.shaftSpeedRef{1}.Values.Time', ...
    'Workspace', modelName);

%% Simulate ROM
outROM = sim(simInROM);

%% Compare ROM with initial model
import matlab.unittest.TestCase
import Simulink.sdi.constraints.MatchesSignal
import Simulink.sdi.constraints.MatchesSignalOptions
% Create a test case:
testCase = TestCase.forInteractiveUse;    

% Set accepted tolerance
relTol = 1e-1;

% Map log signals
dic = {};
dic{1} = 2;
dic{2} = 1;
dic{3} = 4;

% Compare different signals between ROM LSTM model and original model.
for ix=1:outROM.logsout.numElements-1
        testCase.verifyThat(outROM.logsout{ix},MatchesSignal(out(scenarioIdx).logsout{dic{ix}},'RelTol',1e-4))
end


