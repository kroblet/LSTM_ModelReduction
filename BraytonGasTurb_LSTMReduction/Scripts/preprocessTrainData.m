function [XTrain, TTrain] = preprocessTrainData(dataTrain, TTidx)
%PREPROCESSTRAINDATA split trainData to train inputs and train outputs
XTrain = {};
TTrain = {};

for n = 1:numel(dataTrain)
    X = dataTrain{n};
    XTrain{n} = X(:,1:end-1);
    TTrain{n} = X(TTidx:end,2:end);
end
end

