function initConditions = getInitNormData(meanTrain, stdTrain, resampledData)

initConditions = (resampledData{1}(:,1) - meanTrain')./stdTrain';

end