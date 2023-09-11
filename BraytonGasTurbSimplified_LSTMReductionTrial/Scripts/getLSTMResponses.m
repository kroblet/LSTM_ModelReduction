function results = getLSTMResponses(TX, TY, net)

numCases = size(TX,2);
for idx=1:numCases
    X = TX{idx};
    TY = TY{idx};
    
    net = resetState(net);
    offset = 1;
    [net,~] = predictAndUpdateState(net,X(:,1:offset));
    
    numTimeSteps = size(X,2);
    numPredictionTimeSteps = numTimeSteps - offset;
    Y = zeros(sigNumOut,numPredictionTimeSteps);
    
    
    for t = 2:numPredictionTimeSteps
        Xt = [X(1,t-1);Y(:,t-1)];
        [net,Y(:,t)] = predictAndUpdateState(net,Xt);
    end

    results{idx} = Y;
end