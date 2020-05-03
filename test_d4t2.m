clear; clc;

addpath  ./alg
addpath  ./Tensorlab
addpath ./loss
n=20;
dim = [	n  n n  n ]; sz = dim;
r = 5;
t=2;
MaxIter = 2000;

%%%%%% setting
omega = abs(randn(r,1));
Omega = diag(omega);
A01 = rand(dim(1),r)-1/2; A01 = column_normalization(A01); A1= A01*Omega;
B1 = rand(dim(2),r)-1/2; B1 = column_normalization(B1);
C1 = rand(dim(3),r)-1/2;
[P,L,Q] = svd(C1,'econ');
C1 = P;
D1 = rand(dim(4),r)-1/2;
[P,L,Q] = svd(D1,'econ');
D1 = P;
Utrue = {A1,B1,C1 ,D1};

A0 = rand(dim(1),r)-1/2; A0 = column_normalization(A0);
B0 = rand(dim(2),r)-1/2; B0 = column_normalization(B0);
C0 = rand(dim(3),r)-1/2;
[P,L,Q] = svd(C0,'econ');
C0 = P;
D0 = rand(dim(4),r)-1/2;
[P,L,Q] = svd(D0,'econ');
D0 = P;
U00 = {A0,B0,C0,D0 };
U1={A1,B1,C1,D1 };
T1 = cpdgen(U1);
N = randn(dim);
delta = 0.05;
outlier_percent = 0.0;
Cauchy_noise = delta*tan(pi*(rand(dim)-0.5));
noise_level = 0.5;
T = T1/frob(T1)+ noise_level* Cauchy_noise/frob(Cauchy_noise) + get_outlier_uniform( size(T1),outlier_percent, 10 );
%%%% end of the setting of the problem


options.TolX =  1e-6;
options.MaxIter = MaxIter;
options.t = t;
options.loss_weight = @cauchy;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%HQ-ADMM
sigma_array = abs(randn(r,1));
options.tau = 0.7;
options.delta = 0.05;   % or 0.01

options.e1 = 0.00000001; options.e2 = 0.00000001;
tic
[U,sigma_array,out] = hq_admm_robust_orthogonal_approx(T,U00,sigma_array,options);
t_admm=toc;
iter_admm = out.iterations;
U1 = U; U1{1} = U1{1}*diag(sigma_array); est_T = cpdgen(U1);
err_admm = frob(est_T/frob(est_T)-T1/frob(T1));

fprintf('relerr: hq-admm = %.2f, time = %.2f, iter = %d\n',err_admm,t_admm,iter_admm)







