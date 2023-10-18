function [dataTrainNorm] = normalizeData(normalize, dataTrain, meanTrain, stdTrain)

dataTrainNorm = [];
for iy=1:size(dataTrain,2)
    normTrainSep = [];
    % Normalize train data
    for ix=1:size(dataTrain{iy},1)
        normTrainSep(ix,:) = normalize(dataTrain{iy}(ix,:),meanTrain(ix), stdTrain(ix));
    end
    dataTrainNorm{iy} = normTrainSep;
end


% dataValNorm=[];
% for iy=1:size(dataTest,2)
%     normValSep = [];
%     for ix=1:size(dataTest{iy},1)
%         normValSep(ix,:) = normalize(dataTest{iy}(ix,:),meanVal(ix), stdVal(ix));
%     end
%     dataValNorm{iy} = normValSep;
% end

end