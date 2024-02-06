classdef testWorkflows < matlab.unittest.TestCase
    properties
        modelName = 'simpleHelicopter';
    end
    methods (TestMethodSetup)
        function loadModel(testCase)
            % Load the model before each test
            load_system(testCase.modelName);
        end
    end
    
    methods (TestMethodTeardown)
        function closeModel(testCase)
            % Close the model after each test
            close_system(testCase.modelName,0);
        end
    end
    
    methods (Test)
        function testTurboshaftReduction(testCase)
            % Test to simulate the model and check for errors
            startup; 
            initialization;
            addpath(fullfile(proj.RootFolder,"turboShaftEngine", "Scripts","Initialization"));
            addpath(fullfile(proj.RootFolder, "turboShaftEngine", "Models", "Components", "turboShaftEngineLSTM_ROM"));
            net_tN_Path = fullfile(proj.RootFolder, "turboShaftEngine", "Models", "Components", "turboShaftEngineLSTM_ROM","turboshaft_ROM_v6.mat");
            net_Path = fullfile(proj.RootFolder, "turboShaftEngine", "Models", "Components", "turboShaftEngineLSTM_ROM","turboshaft_ROM_v5.mat");
            run('turboshaftReduction.mlx')    
        end

    end
    
end
