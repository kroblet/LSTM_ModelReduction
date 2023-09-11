function results = getLSTMResponses(TX, VY, net)

numCases = size(TX,2);
for idx=1:numCases
    X = TX{idx};
    TY = VY{idx};
    
    net = resetState(net);
    offset = 1;
    [net,~] = predictAndUpdateState(net,X(:,1:offset));
    
    numTimeSteps = size(X,2);
    numPredictionTimeSteps = numTimeSteps - offset;
    Y = zeros(size(TY,1),numPredictionTimeSteps);
    
    
    for t = 2:numPredictionTimeSteps
        Xt = [X(1,t-1);Y(:,t-1)];
        [net,Y(:,t)] = predictAndUpdateState(net,Xt);
    end

    results{idx} = Y;
end