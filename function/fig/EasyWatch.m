function [] = EasyWatch(monkey,day,part)
%EASYWATCH you can see filtered data
    SAVE = 1;
%%%%%%%%%% layer or each task %%%%%%%%%%%%%
    whichgraph = 3;                        % 1:EMG layer,  2:EMG each task
                                           % 3:ECoG layer, 4:ECoG each task
%%%%%%%% Switch for target action %%%%%%%%% 
    WhichAction = 3;                       % 1:SPL1, 2:EPL1
                                           % 3:SPL2, 4:EPL2, 5:full
%%%%%%%%%%%%% switch for ECoG %%%%%%%%%%%%%
    SwitchECoG = 2;                        % 1:EachFrequency
                                           % 2:AllFrequency
%%%%%%% Switch for brain map target %%%%%%%
    ECoGtype = 'M1';                       % All, M1, S1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Data preparing
EMG{1} = 'EMG';

load(fullfile('ECoG_EMG_Analysis',monkey, [monkey '_FiltData'], [monkey day], ...
    ['No' part]), 'BFIL');

switch SwitchECoG
    case 1
        ECoG = BFIL;
    case 2
        ECoG{1} = 'ECoG';
end

%% K_fold cross validation
switch WhichAction
    case 1
        S = load(fullfile('ECoG_EMG_Analysis',monkey,[monkey '_VBSR'],[monkey day],['No' part]),'Epoch_SPL1');
        TARGET = 'start pulling lever 1';
    case 2
        S = load(fullfile('ECoG_EMG_Analysis',monkey,[monkey '_VBSR'],[monkey day],['No' part]),'Epoch_EPL1');
        TARGET = 'end pulling lever 1';
    case 3
        S = load(fullfile('ECoG_EMG_Analysis',monkey,[monkey '_VBSR'],[monkey day],['No' part]),'Epoch_SPL2');
        TARGET = 'start pulling lever 2';
    case 4
        S = load(fullfile('ECoG_EMG_Analysis',monkey,[monkey '_VBSR'],[monkey day],['No' part]),'Epoch_EPL2');
        TARGET = 'end pulling lever 2';
    case 5
        S = load(fullfile('ECoG_EMG_Analysis',monkey,[monkey '_VBSR'],[monkey day],['No' part]),'Epoch_Full');
        TARGET = 'full';
end

name = fieldnames(S);

switch whichgraph
    case {1,2}
        target = EMG;
        Data = S.(name{1});
        Ac = S.(name{1})(1).Timing;
        N = numel(S.(name{1}));
        ECoGtype = 'NaN';
        yarea = [-25 100];
        %yarea = [-5 10];
    otherwise
        target = ECoG;
        Data = S.(name{1});
        Ac = S.(name{1})(1).Timing;
        N = numel(S.(name{1}));
        if SwitchECoG == 5
            %yarea = [-0.02 0.02];
            yarea = [-0.5 2.5];
        else
            yarea = [-0.5 4.5];
        end
            
end

DataSet = MakeDataSet(Data,N,target,ECoGtype);
cd(fullfile('ECoG_EMG_Analysis',monkey,'DataCheck'));
switch whichgraph
    case {1,3}
        MakeLayerGraph(DataSet,target,TARGET,Ac,BFIL,yarea,SAVE)
    otherwise
        MakeEachGraph(DataSet,target,TARGET,Ac,BFIL,yarea,SAVE)
end
cd ../..
end

function [DataSet] = MakeDataSet(Data,N,target,ECoGtype)

X = numel(Data(1).(target{1})(:,1));
Y = numel(Data(1).(target{1})(1,:));
NT = N;

for i = 1%:numel(target)
    preDataSet = zeros(X,Y,NT);
    for n = 1:N
        preDataSet(:,:,n) = Data(n).(target{1});
    end
    
    U = X/64;
    cho = [1:X];
    
    switch ECoGtype
        case 'M1'
            Z = repmat([true,false],1,U);
            choM = cho(repelem(Z,32));
            DataSet.(target{i}) = preDataSet(choM,:,:);
        case 'S1'
            Z = repmat([false,true],1,U);
            choS = cho(repelem(Z,32));
            DataSet.(target{i}) = preDataSet(choS,:,:);
        case 'All'
            DataSet.(target{i}) = preDataSet;
    end
end
end
    
function [] = MakeLayerGraph(Data,target,TARGET,Ac,Band,yarea,SAVE)
EMGs=cell(14,1);
        EMGs{1}= 'Delt';        EMGs{8}= 'ECR';
        EMGs{2}= 'Biceps';      EMGs{9}= 'ECU';
        EMGs{3}= 'Triceps';     EMGs{10}= 'EDC';
        EMGs{4}= 'BRD';         EMGs{11}= 'FDS';  
        EMGs{5}= 'cuff';        EMGs{12}= 'FDP';
        EMGs{6}= 'ED23';        EMGs{13}= 'FCU';
        EMGs{7}= 'ED45';        EMGs{14}= 'FCR';
        
