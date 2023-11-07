function [dataTrain, dataTest, meanTrain, stdTrain] = prepareDataNormalization(reorderedData, trainPercentage)
%PREPAREDATANORMALIZATION gets the resampled data and the training
%percentage and it returns the train and test data and the mean and std
%values

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
end

