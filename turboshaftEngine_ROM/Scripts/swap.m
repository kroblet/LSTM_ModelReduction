function array = swap(array,ind1, ind2, dim)
%SWAP takes as input an array and swaps the elements of ind1, ind2
if dim == 1
    aux = array(ind1);
    array(ind1) = array(ind2);
    array(ind2) = aux;

elseif dim == 2
    aux = array(ind1,:);
    array(ind1,:) = array(ind2,:);
    array(ind2,:) = aux;

elseif dim == 3
    aux = array(:,ind1);
    array(:,ind1) = array(:,ind2);
    array(:,ind2) = aux;

end

end

