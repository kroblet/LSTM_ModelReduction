%% Generate simulation inputs
modelName = 'simpleModel';

trainTqs = [0.2:0.1:1.5];
nameList = {};

numCases = length(trainTqs);

for ix=1:numCases
    nameList{ix} = append('tqInp_',num2str(ix));
    generateDatasetTq(trainTqs(ix), nameList{ix})
    simIn(ix) = Simulink.SimulationInput(modelName);

    dataFile = [nameList{ix} '.mat'];
    simIn(ix) = simIn(ix).setBlockParameter([modelName,'/Signal Editor'], 'Filename', dataFile);
end

%% Simulate
out = parsim(simIn);

%% Save results
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


