function [data,names] = reorderData(data, names, firstNames)
%REORDERDATA takes a dataset and a cell array of names and reorders the data 
% in each array so that the first names will be at first
%   Detailed explanation goes here

% find indices to swap
indNew = 1:length(firstNames);
indOld = zeros(1,indNew(end));

for ix=1:indNew(end)
    ik=1;
    while ik < length(names) && not(strcmp(names(ik), firstNames{ix}))
        ik = ik+1;
    end

    if strcmp(names(ik), firstNames(ix))
        indOld(ix) = ik;
        names = swap(names, indNew(ix), indOld(ix), 1);

    else
        disp('There is a mystyped name in the "firstNames"')
    end
end


% rearange data
for iz=1:numel(data)
    for ix=1:indNew(end)
        data{iz} = swap(data{iz},indNew(ix),indOld(ix),2);
    end
end

end
