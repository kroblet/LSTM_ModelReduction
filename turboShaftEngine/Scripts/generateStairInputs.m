function generateStairInputs(scenariopDir, stateVec, time, idx, physMagnitude)
%GENERATESTAIRINPUT function generates simulaiton inputs for stair
%reference shaft velocity
name = [physMagnitude '_' num2str(stateVec(1)) '_' num2str(stateVec(end))];
stateVecRef = Simulink.SimulationData.Dataset(stateVec');
stateVecRef{1}.Values.Time = time';
stateVecRef{1}.Name = name;
fileName = fullfile(scenariopDir, [num2str(idx) name '_st_' num2str(idx) '_' num2str(max(time)-5) '.mat']);
save(fileName, "stateVecRef");
end