map = [2,4,6,8,9,11,13,15,18,20,22,24,25,27,29,31,...
    34,36,38,40,41,43,45,47,50,52,54,56,57,59,61,63]; 

for j = 1:numel(target)
    X = numel(Data.(target{j})(:,1,1));
    Y = numel(Data.(target{j})(1,:,1));
    NT = numel(Data.(target{j})(1,1,:));
    E = X/numel(Band);
    Mean = zeros(X,Y);
    for x = 1:X
         for y = 1:Y
             SUM = 0;
             for nt = 1:NT
                 SUM = SUM + Data.(target{j})(x,y,nt);
             end
             Mean(x,y) = SUM/NT;
         end
    end
    
    if X > 16
        for x = 1:numel(Band)
            name = [target{1} ' ' Band{x} '_' TARGET '_' sprintf('%02d',x)];
            f = figure('Name',name,'NumberTitle','off'); 
            f.Position = [0 0 1500 1000];
            for h = 1:E
                subplot(8,8,map(h));
                for i = 1:NT
                    H = E*(x-1)+h;
                    plot(Data.(target{j})(H,:,i),'-k')
                    xlim([1 Y])
                    ylim(yarea)
                    hold on
                    if i == NT
                        plot(Mean(H,:),'-r')
                        for l = 1:numel(Ac)
                            xline(Ac(l),'-g');
                        end
                    end
                end
            end
            if SAVE == 1
                saveas(f,[name '.jpg']);
            end
        end
    else
        name = [target{1} '_' TARGET '_' sprintf('%02d',x)];
        f = figure('Name',name,'NumberTitle','off'); 
        f.Position = [0 0 1500 1000];
        for x = 1:X
            subplot(3,5,x);
            for i = 1:NT
                plot(Data.(target{j})(x,:,i),'-k')
                xlim([1 Y])
                ylim(yarea)
                hold on
            end
            plot(Mean(x,:),'-r')
            for l = 1:numel(Ac)
                xline(Ac(l),'-g');
            end
            title(EMGs{x});
        end
        if SAVE == 1
            saveas(f,[name '.jpg']);
        end
    end
end
end

function [] = MakeEachGraph(Data,target,TARGET,Ac,Band,yarea,SAVE)
EMGs=cell(14,1);
        EMGs{1}= 'Delt';        EMGs{8}= 'ECR';
        EMGs{2}= 'Biceps';      EMGs{9}= 'ECU';
        EMGs{3}= 'Triceps';     EMGs{10}= 'EDC';
        EMGs{4}= 'BRD';         EMGs{11}= 'FDS';  
        EMGs{5}= 'cuff';        EMGs{12}= 'FDP';
        EMGs{6}= 'ED23';        EMGs{13}= 'FCU';
        EMGs{7}= 'ED45';        EMGs{14}= 'FCR';
        
map = [2,4,6,8,9,11,13,15,18,20,22,24,25,27,29,31,...
    34,36,38,40,41,43,45,47,50,52,54,56,57,59,61,63]; 

for j = 1:numel(target)
    X = numel(Data.(target{j})(:,1,1));
    Y = numel(Data.(target{j})(1,:,1));
    NT = numel(Data.(target{j})(1,1,:));
    E = X/(numel(Band));
    Mean = zeros(X,Y);
    for x = 1:X
         for y = 1:Y
            Mean(x,y) = mean(Data.(target{j})(x,y,:));
         end
    end
    
    if X > 16
        for x = 1:numel(Band)
            name = [target{1} ' ' Band{x} '_' TARGET '_' sprintf('%02d',x)];
            f = figure('Name',name,'NumberTitle','off'); 
            f.Position = [0 0 1500 1200];
            for i = 1:NT
                for h = 1:E
                    subplot(8,8,map(h));
                    H = E*(x-1)+h;
                    plot(Data.(target{j})(H,:,i),'-k')
                    xlim([1 Y])
                    ylim(yarea)
                    plot(Mean(x,:),'-r')
                    xline(Ac,'-g');
                end
            end
        end
    else
        name = [target{1} '_' TARGET '_' springf('%02d',x)];
        f = figure('Name',name,'NumberTitle','off'); 
        f.Position = [0 0 1500 1200];
        for x = 1:X
            for i = 1:NT
                subplot(3,5,x);
                plot(Data.(target{j})(x,:,i),'-k')
                xlim([1 Y])
                ylim(yarea)
                plot(Mean(x,:),'-r')
                xline(Ac,'-g');
                title(EMGs{x})
            end
            if SAVE == 1
                saveas(f,[name '.jpg']);
            end
        end
    end
end
end
