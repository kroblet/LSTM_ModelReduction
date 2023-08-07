function data = prepareTrainingData(out,sampleStep)
%PREPARETRAININGDATA takes as input the Simulink.SimulationOutputs and
%returns a cell array with the trainning inputs and outputs

caseNum = length(out);
data={};

for ix =1:caseNum
    time = out(ix).tout;
    apu_w = ones(length(time), 1)*out(ix).logsout{2}.Values.Data;
    phi = out(ix).logsout{3}.Values.Data;
    vn = out(ix).logsout{4}.Values.Data;
    vn_apu = ones(length(time), 1)*out(ix).logsout{7}.Values.Data;
    compRPM = out(ix).logsout{1}.Values.Data;
    power = out(ix).logsout{5}.Values.Data;

    % refTorq = out(ix).simlog.Motor_Drive.Tr.series.values; % reference torque input in the motor
    % outTorque = out(ix).simlog.Inertia.t.series.values; % motor output torque
    % outVelocity = out(ix).simlog.Inertia.w.series.values; % motor shaft speed

    % resample data
    resTime = 0:sampleStep:max(time);
    apu_w_res = interp1(time, apu_w, resTime);
    phi_res = interp1(time, phi, resTime);
    vn_res = interp1(time, vn, resTime);
    compRPM_res = interp1(time, compRPM, resTime);
    power_res = interp1(time, power, resTime);

    % refTorq_res = interp1(time, refTorq, resTime);    
    % outTorque_res = interp1(time, outTorque, resTime);
    % outVelocity_res = interp1(time, outVelocity, resTime);

    data{ix} = [apu_w_res;phi_res;vn_res;vn_apu_res;compRPM_res;power_res];

end
end

