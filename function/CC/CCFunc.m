function [R] = CCFunc(X,XX)
%CCFUNC corralation coefficient for 1 or 2 matrix
%
% X = (M x T x NTrial)
% XX = (N x T x NTrial) or NaN
% cc = (M x 1) or (M x N)    
%
% If XX is nothing, you can find the average of CC to x(m x T) between N
% trials.
% If XX is matrix, you can find the average of CC to xx(n x T) and x(m x
% T x nTrial) 

if exist('XX','var') == 0
    R = CC_1data(X);
else
    R = CC_2data(X,XX);
end
end

function [result] = CC_1data(X)
M = numel(X(:,1,1));
NT = numel(X(1,1,:));
result = zeros(M,1);
for i = 1:M
    A(:,:) = X(i,:,:);
    cc = corrcoef(A);
    SUM = 0;
    NN = 0;
    for j = 1:NT - 1
        SUM = SUM + sum(cc(1+j,1:j));    
        NN = NN + j;
    end
    result(i,1) = SUM/NN;
end
end

function [result] = CC_2data(X,XX)
M = numel(X(:,1,1));
N = numel(XX(:,1,1));
NT = numel(XX(1,1,:));
result = zeros(M,N);
for i = 1:M
    A(:,:) = X(i,:,:);
    for ii = 1:N
        B(:,:) = XX(ii,:,:);
        SUM = 0;
        for j = 1:NT
            cc = corrcoef(A(:,j),B(:,j));
            SUM = SUM + cc(1,2);
        end
        result(i,ii) = SUM/NT;
    end
end
end
