mdlName = 'turboShaft_Harness1';


shaftDamp = 0.001:0.1:1;
rotDamp = 0.001:0.1:1;
core = 0.01:0.1:1;

[sD, rD, cD] = ndgrid(shaftDamp, rotDamp, core);
% simIn(1:size(sD,1),1:size(sD,2)) = Simulink.SimulationInput(mdlName);
simIn(1:size(sD,1),1:size(sD,2),1:size(sD,3)) = Simulink.SimulationInput(mdlName);


for ix = 1:size(sD,1)
    for iy = 1:size(sD,2)
        for iz = 1: size(sD,3)
            simIn(ix,iy,iz) = simIn(ix,iy,iz).setVariable('shaftDamping',sD(ix,iy,iz));
            simIn(ix,iy,iz) = simIn(ix,iy,iz).setVariable('rotorDamping',rD(ix,iy,iz));
            simIn(ix,iy,iz) = simIn(ix,iy,iz).setVariable('coreArea',cD(ix,iy,iz));
        end
            
    end
end

%%
out = parsim(simIn, 'ShowSimulationManager','on', 'UseFastRestart','on');