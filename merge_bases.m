function [I] = merge_bases(W)
    h = 45;
    w = 42;
    n = size(W, 2);
    
    nCols = 15;
    nRows = ceil(n / nCols);
    
    I = zeros(h * nRows, w * nCols);
    for i=1:n
        row = ceil(i/nCols);
        col = mod(i - 1, nCols) + 1;
        
        wi = W(:, i) / max(W(:, i));
        wi = W(:, i);
        I( (row-1)*h + 1 : row*h, (col-1)*w + 1 : col*w) = reshape(wi, h, w);
        %I( (row-1)*h + 1 : row*h, (col-1)*w + 1 : col*w) = histeq(reshape(wi, h, w));
    end
    
    if n < nCols
        I = I(:, 1:w * n);
    end
end