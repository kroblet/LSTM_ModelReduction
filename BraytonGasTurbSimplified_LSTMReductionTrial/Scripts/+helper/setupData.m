function [X,Y] = setupData(Xorig,Yorig,chunkSize,numFeatures)

    nSamples = length(Yorig);
    nElems = floor(nSamples/chunkSize);
    X = cell(nElems+1,1);
    Y = cell(nElems+1,1);

    for ii = 1:nElems
        idxStart = 1+(ii-1)*chunkSize;
        idxEnd = ii*chunkSize;
        X{ii} = Xorig(1:numFeatures,idxStart:idxEnd);
        Y{ii} = Yorig(idxStart:idxEnd);
    end
    X{end} = Xorig(1:numFeatures,idxEnd+1:end);
    Y{end} = Yorig(idxEnd+1:end);

end