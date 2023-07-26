function data = trainningDataConv(out, sampleStep)
%TRAINNINGDATACONV takes as input the Simulink.SimulationOutputs and
%returns a dictionary with the trainning inputs and outputs
caseNum = length(out);
for ix =1:caseNum
    time = out(ix).tout;
    refTorq = out(ix).simlog.Motor_Drive.Tr.series.values; % reference torque input in the motor
    outTorque = out(ix).simlog.Inertia.t.series.values; % motor output torque
    outVelocity = out(ix).simlog.Inertia.w.series.values; % motor shaft speed

    % resample data
    resTime = 0:sampleStep:max(time);
    refTorq_res = interp1(time, refTorq, resTime);    
    outTorque_res = interp1(time, outTorque, resTime);
    outVelocity_res = interp1(time, outVelocity, resTime);

end



end

