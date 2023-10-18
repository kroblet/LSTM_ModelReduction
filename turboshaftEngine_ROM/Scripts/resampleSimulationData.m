function [reorderedData, reorderedNames] = resampleSimulationData(out,sampleStep)
%PREPARETRAININGDATA takes as input the Simulink.SimulationOutputs and
%returns a cell array with the trainning inputs and outputs
    cutoff = 1;
    caseNum = length(out);
    data={};
    names = {};
    for ix =1:caseNum
        time = out(ix).tout;
        timeStep = time(2)-time(1);
        logNum = numElements(out(ix).logsout);
        resTime = 0:sampleStep:max(time)-cutoff;
    
        for iy=1:logNum
            loggedVector = round(out(ix).logsout{iy}.Values.Data(:),6);
            if length(loggedVector)==1
                loggedVector = ones(1,length(time)-cutoff).*loggedVector(:);
            else
                loggedVector = round(out(ix).logsout{iy}.Values.Data(1:end-cutoff),6);
            end
            data{ix}(iy,:) = downsample(loggedVector(:), sampleStep/timeStep);

            names{ix}{iy} = out(ix).logsout{iy}.Name;

        end
    
    end
%% Reorder data
firstNames = [{'Altitude', 'Qin'}];
[reorderedData, reorderedNames] = reorderData(data, names{1}, firstNames);

end

