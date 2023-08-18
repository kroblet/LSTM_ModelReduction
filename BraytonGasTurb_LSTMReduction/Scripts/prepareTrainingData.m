function data = prepareTrainingData(out,sampleStep)
%PREPARETRAININGDATA takes as input the Simulink.SimulationOutputs and
%returns a cell array with the trainning inputs and outputs

caseNum = length(out);
data={};

for ix =1:caseNum
    time = out(ix).tout;
    compRPM = out(ix).logsout{1}.Values.Data;
    compRPM_ref = out(ix).logsout{7}.Values.Data;
    apu_w = ones(length(time), 1)*out(ix).logsout{2}.Values.Data;
    phi = out(ix).logsout{3}.Values.Data;
    vn = out(ix).logsout{4}.Values.Data;
    power = out(ix).logsout{5}.Values.Data;
    surgeMargin = out(ix).logsout{6}.Values.Data;
    vn_apu = ones(length(time), 1)*out(ix).logsout{8}.Values.Data;

    % temperature/ pressure at thermodynamic stage 1 - Compressor input
    t1 = out(ix).simlog_sscfluids_brayton_cycle.Ts_1.Pressure_Temperature_Sensor_G.T.series.values;
    p1 = out(ix).simlog_sscfluids_brayton_cycle.Ts_1.Pressure_Temperature_Sensor_G.P.series.values;

    % temperature/ pressure at thermodynamic stage 2 - Burner input
    t2 = out(ix).simlog_sscfluids_brayton_cycle.Ts_2.Pressure_Temperature_Sensor_G.T.series.values;
    p2 = out(ix).simlog_sscfluids_brayton_cycle.Ts_2.Pressure_Temperature_Sensor_G.P.series.values;

    % temperature/ pressure at thermodynamic stage 3 - Turbine input   
    t3 = out(ix).simlog_sscfluids_brayton_cycle.Ts_3.Pressure_Temperature_Sensor_G.T.series.values;
    p3 = out(ix).simlog_sscfluids_brayton_cycle.Ts_3.Pressure_Temperature_Sensor_G.P.series.values;

    % temperature/ pressure at thermodynamic stage 4 - APU input
    t4 = out(ix).simlog_sscfluids_brayton_cycle.Ts_4.Pressure_Temperature_Sensor_G.T.series.values;
    p4 = out(ix).simlog_sscfluids_brayton_cycle.Ts_4.Pressure_Temperature_Sensor_G.P.series.values;    

    % temperature/ pressure at thermodynamic stage 5 - APU output
    t5 = out(ix).simlog_sscfluids_brayton_cycle.Ts_5.Pressure_Temperature_Sensor_G.T.series.values;
    p5 = out(ix).simlog_sscfluids_brayton_cycle.Ts_5.Pressure_Temperature_Sensor_G.P.series.values;  

    % resample actuation signals
    resTime = 0:sampleStep:max(time);
    apu_w_res = interp1(time, apu_w, resTime);
    phi_res = interp1(time, phi, resTime);
    vn_res = interp1(time, vn, resTime);
    vn_apu_res = interp1(time, vn_apu, resTime);
    compRPM_res = interp1(time, compRPM, resTime);
    compRPM_ref_res = interp1(time, compRPM_ref, resTime);
    power_res = interp1(time, power, resTime);
    surgeMargin_res = interp1(time, surgeMargin, resTime);

    % resample physical signals
    t1_res = interp1(time, t1, resTime);
    t2_res = interp1(time, t2, resTime);
    t3_res = interp1(time, t3, resTime);
    t4_res = interp1(time, t4, resTime);
    t5_res = interp1(time, t5, resTime);

    p1_res = interp1(time, p1, resTime);
    p2_res = interp1(time, p2, resTime);
    p3_res = interp1(time, p3, resTime);
    p4_res = interp1(time, p4, resTime);
    p5_res = interp1(time, p5, resTime);    

    % data{ix} = [apu_w_res;phi_res;vn_res;vn_apu_res;compRPM_res;power_res;surgeMargin_res...
    %     t1_res;t2_res;t3_res;t4_res;t5_res;...
    %     p1_res;p2_res;p3_res;p4_res;p5_res];

    % % trainning data without power
    % data{ix} = [apu_w_res;phi_res;vn_res;vn_apu_res;compRPM_res;surgeMargin_res;...
    % t1_res;t2_res;t3_res;t4_res;t5_res;...
    % p1_res;p2_res;p3_res;p4_res;p5_res];

    % minimum data
    data{ix} = [phi_res;vn_res;surgeMargin_res;...
                t3_res; compRPM_res];
end
end

