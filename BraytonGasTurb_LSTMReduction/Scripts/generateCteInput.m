function generateCteInput(scenariopDir, shaftSpeed, simStopTime)
    % ConstantInp
    name = ['constantShaftSpeed_' num2str(shaftSpeed)];
    time = [0 simStopTime];
    shaftSpeedRef = [shaftSpeed shaftSpeed]; 
    shaftSpeedRef = Simulink.SimulationData.Dataset(shaftSpeedRef');
    shaftSpeedRef{1}.Values.Time = time';
    shaftSpeedRef{1}.Name = name;
    fileName = fullfile(scenariopDir, [name '.mat']);
    save(fileName, "shaftSpeedRef")
end
