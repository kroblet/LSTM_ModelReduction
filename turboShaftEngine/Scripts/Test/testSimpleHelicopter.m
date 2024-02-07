classdef testSimpleHelicopter < matlab.unittest.TestCase
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
        function testSimulationROM(testCase)
            % Test to simulate the model and check for errors
            engineMode = 'ROM';
            testCase.loadModel
            set_param([testCase.modelName,'/Engine'],'LabelModeActivechoice', engineMode)
            romSim = sim(testCase.modelName, 'SaveOutput', 'on');
            
            % Verify that the simulation output is not empty
            testCase.verifyNotEmpty(romSim);   
        end
        function testSimulationPhysMod(testCase)
            % Test to simulate the model and check for errors
            engineMode = 'PhysMod';
            testCase.loadModel
            set_param([testCase.modelName,'/Engine'],'LabelModeActivechoice', engineMode)
            refSim = sim(testCase.modelName,'SaveOutput', 'on');
            
            % Verify that the simulation output is not empty
            testCase.verifyNotEmpty(refSim);
        end
    end
    
end