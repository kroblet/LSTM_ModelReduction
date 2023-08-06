function generateShaftSpeedInputs(scenarioDir,shaftSpeedStates, simStopTime)
%GENERATESHAFTINPUTS Summary of this function goes here
%   Detailed explanation goes here
shaftSpeeds = shaftSpeedVector(shaftSpeedStates);
time = linspace(0,simStopTime,length(shaftSpeeds));

% Constant Simulation Scenarios
for ix =1:numel(shaftSpeedStates)
    generateCteInput(scenarioDir, shaftSpeedStates(ix), simStopTime)
end

% Increased speed Simulation Scenarios
generateStairInputs(scenarioDir, shaftSpeeds, time);

% Decreased speed Simulation scenarios
generateStairInputs(scenarioDir, fliplr(shaftSpeeds), time);

end

