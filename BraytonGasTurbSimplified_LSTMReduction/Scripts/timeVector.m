function t = timeVector(time,stairOffset)

    t = zeros(1,2*length(v));
    for ix =1:2:numel(n)
        idx = ceil(ix/2);
        t(ix) = time(idx);
        t(ix+1) = time(idx)+stairOffset;
    end
end

