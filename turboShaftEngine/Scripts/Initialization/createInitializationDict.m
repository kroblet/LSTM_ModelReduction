initialization;
myDictionaryObj = Simulink.data.dictionary.open('initialization.sldd');
importFromBaseWorkspace(myDictionaryObj,'varList',...
{'burner', 'chassis', 'compressor', 'coreArea', 'coreDiameter', 'coreHydrDiameter',...
'exhaust', 'fixedStepSize', 'g', 'height', 'initConditions', 'inlet', ...
'nozzle', 'Qin', 'Qin_time', 'rom', 'rotor', 'rotorDamping', 'sampleTime', ...
'shaft', 'shaftDamping', 'shaftFTP', 'turbine', 'turbineFPT'});
myDictionaryObj.saveChanges;
clear all
startup;