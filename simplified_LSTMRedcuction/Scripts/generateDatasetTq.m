function generateDatasetTq(maxT, name, trainDir)
    % Trapezoidal input
    time = [0 0.5 0.7 0.8 2];
    torque = [0 maxT maxT 0 0]; 
    sdata = Simulink.SimulationData.Dataset(torque');
    sdata{1}.Values.Time = time';
    sdata{1}.Name = name;
    fileName = fullfile(trainDir, [name '_trap' '.mat']);
    save(fileName, "sdata")

    % Positive Step input
    time = [0 0.5 1 1 2];
    torque = [0 0 0 maxT maxT]; 
    sdata = Simulink.SimulationData.Dataset(torque');
    sdata{1}.Values.Time = time';
    sdata{1}.Name = name;
    fileName = fullfile(trainDir, [name '_posStep' '.mat']);
    save(fileName, "sdata")

    % Negative Step input
    time = [0 0.5 1 1 2];
    torque = [0 0 0 -maxT -maxT]; 
    sdata = Simulink.SimulationData.Dataset(torque');
    sdata{1}.Values.Time = time';
    sdata{1}.Name = name;
    fileName = fullfile(trainDir, [name '_negStep' '.mat']);
    save(fileName, "sdata")

    % Zero input
    time = [0 0 0 0 0];
    torque = [0 0 0 0 0]; 
    sdata = Simulink.SimulationData.Dataset(torque');
    sdata{1}.Values.Time = time';
    sdata{1}.Name = name;
    fileName = fullfile(trainDir, [name '_zero' '.mat']);
    save(fileName, "sdata")    
    
    % Const input
    time = [0 0 0 0 0];
    torque = [maxT maxT maxT maxT maxT]; 
    sdata = Simulink.SimulationData.Dataset(torque');
    sdata{1}.Values.Time = time';
    sdata{1}.Name = name;
    fileName = fullfile(trainDir, [name '_zero' '.mat']);
    save(fileName, "sdata")  


end