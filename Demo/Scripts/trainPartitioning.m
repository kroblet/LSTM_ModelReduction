function [dataTrain, dataTest] = trainPartitioning(trainData, trainPercentage)
% TRAINPARTITIONING takes as input the data for trainning and returns
% the trainPercentage of data for trainning and 1-trainPercentage for 
% testing
numObservations = numel(trainData);
idxTrain = 1:floor(trainPercentage*numObservations);
idxTest = floor(trainPercentage*numObservations)+1:numObservations;
dataTrain = trainData(idxTrain);
dataTest = trainData(idxTest);