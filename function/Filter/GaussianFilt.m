function [TMP] = GaussianFilt(tmp,range,Sigma,dim)
%GAUSSIANFILT Gaussian filter with range and sigma you set
%   'dim' is time dimention. if 'tmp' have only one dimention, don't
%   neet'dim'.

% make gaussian filter
w = ceil(range/2);
W = [1:range] - w;
F = 1/sqrt(2*pi*Sigma^2) * exp(-1 * (W).^2 / (2*Sigma^2));

% check data form
if ~exist('dim')
    if size(tmp,1) == 1
        TMP = filtering(tmp,range,F,w);
    else
        tmp = tmp.';
        TMP = filtering(tmp,range,F,w);
        TMP = TMP.';
    end
else
    if dim ==2
        TMP = filtering(tmp,range,F,w);
    else
        tmp = tmp.';
        TMP = filtering(tmp,range,F,w);
        TMP = TMP.';
    end
end
end

function[TMP] = filtering(tmp,range,F,w)
[R,T] = size(tmp,[1 2]);
TMP = zeros(R, T+range-1);
F = repmat(F,R,1);

% filtering
for i = 1:T
    TMP(: , i:i+range-1)  = TMP(: , i:i+range-1) + tmp(:,i) .* F;
end

% deleta stretch data
TMP(:, 1:w) = [];
TMP(:, T+1:end) = [];
end

