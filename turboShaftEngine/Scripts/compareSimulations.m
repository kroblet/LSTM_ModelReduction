function compareSimulations(refOut,romOut)
%COMPARESIMULATIONS Summary of this function goes here
%   Detailed explanation goes here
figure
ref.init = refOut.SimulationMetadata.TimingInfo.InitializationElapsedWallTime;
ref.execution = refOut.SimulationMetadata.TimingInfo.ExecutionElapsedWallTime;
ref.total = refOut.SimulationMetadata.TimingInfo.TotalElapsedWallTime;
baseline = [ref.init ref.execution ref.total];

rom.init = romOut.SimulationMetadata.TimingInfo.InitializationElapsedWallTime;
rom.execution = romOut.SimulationMetadata.TimingInfo.ExecutionElapsedWallTime;
rom.total = romOut.SimulationMetadata.TimingInfo.TotalElapsedWallTime;
reduced = [rom.init rom.execution rom.total];

categories = categorical({'Initialization','Execution','Total'});
bar(categories, [baseline;reduced])
ylabel('Time(s)')
grid on

end

