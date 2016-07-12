function [ Label_test_predict ] = NN_classifier( X_train, X_test, Label_train )
    N_train = size(X_train, 2);
    N_test = size(X_test, 2);
    
    Label_test_predict = zeros(N_test, 1);
    for i=1:N_test        
        [~, id] = min( sum(( X_train - repmat(X_test(:, i), 1, N_train) ).^2) );
        Label_test_predict(i) = Label_train(id);
    end
end