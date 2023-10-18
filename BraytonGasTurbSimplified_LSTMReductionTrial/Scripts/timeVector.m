function t = timeVector(time,stairOffset)

    t = zeros(1,2*length(time));
    for ix =1:2:numel(t)
        idx = ceil(ix/2);
        t(ix) = time(idx);
        t(ix+1) = time(idx)+stairOffset;
    end
    time(end)=time(end)+1;
end

