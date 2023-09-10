function generateShaftSpeedInputs(scenarioDir,shaftSpeedStates, simStopTime, mode, idx)
%GENERATESHAFTINPUTS Summary of this function goes here
%   Detailed explanation goes here
shaftSpeeds = shaftSpeedVector(shaftSpeedStates);
stepTimes = linspace(0,simStopTime, length(shaftSpeedStates));
timeStep = (stepTimes(2)-stepTimes(1));
time = timeVector(stepTimes, 0.8*timeStep);

if strcmp(mode,'all')
    % Constant Simulation Scenarios
    for ix =1:numel(shaftSpeedStates)
        generateCteInput(scenarioDir, shaftSpeedStates(ix), simStopTime, idx)
    end
end
    % Increased speed Simulation Scenarios
    generateStairInputs(scenarioDir, shaftSpeeds, time, idx);
    
    % Decreased speed Simulation scenarios
if strcmp(mode,'all') || strcmp(mode,'descent')
    generateStairInputs(scenarioDir, fliplr(shaftSpeeds), time, idx);
end
end

