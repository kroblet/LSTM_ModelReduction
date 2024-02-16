function n = stairVector(v)
    n = zeros(1,2*length(v));
    for ix =1:2:numel(n)
        idx = ceil(ix/2);
        n(ix) = v(idx);
        n(ix+1) = v(idx);
    end