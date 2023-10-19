function compareSimulationPerformance(refOut,romOut)
%COMPARESIMULATIONS Summary of this function goes here
%   Detailed explanation goes here
figure
ax1 = subplot(2,1,1);
ax2 = subplot(2,1,2);

ref.init = refOut.SimulationMetadata.TimingInfo.InitializationElapsedWallTime;
ref.execution = refOut.SimulationMetadata.TimingInfo.ExecutionElapsedWallTime;
ref.total = refOut.SimulationMetadata.TimingInfo.TotalElapsedWallTime;
baseline = [ref.init ref.execution ref.total];

rom.init = romOut.SimulationMetadata.TimingInfo.InitializationElapsedWallTime;
rom.execution = romOut.SimulationMetadata.TimingInfo.ExecutionElapsedWallTime;
rom.total = romOut.SimulationMetadata.TimingInfo.TotalElapsedWallTime;
reduced = [rom.init rom.execution rom.total];

categories = categorical({'Initialization','Execution','Total'});
barh(ax1, categories, [baseline;reduced])
xlabel(ax1,'Time (s)')
legend(ax1, {'Simscape model', 'LSTM ROM'})
grid(ax1,'on')

timereduction = (baseline-reduced)./baseline.*100;
barh(ax2, categories, timereduction, 0.3)
xlabel(ax2,'Time reduction (%)')
grid(ax2,'on')


end

