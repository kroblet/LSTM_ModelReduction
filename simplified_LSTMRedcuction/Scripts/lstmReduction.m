%% Initialization
proj = matlab.project.rootProject; % project root
modelName = 'simpleModel';
trainDir = fullfile(proj.RootFolder, 'simplified_LSTMRedcuction', 'TrainInput');
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
end

%% Simulate
out = parsim(simIn);

%% Configure trainning data format
trainData = {};
% for ix=1:length(out)
%     trainData{i}=
% 
% end
%% LSTM Architecture

layers = [
    sequenceInputLayer(1)
    lstmLayer(128)
    fullyConnectedLayer(1)
    regressionLayer];


