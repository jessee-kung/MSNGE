# MSNGE
Matlab Implementation of Dual Subspace Nonnegative Graph Embedding (DSNGE), with multiple subspace support.

## Usage

Please refer to following instructions to call function ```MSNGE```:
```MATLAB
function [ W, H, norm_list ] = MSNGE(X, W_init, H_init, S, q, use_l1, lambda, itr_max)
```

Input:
```
X:       Original data, m-by-n matrix, where m is data dimension, n is data counts
W_init:  Bases initial, m-by-d matrix, d is number of bases
H_init:  Coefficients initial, d-by-n matrix
S:       n-by-n-by-c matrix, with (:, :, k) is the similarity matrix of k-th dominant submanifold
q:       c-by-1 matrix, with k-th element as the number of bases corresponded to k-th dominant submanifold
use_l1:  c-by-1 matrix, with k-th element true if the k-th submanifold is necessary to be evaluated by l1-norm, false if k-th submanifold is necessary to be evaluated by l2-norm
lambda:  c-by-1 matrix, with k-th element as the trade-off for k-th graph term
itr_max: Maximum iterations
```

Output:
```
W:      Bases matrix, m-by-d matrix
H:      Coefficients matrix, d-by-n matrix
norm_list:  Objective function value for each iteration
```


## Demo with JAFFE Database

The demo is prepared for Japanese Female Facial Expression (JAFFE) Database[35]. For copyright reason, we cannot provide JAFFE database directly. Please prepare your 'JAFFE.mat' according to following instructions:

1. Get dataset from official URL:  
http://www.kasrl.org/jaffe.html
 
2. Extract all images, crop and rectify images to 45 x 42. Please notice that the recognition rate of DSNGE is seriously affected by image registration. With poor registration result, the un-expected variations would be learned to the bases. In our case, we rectify all facial images with RASL [44], which helps DSNGE achieves the best recognition result in facial expression recognition.
 
3. Create 'JAFFE.mat', with following 3 parameters must be exist:  
	```
	X:		M x N double Matrix, N facial images in dimension M
	Exp:    N x 1 double Matrix, Expression label
	Person: N x 1 double Matrix, Identity label
	```
	In original paper, M = 1890 (45x42), N = 183, label ```Exp``` is ranged in ```[1,2,3,4,5,6]```, and label ```Person``` is ranged in ```[1,2,3,4,5,6,7,8,9,10]```.
 
4. Run the demo with 'demo_JAFFE.m'


## Related Publication

All information (including all source code) is provided for non-commercial research purpose only. If you use this code/model for your research or experimental result comparison, please cite our original paper:

H-W. Kung, Y-H. Tu, and C-T. Hsu, "Dual Subspace Nonnegative Graph Embedding for Identity-Independent Expression Recognition, " IEEE Trans. Information Forensics and Security, vol. 10, no.3, pp.626-639, Mar. 2015.

```
@Article{DSNGE_TIFS15,
	author = {Hsin-Wen Kung, Yi-Han Tu, and Chiou-Ting Hsu},
	title = {Dual Subspace Nonnegative Graph Embedding for Identity-Independent Expression Recognition},
	journal = {IEEE Transactions on Information Forensics and Security},
	volume = {10},
	number = {3},
	month = {March},
	year = {2015},
	pages = {626-639}
}
```

## References

[35] M. Lyons, S. Akamatsu, M. Kamachi, and J. Gyoba, "Coding facial expressions with Gabor wavelets,” in Proc. 3rd IEEE Int. Conf. Autom. Face Gesture Recognit., Apr. 1998, pp. 200–205.
     
[44] Y. Peng, A. Ganesh, J. Wright, W. Xu, and Y. Ma, "RASL: Robust alignment by sparse and low-rank decomposition for linearly correlated images," IEEE Trans. Pattern Anal. Mach. Intell., vol. 34, no. 11, pp. 2233–2246, Nov. 2012.
