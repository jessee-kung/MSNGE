function [ W, H, norm_list ] = MSNGE(X, W_init, H_init, S, q, use_l1, lambda, itr_max)
    % Multi Subspace Non-negative Graph-Embedding
    %
    % Author:
	%	Jessee Hsin-Wen Kung
	% 
	% Revision:
	% 	1.0  - 20, Feb, 2013 - Original version
	% 	1.1  - 19, Jul, 2013 - Refactor to MSNGE
    %
    % Multimedia Processing Laboratory
    % Dept. of Computer Science, National Tsing-Hua University
    %
    % Input:
    % X:       Original data, m-by-n matrix, where m is data dimension, n is
    %          data counts
    % W_init:  Bases initial, m-by-d matrix, d is number of bases
    % H_init:  Coefficients initial, d-by-n matrix
    % S:       n-by-n-by-c matrix, with (:, :, k) is the similarity matrix
    %          of k-th dominant submanifold
    % q:       c-by-1 matrix, with k-th element as the number of bases
    %          corresponded to k-th dominant submanifold
    % use_l1:  c-by-1 matrix, with k-th element true if the k-th
    %          submanifold is necessary to be evaluated by l1-norm, false
    %          if k-th submanifold is necessary to be evaluated by l2-norm
    % lambda:  c-by-1 matrix, with k-th element as the trade-off for k-th
    %          graph term
    % itr_max: Maximum iterations
    %
    %
    % Output:
    % W:      Bases matrix, m-by-d matrix
    % H:      Coefficients matrix, d-by-n matrix
    % norm_list:  Objective function value for each iteration
    
    
    %% Initialize: Dimension parameters, number of data ., etc.
    [m, n] = size(X);
    d = size(W_init, 2);
    c = size(q, 2);
    if d ~= sum(q)
        error('Error: 2nd Dimension of W_init should be equals to the sum of q');
    end
    
    range = cell(c, 1);
    for k=1:c
        range{k} = sum( q(1:k-1) ) + 1 : sum( q(1:k-1) ) + q(k);
    end
    
    converge_cond = sqrt(m*n) * 1e-6;
    
    %% Initialize: Output parameters
    W = W_init;
    H = H_init;
    norm_list = zeros(itr_max, 1);
    
    
    %% Main iteration start
    for k=1:itr_max
        %% Compute Yw+, Yw-
        S_scaled = compute_scaleS(W, H, S, range, use_l1, true);
        
        Yw_p = zeros(d);
        Yw_n = zeros(d);
        for j=1:c
            Yw_p( range{j}, range{j} ) = H( range{j} , :) * (lambda(j) * diag(sum( S_scaled(:,:,j) ))) * H( range{j} , :)';
            Yw_n( range{j}, range{j} ) = H( range{j} , :) * (lambda(j) * S_scaled(:,:,j)) * H( range{j} , :)';
        end
        Yw_p = Yw_p .* eye(d);
        Yw_n = Yw_n .* eye(d);
        
        
        %% Update W
        W_prev = W;
        W = W .* ( ( X*H' + W * Yw_n ) ./ (  (W*H) * H' + W * Yw_p ) );
        
        
        %% Normalize W and H
        dist_W = sqrt(sum(W.^2));
        W = W ./ repmat( dist_W, m, 1 );
        H = H .* repmat( dist_W', 1, n);
        
        
        %% Compute Yh+, Yh-
        S_scaled = compute_scaleS(W, H, S, range, use_l1, false);
        
        Yh_p = zeros(d, n);
        Yh_n = zeros(d, n);
        for j=1:c
            Yh_p( range{j} , : ) = H( range{j}, :) * (lambda(j) * diag(sum(S_scaled(:,:,j))));
            Yh_n( range{j} , : ) = H( range{j}, :) * (lambda(j) * S_scaled(:,:,j));
        end
        
                
        %% Update H
        H_prev = H;
        H = H .* ( (W' * X + Yh_n) ./ (W' * (W*H) + Yh_p) );
        
        
        %% Record the value of object function
        norm_list( k ) = solve_obj(X, W, H, S, use_l1, lambda, range);
        
        if mod( k , 50) == 0
            disp(['iter = ',num2str( k ),' obj = ',num2str(norm_list( k ))]);
        end
        
        if norm(W - W_prev, 'fro') < converge_cond && norm(H - H_prev, 'fro') < converge_cond
            disp(['Converged @ iter = ', num2str(k)]);
            norm_list = norm_list(1:k);
            break;
        end
        
    end
end



function [ O ] = solve_obj(X, W, H, S, use_l1, lambda, range)
    O = norm(X- W*H, 'fro')^2;
    
    c = size(range, 1);
    n = size(X, 2);
    
    for k=1:c
        if use_l1(k)
            dist_H = zeros(n);
            for i=1:n
                dist_H(:, i) = sqrt(sum(( H(range{k}, :) - repmat( H(range{k}, i), 1, n) ).^2));
            end
            O = O + lambda(k) * sum(sum(dist_H .* S(:, :, k)));
        else
            O = O + lambda(k) * trace( H(range{k}, :) * ( diag(sum(S(:,:,k))) - S(:, :, k) ) * H(range{k}, :)' );
        end
    end
end



function [ S_scaled ] = compute_scaleS(W, H, S, range, use_l1, normalize_by_W)
    c = size(range, 1);
    n = size(H, 2);
    
    if normalize_by_W
        H_scaled = diag( sqrt(sum(W.^2)) ) * H;
    else
        H_scaled = H;
    end
    
    S_scaled = S;
    for k=1:c
        if use_l1(k)
            %% Compute the distance between hi_f and hj_f (f is the index of factor, For example: Expression, Identity)
            dist_H = zeros(n);
            for i=1:n
                dist_H(:, i) = sqrt(sum((H_scaled(range{k}, :) - repmat(H_scaled(range{k}, i), 1, n) ).^2));
            end
            dist_H = dist_H + eye(n)*eps;

            %% Compute the scaled Sij
            S_scaled(:, :, k)  = S_scaled(:, :, k)  ./ dist_H;
        end
    end
end