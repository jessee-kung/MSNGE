function [X_train, X_test, Label_train, Label_test] = build_lopo(X, Label, p)
    % Input:
    % X:      Original data, m-by-n matrix, where m is data dimension, n is
    %         data counts
    % Label:  Label of each dominant submanifolds, n-by-c matrix
    %
    %         IMPORTANT!
    %         Label(:, 1) should be Person label for
    %         leave-one-person-out evaluation strategy
    %
    % Output:
    % X_train:  Training data
    % X_test:   Testing data
    
    id_test = false(size(Label, 1), 1);
    for i=1:size(p, 2)
        id_test( Label(:, 1) == p(i) ) = true;
    end
    id_train = ~id_test;
    
    X_test = X(:, id_test);
    X_train = X(:, id_train);
    
    Label_test = Label(id_test, :);
    Label_train = Label(id_train, :);
end