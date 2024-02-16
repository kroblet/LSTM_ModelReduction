function generateInputs(scenarioDir,states, simStopTime, idx, physMagn)
%GENERATEINPUTS generates Simulation scenarios for a given vector
%   Detailed explanation goes here
stateVector = stairVector(states);
stepTimes = linspace(0,simStopTime, length(states));
timeStep = (stepTimes(2)-stepTimes(1));
time = timeVector(stepTimes, 0.8*timeStep);
% ScenarioGeneration
generateStairInputs(scenarioDir, stateVector, time, idx, physMagn);
    
end
