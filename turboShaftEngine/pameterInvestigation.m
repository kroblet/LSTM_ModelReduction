mdlName = 'turboShaft_Harness1';


shaftDamp = 0.1:5:100;
rotDamp = 1:2:500;
core = 0.1:0.1:1;

[sD, rD, cD] = ndgrid(shaftDamp, rotDamp, core);
% simIn(1:size(sD,1),1:size(sD,2)) = Simulink.SimulationInput(mdlName);
simIn(1:size(sD,2)) = Simulink.SimulationInput(mdlName);


% for ix = 1:size(sD,1)
    for iy = 1:size(sD,2)
        % for iz = 1: size(sD,3)
            simIn(iy) = simIn(iy).setVariable('shaftDamping',sD(iy));
            simIn(iy) = simIn(iy).setVariable('rotorDamping',rD(iy));
            simIn(iy) = simIn(iy).setVariable('coreArea',0.3);
        % end
            
    end
% end

%%
parsim(simIn, 'ShowSimulationManager','on', 'UseFastRestart','on')