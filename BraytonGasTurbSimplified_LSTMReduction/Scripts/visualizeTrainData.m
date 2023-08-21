function visualizeTrainData(trainData,signalNames)
%VISUALIZETRAINDATA Summary of this function goes here
%   Detailed explanation goes here
ax = {};
signalNum = size(trainData{1},1);
for ix=1:signalNum
    ax{ix} = subplot(signalNum,1,ix);
    hold(ax{ix},'on')
end

numCases = length(trainData);

for ix=1:numCases 
    data = trainData{ix};
    for iy=1:signalNum
        plot(ax{iy}, data(iy,:))
    end
end

% hold off axes
for ix=1:signalNum
    ylabel(ax{ix},signalNames{ix})
    grid(ax{ix}, 'on')
    hold(ax{ix},'off')
end

end

