clear all

% ANALYSISVBSR 回帰分析用プログラム（10分割交差検証で変分ベイズスパース回帰分析）
% 変数の設定は自由に行えるので、各サル毎に適切な変数を設定する（Wasa, Nibaliは設定済み）
% %%%% which muscle use %%%%より上は解析前に設定する変数なので、
% 目的によって設定を変更できる

%%%%%%%%%%%%%%%% which monkey %%%%%%%%%%%%%%%%
                monkey = 'Ni';                  % 'Wa' or 'Ni'
% K fold cross validarion & use N train data %
    K = 10;     N = 5; 
%%%%%%%%%% Switch for target action %%%%%%%%%%
    actionPoint = 5;                            % 1:SPL1, 2:EPL1, 3:SPL2, 4:EPL2, 5:Full in case 'Wa'
                                                % 1:ST, 2:SON, 3:SOF, 4:ET, 5:Full       in case 'Ni'
%%%%%%%% switch for ECoG and EMG data %%%%%%%%
    Each_or_AllFrequency = 2;                   % 1:EachFrequency, 2:AllFrequency,
%%%%%%%%% Switch for brain map target %%%%%%%%
    ecogTarget.portion = 'M1';                          % All, M1, S1
    switch ecogTarget.portion
        case 'M1'
            ecogTarget.channelFront = 1;
            ecogTarget.channelEnd = 32;
        case 'S1'
            switch monkey
                case 'Wa'
                    ecogTarget.channelFront = 33;
                    ecogTarget.channelEnd = 64;
                case 'Ni'
                    ecogTarget.channelFront = 33;
                    ecogTarget.channelEnd = 64;
            end
        case 'All'
            switch monkey
                case 'Wa'
                    ecogTarget.channelFront = 1;
                    ecogTarget.channelEnd = 64;
                case 'Ni'
                    ecogTarget.channelFront = 1;
                    ecogTarget.channelEnd = 80;
            end
    end
%%%%%%%%%%%% corresponding muscle %%%%%%%%%%%%
    EMGs=cell(16,1);
    switch monkey
        case 'Wa'
            EMGs{1}= 'Delt';    EMGs{9}=  'ECU';
            EMGs{2}= 'Biceps';  EMGs{10}= 'EDC';
            EMGs{3}= 'Triceps'; EMGs{11}= 'FDS';
            EMGs{4}= 'BRD';     EMGs{12}= 'FDP';
            EMGs{5}= 'cuff';    EMGs{13}= 'FCU';
            EMGs{6}= 'ED23';    EMGs{14}= 'FCR';
            EMGs{7}= 'ED45';    EMGs{15}= 'ref1';
            EMGs{8}=  'ECR';    EMGs{16}= 'ref2';
        case 'Ni'
            EMGs{1}= 'EDC_p';   EMGs{9}=  'FDS_p';
            EMGs{2}= 'EDC_d';   EMGs{10}= 'FDS_d';
            EMGs{3}= 'ED23';    EMGs{11}= 'FDP';
            EMGs{4}= 'ED45';    EMGs{12}= 'FCR';
            EMGs{5}= 'ECR';     EMGs{13}= 'FCU';
            EMGs{6}= 'ECU';     EMGs{14}= 'FPL';
            EMGs{7}= 'BRD';     EMGs{15}= 'Biceps';
            EMGs{8}= 'EPL';     EMGs{16}= 'Triceps';
    end
%%%%%%%%%%%%%% which muscle use %%%%%%%%%%%%%%
    emgTarget = ones(16,1);                     %0/1 = no/yes
    nonForcus = [1 9];                          %choose channel not to forcus
    emgTarget(nonForcus,1) = 0;
    EMGinfo = EMGs; EMGinfo(nonForcus) = [];
%%%%%%%%%%%%%% select .mat file %%%%%%%%%%%%%%
    [file,path] = uigetfile('*.mat','Select a file',fullfile('ECoG_EMG_Analysis', monkey,'FiltData'));
    if isequal(file,0)
        disp('You selected Cancel')
        return
    else
        disp(['You selected "' file '"'])
    end
