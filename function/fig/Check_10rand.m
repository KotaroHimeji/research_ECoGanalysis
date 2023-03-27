function [] = Check_10rand(monkey,day,part,type)
%CHECK_10rand check noizy or not working electrodes by using graph with 10
%randam Task

%   You can Use this program only in
%   'cd(fullfile('ECoG_EMG_Analysis',monkey,[monkey '_Figure']))'

%   Type : 'EMG' or 'Raw'
%   ST : start timing
%   T1 : task1 start
%   T2 : task2 start
%   
%%%%%%%%%% Neseccary Task Number for Analysis %%%%%%%%%%%
        TS   = 1092;   %trial start
        SPL1 = 1296;   %start pulling lever 1
        EPL1 =   80;   %end pulling lever 1
        SPL2 = 1104;   %start pulling lever 2
        EPL2 =  336;   %end pulling lever 2
        ST   = 1024;   %success trial        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%% Muscle Name and Number %%%%%%%%%%%%%%%%%
EMGs=cell(14,1);
        EMGs{1}= 'Delt';        EMGs{8}= 'ECR';
        EMGs{2}= 'Biceps';      EMGs{9}= 'ECU';
        EMGs{3}= 'Triceps';     EMGs{10}= 'EDC';
        EMGs{4}= 'BRD';         EMGs{11}= 'FDS';  
        EMGs{5}= 'cuff';        EMGs{12}= 'FDP';
        EMGs{6}= 'ED23';        EMGs{13}= 'FCU';
        EMGs{7}= 'ED45';        EMGs{14}= 'FCR';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% ECoG Name and Number %%%%%%%%%%%%%%%%%%
ECoGs=cell(64,1);
for i = 1:32
        ECoGs{i} = ['M1 ' sprintf('%02d',i)];
        ECoGs{32+i} = ['S1 ' sprintf('%02d',i)];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
load(fullfile('ECoG_EMG_Analysis',monkey,[monkey '_VBSR'],[monkey day],['No' part]),...
    'Epoch_Full','NumberOfTask','InPort')
%% prepare data
switch type
    case {'EMG' 'Raw'}
        Type{1} = type;
    case 'ECoG'
        load(fullfile('ECoG_EMG_Analysis',monkey,[monkey '_FiltData'],...
            [monkey day],['No' part]),'BFIL')
        Type = BFIL;
end

A = exist('Epoch_Full','var');
B = exist('AllInPort','var');
if (A+B ~= 2)
    BadMessage1 = [monkey day '\No' part ' do not have enough data!'];
    warning(BadMessage1);
else

    NumberFig = numel(Type);
    if NumberOfTask > 10
        if NumberOfTask > 100
            NumberOfTask = 100;
        end
        TaskNo = randperm(NumberOfTask,10);
        Number = 10;
        TaskNo = sort(TaskNo);
        IP = zeros(2,6*10);
        for j = 1:Number
            IP(:,6*j-5:6*j) = InPort(:, 6*(TaskNo(j))-5 : 6*(TaskNo(j)) );
        end
    else
        TaskNo = [1:NumberOfTask];
        Number = NumberOfTask;
        IP = InPort;
    end
        
    STTime = 0;
    for j = 1:Number
        TSTimeNo = 6*j-5;
        TSTime = IP(1,TSTimeNo);
        IP(1,TSTimeNo:6*Number) = IP(1,TSTimeNo:6*Number) - (TSTime-STTime);
        STTime = IP(1,6*j);
    end
    
    Data = Epoch_Full;
    PlotData = cell(NumberFig,Number);
    ForPlot = cell(1,NumberFig);
    for j = 1:NumberFig
        for i = 1:Number
            PlotData{j,i} = Data(TaskNo(i)).(Type{j});
        end
        ForPlot{j} = cell2mat(PlotData(j,:));
    end
    EN = numel(ForPlot{1}(:,1)); %electrodes number

    switch type
        case 'EMG'
            U = 0;      W = 25;     ylabel  = EMGs;     Gap = 0;
        case 'ECoG'
            U = -3;    W = 3;     ylabel = ECoGs;     Gap = 0;
        case 'Raw'
            U = -200;   W = 200;    ylabel = ECoGs;     Gap = 0;
    end
    WW = W*2;
    UW = WW*EN+U;
    y_axis = [U UW];

%% plot
    for j = 1:NumberFig
        cd(Type{j})
        switch type
            case 'ECoG'
                name = [Type{j} '_' monkey day '_' part];
            otherwise
                name = [type '_' monkey day '_' part];
        end
        f = figure('Name',name,'NumberTitle','off'); 
        f.Position = [200 100 2300 1200];
        for i = 1:EN
            plot((ForPlot{j}(EN-i+1,:)+WW*(i-1)-Gap)');
            ylim(y_axis);
            hold on
        end
        yticks(0:WW:WW*EN)
        yticklabels(flip(ylabel))
        for i = 1:Number
            A = IP(1,6*i-5);
            B = IP(1,6*i-4);
            C = IP(1,6*i-2);
            xline(A,'-k','ST');
            xline(B,'-r','T1');
            xline(C,'-b','T2');
        end
        saveas(f,[name '.jpg']);
        close
        cd ..
    end
end
end

