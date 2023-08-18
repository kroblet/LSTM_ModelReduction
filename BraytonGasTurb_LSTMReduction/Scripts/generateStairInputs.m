function generateStairInputs(scenariopDir, shaftSpeed, time)
%GENERATESTAIRINPUT function generates simulaiton inputs for stair
%reference shaft velocity
name = ['stairShaftSpeed_' num2str(shaftSpeed(1)) '_' num2str(shaftSpeed(end))];
shaftSpeedRef = Simulink.SimulationData.Dataset(shaftSpeed');
shaftSpeedRef{1}.Values.Time = time';
shaftSpeedRef{1}.Name = name;
fileName = fullfile(scenariopDir, [name '_st_' num2str(max(time)) '.mat']);
save(fileName, "shaftSpeedRef");
end