%%%%%%%%%%%%%% data prepairing %%%%%%%%%%%%%%%
% make the wrist for K fold cross validation
    load([path file],'BFIL');
    global bandNum
    bandNum = numel(BFIL);
    switch Each_or_AllFrequency
        case 1
            band = BFIL;
            ECoGinfo = 'eachBand';
        case 2
            band{1} = 'ECoG';
            ECoGinfo = 'allBand';
        case 3
            band{1} = 'ECoG_koi';
            ECoGinfo = 'allBand(koike)';
    end
    
    %% K_fold cross validation
load([path file],'LFP_filt','EMG_filt');
f_name = fieldnames(LFP_filt);
ecog = LFP_filt.(f_name{actionPoint});
emg = EMG_filt.(f_name{actionPoint});
n = size(ecog,3);
c = cvpartition(n,'KFold',K);
TestSize = c.TestSize;    % each number of test data
logicalNum_Test = cell(1,K);
for i = 1:K
    logicalNum_Test{i} = test(c,i);  %logical number of test set
end
timing = struct;
    
for i = 1:K
    A = 0;
    while A ~= N
        TrainNo = randperm(K,N);
        A = find(TrainNo -i);
    end
    logicalNum_Train = false(n,1);
    for j = 1:N
        logicalNum_Train = logicalNum_Train | logicalNum_Test{TrainNo(j)};  %logical number of train set
    end
    TrainSize = sum(logicalNum_Train); %numter of training data
        
    [test(i)] = MakeDataSet(logicalNum_Test{i},TestSize(i),ecog,emg,ecogTarget,emgTarget,band);
    [train(i)] = MakeDataSet(logicalNum_Train,TrainSize,ecog,emg,ecogTarget,emgTarget,band);
end
target.ECoG = ECoGinfo;
target.EMG = EMGinfo;
target.band = BFIL;
target.frameNum = size(ecog,2);
target.BrainMap = [f_name{actionPoint} 'Task' ecogTarget.portion];
target.BrainCnannel = [sprintf('%d',ecogTarget.channelFront) ':' ...
     sprintf('%d',ecogTarget.channelEnd)];

%% required parameters, Model and parm
ReadyFor  %function to ready for analysis 

%% to evaluate 'model' accuracy by K fold cross validation
fields = fieldnames(train);
I = numel(fields);
EN = numel(EMGs);

if I > 2
    for i = 1:I-1
        nRMSE.(fields{i}) = struct; Tr.(fields{i}) = struct;
        CC.(fields{i}) = struct;    Te.(fields{i}) = struct;
    end
else
    nRMSE = struct; Tr = struct;
    CC = struct;    Te = struct;
end

for k = 1:K
    Y = train(k).(fields{I});
    testY = test(k).(fields{I});
    
    for i = 1:I-1
        X = train(k).(fields{i});
        testX = test(k).(fields{i});
    
        [model,info] = linear_sparse_space(X,Y,Model,parm);
        MODEL(k).(fields{i}) = model;   %model for K_fold_cross_validation
        INFO(k).(fields{i}) = info;     %info for K_fold_cross_validation
        if I > 2
            [nRMSE.(fields{i}),CC.(fields{i}),Tr.(fields{i}),Te.(fields{i})] = ...
                Sparce_nRMSE( model , testX , testY , EMGs,...
                nRMSE.(fields{i}) , CC.(fields{i}) , Tr.(fields{i}) , Te.(fields{i}) , k);
        else
            [nRMSE,CC,Tr,Te] = ...
                Sparce_nRMSE( model , testX , testY , EMGs,...
                nRMSE , CC , Tr , Te , k);
        end
    end
end

