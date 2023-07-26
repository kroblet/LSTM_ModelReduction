function generateDatasetTq(maxT, name, trainDir)
    time = [0 0.5 0.7 0.8 2];
    torque = [0 maxT maxT 0 0]; 
    sdata = Simulink.SimulationData.Dataset(torque');
    sdata{1}.Values.Time = time';
    sdata{1}.Name = name;
    fileName = fullfile(trainDir, [name '.mat']);

    save(fileName, "sdata")
end