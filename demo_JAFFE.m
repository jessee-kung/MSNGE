clc;
clear;

%% Initial step: Parameter setting + Dataset setting
% This demo is prepared for Japanese Female Facial Expression (JAFFE) Database
% Please prepare 'JAFFE.mat' according to following instructions:
%
%   1. Get dataset from official URL:
%      http://www.kasrl.org/jaffe.html
%
%   2. Extract all images, crop and rectify images to 45 x 42
%      Notice that the recognition rate of DSNGE was seriously affected by 
%      image registration. With poor registration result, the un-expected
%      variations would be learned to the bases.
%      In our case, we rectify all facial images with RASL [44].
%
%   3. Create 'JAFFE.mat', with following 3 parameters must be exist :
%      (1) X:      M x N double Matrix, N facial images in dimension M,
%                  which is extracted by Step 2 above.
%      (2) Exp:    N x 1 double Matrix, Expression label
%      (3) Person: N x 1 double Matrix, Identity label
%
%      In original paper, M = 1890 (45x42), N = 183
%      'Expression' is ranged in[1,2,3,4,5,6]
%      'Person'     is ranged in [1,2,3,4,5,6,7,8,9,10]
%
%   4. Run this demo
%
dataset_title = 'JAFFE_RASL';
dataset_filename = 'JAFFE.mat';

output_folder = ['data/' , dataset_title];
mkdir(output_folder);

m = 1890;           % Dimension, cropped image should be 45 x 42 = 1890
N_subject = 10;     % Number of identities
dim = 35;           % Number of W Bases
q = [14;21];        % Number of W Bases for identity part and Expression part
lambda = [1 0.15];  % LambdaI (1.0) and LambdaE (0.15)
use_l1 = [0 1];     % Solved by Frobenius norm (0) or L2-1 norm (1) 


%% Initial step: Write all parameters as diary
diary([output_folder, '/diary.txt']);
diary on;
fprintf('Multi-Subspace Nonnegative Graph Embedding\n\n');
fprintf(['Dataset: ', dataset_filename, '\n']);
fprintf('Leave-one-person-out Evaluation Start...!\n\n');


%% Step1. Load data    
if ~exist([output_folder, '/W_MSNGE_001.mat'], 'file');
    
    if ~exist('X', 'var')
        load(dataset_filename);
        load('random.mat');
        clear size;
    end
    
    for i=1:N_subject
        %% Step2. Select testing subject for Leave-One-Person-Out evaluation strategy
        fprintf(['LOPO #', num2str(i), ':\n']);
        [X_train, X_test, Label_train, Label_test] = build_lopo(X, [Person, Exp], i);
        N_train = size(X_train, 2);
        N_test = size(X_test, 2);


        %% Step3. Start solving MSNGE
        fprintf(' >> MSNGE solving ...\n');
        
		S = build_similarityMat(X_train, Label_train);
        [W, H_train, norm_list] = MSNGE(X_train, fix_W_init(1:m, 1:dim), fix_H_init(1:dim, 1:N_train), S, q, use_l1, lambda, 4000);
		
        %% Step4. Start solving testing samples
        H_test = zeros(dim, N_test); 
        for j=1:N_test
            H_test(:, j) = solve_lsq_h(W, fix_H_init(1:dim, 1), X_test(:, j), 500);
        end
        
        save([output_folder, '/W_MSNGE_', num2str(i, '%.3d'), '.mat'], 'W', 'H_train', 'H_test', 'Label_train', 'Label_test', 'N_train', 'N_test', 'norm_list');
    end

end


conf_mat = zeros(6, 6);
for i=1:N_subject
    load([output_folder, '/W_MSNGE_', num2str(i, '%.3d'), '.mat']);
    
    %% Step5. KNN Classifier (with K = 1)
    Exp_test_predict = NN_classifier(H_train(q(1)+1:q(1)+q(2), :), H_test( q(1)+1:q(1)+q(2), : ), Label_train(:, 2));
    for j=1:N_test
        conf_mat( Label_test(j, 2), Exp_test_predict(j) ) = conf_mat( Label_test(j, 2), Exp_test_predict(j) ) + 1;
    end
end
conf_mat

perf = sum(diag(conf_mat(:, :))) / sum(sum(conf_mat(:, :)));
disp(['Overall accuracy: ', num2str(perf)]);

%% Step6. Output result
% Step6.1. Display expression part + original images for expression label 4 (smile)
X_orig = merge_bases(W * H_train(:, Label_train(:, 2) == 4));
WHe_reconstruct = merge_bases(W(:, 15:35) * H_train(15:35, Label_train(:, 2) == 4));
figure('name', 'Expression part reconstruction (Expression = 4)');
imshow( [X_orig;  WHe_reconstruct] );


% Step6.2. Display identity part + original images for identity 1
X_orig = merge_bases(W * H_train(:, Label_train(:, 1) == 1));
WHi_reconstruct = merge_bases(W(:, 1:14) * H_train(1:14, Label_train(:, 1) == 1));
figure('name', 'Identity part reconstruction (Identity = 1)');
imshow( [X_orig;  WHi_reconstruct] );


% Step6.3. Plot convergence trend
figure('name', 'Convergence trend');
plot(norm_list);
xlabel('Iteration');
ylabel('Objective Value');

diary off;