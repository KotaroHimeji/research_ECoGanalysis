function [SmoothData] = Normalize(data,range)
% NORMALIZE Normalize for one dimentional linear data. (éûä‘ê≥ãKâª)
% You can choose the area where thinking for average and sigma to change
% the parameter 'range' like [a b].  
% a:start timing, b:end timing

% check data form 
R = numel(data(:,1)); %rows
C = numel(data(1,:)); %columns
if R == 1
    N = C;
else
    N = R;
end
Average = zeros(R, C);
Sigma = zeros(R, C);
% decide parameter
for i = 1:N
    S = i+range(1);
    E = i+range(2);
    if S < 1
        S = 1;
        if E < 1
            E = 1;
        end
    end
    if E > N
        E = N;
        if S > N
            S = N;
        end
    end
    Average(i) = mean(data(S:E));
    Sigma(i) = std(data(S:E));
end

L = Sigma == 0;
Sigma(L) = 1;
Average(L) = 0;

% nomalize
SmoothData  = (data - Average) ./ Sigma;

end