FN = fieldnames(CC);%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for NT = 1:numel(FN)
    NRMSE_mean = zeros(EN,I-1);
    cc_mean = zeros(EN,I-1);
    for j = 1:EN
        for i = 1:I-1
            S = 0; SS = 0;
            for k = 1:numel(nRMSE.(FN{NT}))
                if I > 2
                    S = S + nRMSE.(FN{NT}).(fields{i})(k).(EMGs{j});
                    SS = SS + CC.(FN{NT}).(fields{i})(k).(EMGs{j});
                else
                    S = S + nRMSE.(FN{NT})(k).(EMGs{j});
                    SS = SS + CC.(FN{NT})(k).(EMGs{j});
                end
            end
            if S > 0
                NRMSE_mean(j,i) = S/K;
                cc_mean(j,i) = SS/K;
            else   %バグ回避分岐
                NRMSE_mean(j,i) = 0;
                cc_mean(j,i) = 0;
            end
        end
    end
    nRMSE_mean.(FN{NT}) = NRMSE_mean;
    CC_mean.(FN{NT}) = cc_mean;
end

nn = numel(CC_mean.(FN{1}));%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cMEAN = zeros(nn,1);  nMEAN = zeros(nn,1);
for i = 1:nn
    SUMc = 0;  SUMn = 0;
    for j = 1:numel(FN)-1
        SUMc = SUMc + CC_mean.(FN{j})(i);
        SUMn = SUMn + nRMSE_mean.(FN{j})(i);
    end
    cMEAN(i) = SUMc/(numel(FN)-1);
    nMEAN(i) = SUMn/(numel(FN)-1);
end
CC_mean.MEAN = cMEAN;
nRMSE_mean.MEAN = nMEAN;

Result.target = target;
Result.model = MODEL;
Result.info = INFO;
Result.train = Tr;
Result.test = Te;
Result.timing = timing;
Result.CC = CC;
Result.CC_mean = CC_mean;
Result.nRMSE = nRMSE;
Result.nRMSE_mean = nRMSE_mean;

while  isempty(dir('ECoG_EMG_Analysis'))
    cd ..
end

n = 0;
check = exist(fullfile('ECoG_EMG_Analysis',monkey,'VBSR_result',file),'file');
while check == 2
    ZZ = extractBefore(file,'.');
    n = n + 1;
    file = [ZZ sprintf('%02d',n)];
    check = exist(fullfile('ECoG_EMG_Analysis',monkey,'VBSR_result',file),'file');
end
save(fullfile('ECoG_EMG_Analysis',monkey,'VBSR_result',file),'Result')



function [DataSet] = MakeDataSet(logical,N,ecog,emg,ecogTarget,emgTarget,band)
global bandNum
m = 1;  %train data number
M = 1;  %train data counter
electroY = size(emg,1);
[electroX,frameNum] = size(ecog,[1 2]);
channelNumAll = electroX/bandNum;
electrodes = [ecogTarget.channelFront : ecogTarget.channelEnd];
channelNum = numel(electrodes);
electrodesAll = repmat(electrodes,1,bandNum);
for j = 1:bandNum-1
    electrodesAll(channelNum*j+1:channelNum*(j+1)) = channelNumAll*j+electrodes;
end
ecog = ecog(electrodesAll,:,:);
electroX = size(ecog,1);
rowNum = electroX/numel(band);
for i = 1:numel(band)
    DataSet.(band{i}) = zeros(electroX,frameNum,N);  %data of ECoG
end
preEMG = zeros(electroY,frameNum,N);   %training data of EMG
while m-1 ~= N
    if logical(M)
        for i = 1:numel(band)
            DataSet.(band{i})(:,:,m) = ecog((i-1)*rowNum+1:i*rowNum,:,M);
        end
        preEMG(:,:,m) = emg(:,:,M);
        m = m + 1;
    end
    M = M + 1;
end
for i = 1:numel(emgTarget)
    preEMG(i,:,:) = emgTarget(i)*preEMG(i,:,:);
    DataSet.EMG = preEMG;
end
end

% coded by Kotato Himeji
% last modification : 2021.1.12