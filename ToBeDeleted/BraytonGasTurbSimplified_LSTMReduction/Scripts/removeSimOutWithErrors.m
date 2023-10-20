function cleanOut =  removeSimOutWithErrors(out)
idx = 1;
aux = length(out);
while idx <= aux
    if ~isempty(out(idx).ErrorMessage)
        out(idx) = [];
    else
        idx=idx+1;
    end
    aux = length(out);
end

cleanOut = out;
end
