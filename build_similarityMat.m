function [ S ] = build_similarityMat(X, Label)
    % Input:
    % X:      Original data, m-by-n matrix, where m is data dimension, n is
    %         data counts
    % Label:  Label of each dominant submanifolds, n-by-c matrix
    %
    % Output:
    % S:      n-by-n-by-c matrix, where (:, :, k) is the similarity matrix
    %         of k-th dominant submanifold

    %% Step1. Compute distance for each vector pairs
    [~,n] = size(X);
    c = size(Label, 2);
    D = zeros(n);
    for i=1:n
        D(:, i) = sqrt(sum(( repmat(X(:, i), 1, n) - X ).^2 ))';
    end
    
    %% Step2. Compute similarity matrix by distance of vector (i.e. exp( -D(xi, xj) / sigma^2 )
    sigma_exp = sum(sum(triu(D))) / ( n * (n+1) / 2 );
    S_exp = exp(-D.^2 / sigma_exp^2);
    
    %% Step3. Build similarity graph for each dominant manifold
    S = zeros(n, n, c);
    for i=1:c
        S(:, :, i) = S_exp .* (repmat(Label(:, i), 1, n) == repmat(Label(:, i)', n, 1));
        S(:, :, i) = S(:, :, i) - eye(n);
    end
end