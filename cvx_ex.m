clc;
clear all;
close all;
%% example cvx script



% A 1-norm minimization; constrained optimization problem
if 0
    A = randn(5,3);
    b = randn(5,1);
    cvx_begin
        variable x(3);
        minimize(norm(A*x - b, 1))
        subject to
            -0.5 <= x;
            x <= 0.3;
    cvx_end
end       

% A lasso problem
m = 100;
n = 64;
A = randn(m,n);
b = randn(m,1);
lambda1 = 0.1;
if 1
    cvx_begin
        variable x(n)
        minimize(norm((A*x - b), 2) + lambda1*norm(x,1))
        subject to
            -5 <= x;
            x <= 5;
    cvx_end
end