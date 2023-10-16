function [data, names] = resampleSimulationData(out,sampleStep)
%PREPARETRAININGDATA takes as input the Simulink.SimulationOutputs and
%returns a cell array with the trainning inputs and outputs
    cutoff = 1;
    caseNum = length(out);
    data={};
    names = {};
    for ix =1:caseNum
        time = out(ix).tout;
        logNum = numElements(out(ix).logsout);
        resTime = 0:sampleStep:max(time)-cutoff;
    
        for iy=1:logNum
            loggedVector = round(out(ix).logsout{iy}.Values.Data(:),6);
            if length(loggedVector)==1
                loggedVector = ones(1,length(time)-cutoff).*loggedVector(:);
            else
                loggedVector = round(out(ix).logsout{iy}.Values.Data(1:end-cutoff),6);
            end
    

            % data{ix}(iy,:) = resample(loggedVector, time, 1/sampleStep)
            data{ix}(iy,:) = downsample(loggedVector(:), 1/sampleStep);

            % data{ix}(iy,:) = interp1(time, loggedVector,  resTime);
            
            names{ix}{iy} = out(ix).logsout{iy}.Name;

        end
    
    end
end

