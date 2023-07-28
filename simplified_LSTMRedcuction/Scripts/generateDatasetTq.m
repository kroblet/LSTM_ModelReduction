function generateDatasetTq(maxT, name, trainDir,simStopTime)
    % Positive trapezoidal input
    time = [0 0.5 0.7 0.8 simStopTime];
    torque = [0 maxT maxT 0 0]; 
    sdata = Simulink.SimulationData.Dataset(torque');
    sdata{1}.Values.Time = time';
    sdata{1}.Name = name;
    fileName = fullfile(trainDir, [name '_posTrap' '.mat']);
    save(fileName, "sdata")
        
    % Negative trapezoidal input
    time = [0 0.5 0.7 0.8 simStopTime];
    torque = [0 -maxT -maxT 0 0]; 
    sdata = Simulink.SimulationData.Dataset(torque');
    sdata{1}.Values.Time = time';
    sdata{1}.Name = name;
    fileName = fullfile(trainDir, [name '_negTrap' '.mat']);
    save(fileName, "sdata")

    % Positive Step input
    time = [0 0.5 1 1 2 simStopTime];
    torque = [0 0 0 maxT maxT 0]; 
    sdata = Simulink.SimulationData.Dataset(torque');
    sdata{1}.Values.Time = time';
    sdata{1}.Name = name;
    fileName = fullfile(trainDir, [name '_posStep' '.mat']);
    save(fileName, "sdata")

    % Negative Step input
    time = [0 0.5 1 1 2 simStopTime];
    torque = [0 0 0 -maxT -maxT 0]; 
    sdata = Simulink.SimulationData.Dataset(torque');
    sdata{1}.Values.Time = time';
    sdata{1}.Name = name;
    fileName = fullfile(trainDir, [name '_negStep' '.mat']);
    save(fileName, "sdata")

    % Zero input
    time = [0 simStopTime];
    torque = [0 0]; 
    sdata = Simulink.SimulationData.Dataset(torque');
    sdata{1}.Values.Time = time';
    sdata{1}.Name = name;
    fileName = fullfile(trainDir, [name '_zero' '.mat']);
    save(fileName, "sdata")    
    
    % Positive constant input
    time = [0 2 simStopTime];
    torque = [maxT maxT 0]; 
    sdata = Simulink.SimulationData.Dataset(torque');
    sdata{1}.Values.Time = time';
    sdata{1}.Name = name;
    fileName = fullfile(trainDir, [name '_posConst' '.mat']);
    save(fileName, "sdata")  

    % Negative constant input
    time = [0 2 simStopTime];
    torque = [-maxT -maxT 0]; 
    sdata = Simulink.SimulationData.Dataset(torque');
    sdata{1}.Values.Time = time';
    sdata{1}.Name = name;
    fileName = fullfile(trainDir, [name '_negConst' '.mat']);
    save(fileName, "sdata")  
end