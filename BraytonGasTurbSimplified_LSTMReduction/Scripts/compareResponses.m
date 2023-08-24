function dev = compareResponses(refData, inpData, signalNames, figTitle)
%COMPARERESPONSES Summary of this function goes here
%   Detailed explanation goes here
ax = {};
figure;
signalNum = size(refData{1},1);
lg = {};
iz = 1;
for ix=1:signalNum
    ax{ix} = subplot(2*signalNum,1,iz);
    axEr{ix} = subplot(2*signalNum,1,iz+1);
    hold(ax{ix},'on');
    hold(axEr{ix},'on');
    iz= iz+2;
end

numCases = length(refData);
ik=1;
for ix=1:numCases 
    dataRef = refData{ix};
    dataInp = inpData{ix};
    for iy=1:signalNum
        plot(ax{iy}, dataRef(iy,:));
        plot(ax{iy}, dataInp(iy,:));
        dev{iy} = dataInp(iy,:)-dataRef(iy,:);
        plot(axEr{iy}, dev{iy});
        lg{ik} = ['Scenario ' num2str(iy)];
        lg{ik+1} = ['Response ' num2str(iy)];
        ik= ik+2;
    end
end

% hold off axes

for ix=1:signalNum
    ylabel(ax{ix},signalNames{ix})
    ylabel(axEr{ix},['Difference in ' signalNames{ix}])

    grid(ax{ix}, 'on')
    grid(axEr{ix}, 'on')
    hold(ax{ix},'off')
end
title(ax{1}, figTitle);
legend(ax{1},lg);
title(axEr{1},'Deviation from reference')
end



