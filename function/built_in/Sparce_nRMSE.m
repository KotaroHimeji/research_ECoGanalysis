function [nRMSE,CC,Tr,Te,NTest] = Sparce_nRMSE(model,testX,testY,EMGs,nRMSE,CC,Tr,Te,k,NTest)
%SPARCE_NRMSE nRMSE for sparse regression
%   nRMSE   :   二乗平均平方根誤差
%   CC      :   相関係数
%   Tr,Te   :   グラフを後から書けるように、筋活動予測から導いたデータと、
%               真のテストデータをそれぞれ保存している

N = numel(testY(:,1,1));  %number of EMG
M = numel(testX(:,1,1));  %number of ECoG
T = numel(testX(1,:,1));  %Time range
NTest(k) = numel(testX(1,1,:));  %Number of test data
W = model.W;
D = model.Dtau;
tau  = model.Tau;
Xele = model.ix_act;
TESTX = zeros(M*D,T,NTest(k));
XX = repmat(testX,D,1,1);
WW = zeros(N,M*D);
        
for i = 1:numel(Xele)
    TESTX(Xele(i),:,:) = XX(Xele(i),:,:);
    WW(:,Xele(i)) = W(:,i);
end
m = 1;
tid = tau*(D-1);
for d = 1:D
    TESTX(m:M*d,:,:) = [TESTX(m:M*d,tid+1:T,:) zeros(M,tid,NTest(k))];
    m = m + M;
    tid = tid - tau;
end

TESTY = zeros(N,T,NTest(k));
for NT = 1:NTest(k)
    TESTY(:,:,NT) = WW*TESTX(:,:,NT);
end
Gap = testY - TESTY;  %Ytrue - W*Xtest

for NT = 1:NTest(k)
    name = ['Test_No' sprintf('%02d',k)];
    for n = 1:N
        GapSum = 0;
        ymin = testY(n,1,NT);
        ymax = testY(n,1,NT);
        for t = 1:T
            GapSum = GapSum + Gap(n,t,NT)^2;
            if ymin > testY(n,t,NT)
                ymin = testY(n,t,NT);
            elseif ymax < testY(n,t,NT)
                ymax = testY(n,t,NT);
            end
        end
        Tr.(name)(NT).(EMGs{n}) = TESTY(n,:,NT);   % EMG data from train data  
        Te.(name)(NT).(EMGs{n}) = testY(n,:,NT);   % real EMG data            
        c = corrcoef(testY(n,:,NT),TESTY(n,:,NT));
        CC.(name)(NT).(EMGs{n}) = c(1,2);
        nRMSE.(name)(NT).(EMGs{n}) = sqrt(GapSum/T)/(ymax-ymin);
    end
end
end



% coded by Kotato Himeji
% last modification : 2021.1.13