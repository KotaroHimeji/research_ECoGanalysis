function [CC] = SympleCC(monkey,day,part)
%UNTITLED CC caliculater  "in a day"
%   show graphs for ECoG sach frequency band 
    SAVE = 1;
%%%%%%%% Switch for target action %%%%%%%%%
    WhichAction = 5;                        % 1:SPL1, 2:EPL1
                                            % 3:SPL2, 4:EPL2, 5:Full
%%%%%%%%%%%%% switch for ECoG %%%%%%%%%%%%%
    SwitchECoG = 2;                         % 1:EachFrequency
                                            % 2:AllFrequency
%%%%%%% Switch for brain map target %%%%%%%
    ECoGtype = 'M1';                        % All, M1, S1
%%%%%%%%%%%%%%% %CC target %%%%%%%%%%%%%%%%
%% Data preparing
EMG{1} = 'EMG';

load(fullfile('ECoG_EMG_Analysis', monkey, [monkey '_FiltData'], ...
    [monkey day '_' part]), 'BFIL');

switch SwitchECoG
    case 1
        ECoG = BFIL;
    case 2
        ECoG{1} = 'ECoG';
end
Z = exist(fullfile('ECoG_EMG_Analysis', monkey, [monkey '_FiltData'], ...
    [monkey day '_' part '.mat']), 'file');
if Z == 2
    switch WhichAction
        case 1
            S = load(fullfile('ECoG_EMG_Analysis',monkey,[monkey '_VBSR'],[monkey day],['No' part]),'Epoch_SPL1');
        case 2
            S = load(fullfile('ECoG_EMG_Analysis',monkey,[monkey '_VBSR'],[monkey day],['No' part]),'Epoch_EPL1');
        case 3
            S = load(fullfile('ECoG_EMG_Analysis',monkey,[monkey '_VBSR'],[monkey day],['No' part]),'Epoch_SPL2');
        case 4
            S = load(fullfile('ECoG_EMG_Analysis',monkey,[monkey '_VBSR'],[monkey day],['No' part]),'Epoch_EPL2');
        case 5
            S = load(fullfile('ECoG_EMG_Analysis',monkey,[monkey '_VBSR'],[monkey day],['No' part]),'Epoch_Full');
    end
    name = fieldnames(S);
    N = numel(S.(name{1}));

%% correlation coefficient
    Data = S.(name{1});
    ECoGnum = numel(Data(1).raw(:,1));
    DataA = MakeDataSet(Data,N,ECoG,ECoGtype,ECoGnum);
    DataB = MakeDataSet(Data,N,EMG,'NaN',ECoGnum);
    switch monkey
        case 'Wa'
            ele = 32;
        case 'Ni'
            ele = 40;
    end
    
    CCECoG = CCFunc(DataA);
    BN = numel(CCECoG)/ele;
    ccECoG = zeros(ele,BN);
    for i = 1:BN
        ccECoG(:,i) = CCECoG(ele*(i-1)+1:ele*i);
    end
    CC.ECoG = ccECoG;
    CC.EMG = CCFunc(DataB);
    CC.ECoG_EMG = CCFunc(DataA,DataB);
    
    if SAVE == 1
        while isempty(dir('ECoG_EMG_Analysis'))
            cd ..
        end
        save(fullfile('ECoG_EMG_Analysis',monkey,[monkey '_VBSR'],[monkey day],['No' part]),'CC','-append')
    end
else
    BadMessage1 = [monkey day '\No' part ' do not have enough data!'];
    warning(BadMessage1);
end
end

function [DataSet] = MakeDataSet(Data,N,target,type,ECoGnum)
X = numel(Data(1).(target{1})(:,1));
Y = numel(Data(1).(target{1})(1,:));
NT = N;

for i = 1%:numel(target)
    preDataSet = zeros(X,Y,NT);
    for n = 1:N
        preDataSet(:,:,n) = Data(n).(target{1});
    end
    U = X/ECoGnum;
    cho = [1:X];
    switch type
        case 'M1'
            Z = repmat([true,false],1,U);
            choM = cho(repelem(Z,ECoGnum/2));
            DataSet = preDataSet(choM,:,:);
        case 'S1'
            Z = repmat([false,true],1,U);
            choS = cho(repelem(Z,ECoGnum/2));
            DataSet = preDataSet(choS,:,:);
        otherwise
            DataSet = preDataSet;
    end
end
end