function data = prepareTrainingData(out,sampleStep, scaleFactor, removeInitEffect)
%PREPARETRAININGDATA takes as input the Simulink.SimulationOutputs and
%returns a cell array with the trainning inputs and outputs

caseNum = length(out);
data={};
if removeInitEffect==0
    removeInit = 1;
    removeEnd = 0;
else
    removeInit = removeInitEffect;
    removeEnd = removeInitEffect;

for ix =1:caseNum
    time = out(ix).tout(removeInit:end-removeEnd);
    compRPM = out(ix).logsout{1}.Values.Data(removeInit:end-removeEnd);
    phi = out(ix).logsout{2}.Values.Data(removeInit:end-removeEnd);
    vn = out(ix).logsout{3}.Values.Data(removeInit:end-removeEnd);
    power = out(ix).logsout{5}.Values.Data(removeInit:end-removeEnd);
    surgeMargin = out(ix).logsout{4}.Values.Data(removeInit:end-removeEnd);
    globEff = out(ix).logsout{6}.Values.Data(removeInit:end-removeEnd);
    RPMref = out(ix).logsout{7}.Values.Data(removeInit:end-removeEnd);

    % temperature/ pressure at thermodynamic stage 1 - Compressor input
    % t1 = out(ix).simlog_sscfluids_brayton_cycle.Ts_1.Pressure_Temperature_Sensor_G.T.series.values;
    % p1 = out(ix).simlog_sscfluids_brayton_cycle.Ts_1.Pressure_Temperature_Sensor_G.P.series.values;
    % 
    % % temperature/ pressure at thermodynamic stage 2 - Burner input
    t2 = out(ix).simlog_sscfluids_brayton_cycle.Ts_2.Pressure_Temperature_Sensor_G.T.series.values;
    t2 = t2(removeInit:end-removeInitEffect);

    p2 = out(ix).simlog_sscfluids_brayton_cycle.Ts_2.Pressure_Temperature_Sensor_G.P.series.values;
    p2 = p2(removeInit:end-removeInitEffect);

    % 
    % % temperature/ pressure at thermodynamic stage 3 - Turbine input   
    t3 = out(ix).simlog_sscfluids_brayton_cycle.Ts_3.Pressure_Temperature_Sensor_G.T.series.values;
    t3 = t3(removeInit:end-removeInitEffect);
    p3 = out(ix).simlog_sscfluids_brayton_cycle.Ts_3.Pressure_Temperature_Sensor_G.P.series.values;
    p3 = p3(removeInit:end-removeInitEffect);

    % 
    % % temperature/ pressure at thermodynamic stage 4 - APU input
    t4 = out(ix).simlog_sscfluids_brayton_cycle.Ts_4.Pressure_Temperature_Sensor_G.T.series.values;
    t4 = t4(removeInit:end-removeInitEffect);

    p4 = out(ix).simlog_sscfluids_brayton_cycle.Ts_4.Pressure_Temperature_Sensor_G.P.series.values;    
    p4 = p4(removeInit:end-removeInitEffect);

    % % temperature/ pressure at thermodynamic stage 5 - APU output
    t5 = out(ix).simlog_sscfluids_brayton_cycle.Ts_5.Pressure_Temperature_Sensor_G.T.series.values;
    % p5 = out(ix).simlog_sscfluids_brayton_cycle.Ts_5.Pressure_Temperature_Sensor_G.P.series.values;  

    % resample actuation signals
    resTime = 0:sampleStep:max(time);
    phi_res = interp1(time, phi, resTime);
    globEff_res = interp1(time, globEff, resTime);
    compRPM_res = interp1(time, compRPM, resTime);
    power_res = interp1(time, power, resTime);
    surgeMargin_res = interp1(time, surgeMargin, resTime);
    RPMref_res = interp1(time, RPMref, resTime);
    vn_res = interp1(time, vn, resTime);

    % resample physical signals
    % t1_res = interp1(time, t1, resTime);
    t2_res = interp1(time, t2, resTime);
    t3_res = interp1(time, t3, resTime);
    t4_res = interp1(time, t4, resTime);
    % t5_res = interp1(time, t5, resTime);
    % 
    % p1_res = interp1(time, p1, resTime);
    p2_res = interp1(time, p2, resTime);
    p3_res = interp1(time, p3, resTime);
    p4_res = interp1(time, p4, resTime);
    % p5_res = interp1(time, p5, resTime);    


    % minimum data
    data{ix} = [RPMref_res./scaleFactor; phi_res./scaleFactor;...
        compRPM_res./scaleFactor; power_res./scaleFactor; 
        t2_res./scaleFactor;
        t3_res./scaleFactor;
        t4_res./scaleFactor;
        % p2_res./scaleFactor;
        p3_res./scaleFactor;
        % p4_res./scaleFactor;
        % globEff_res./scaleFactor;
        % surgeMargin_res;
        vn_res./scaleFactor;
        ];
end
end

