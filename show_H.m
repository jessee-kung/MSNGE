function show_H(H, Label, q, k)   
    HH = sortrows([Label(:, k), H(sum( q(1:k-1) ) + 1 : sum( q(1:k-1) ) + q(k), :)'], 1);
    imshow(HH(:, 2:end)', []);
end