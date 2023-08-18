function fileList = listSimInpFiles(scenarioDir)
%SIMINPFILELIST Summary of this function goes here
%   Detailed explanation goes here
aux = dir(scenarioDir); 
fileList={};
ik = 1;
for ix=1:length(aux)
    if contains(aux(ix).name, '.mat')
        fileList{ik} = aux(ix).name;
        ik = ik+1;
    end
end

end

