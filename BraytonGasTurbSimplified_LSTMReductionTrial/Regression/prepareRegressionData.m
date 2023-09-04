function regTable = generateTable(XTrain)

auxArray = cat(2, XTrain{:}).*1000;

regTable = table(auxArray(1,:)', auxArray(2,:)');
regTable.Properties.VariableNames = {'Phi', 'N'};