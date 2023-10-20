function ds = prepareDatastore(X, Y)

dsXTrain = arrayDatastore(X);
dsXTrain = transform(dsXTrain, @(x) x{:});
dsYTrain = arrayDatastore(Y);
dsYTrain = transform(dsYTrain, @(x) x{:});
ds = combine(dsXTrain, dsYTrain);