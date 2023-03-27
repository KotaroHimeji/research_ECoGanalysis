function [] = CheckFull(monkey,day,part,type)
%CHECKFULL check noizy or not working electrodes by using graph of Full 
%           Time Series
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
    case {'EMG' 'Raw' 'EMGNarr'}
        Type{1} = type;
    case 'ECoG'
        load(fullfile('ECoG_EMG_Analysis',monkey,[monkey '_FiltData'],[monkey day],['No' part]),...
            'BFIL')
        Type = BFIL;
end
%if InPort > 6*100
%    InPort = InPort(:,1:6*100);
%end

Data = Epoch_Full;
NumberFig = numel(Type);
%NumberOfTask = 100; %%%%%%%%%@@%%%%%%%%%%%
PlotData = cell(NumberFig,NumberOfTask);
STTime = 0;


for j = 1:NumberFig
    for i = 1:NumberOfTask
        PlotData{j,i} = Data(i).(Type{j});
        if j == 1
            TSTimeNo = 6*i-5;
            TSTime = InPort(1,6*i-5);
            InPort(1,TSTimeNo:6*NumberOfTask) = InPort(1,TSTimeNo:6*NumberOfTask) - (TSTime-STTime);
            STTime = InPort(1,6*i);
        end
    end
    ForPlot{j} = cell2mat(PlotData(j,:));
end
EN = numel(ForPlot{1}(:,1)); %electrodes number

switch type
    case {'EMG' 'EMGNarr'}
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
    switch type
        case 'ECoG'
            name = [Type{j} '_' monkey day '_' part];
        otherwise
            name = [type '_' monkey day '_' part];
    end
    f = figure('Name',name,'NumberTitle','off'); 
    f.Position = [200 100 1800 800];
    for i = 1:EN
        plot((ForPlot{j}(EN-i+1,:)+WW*(i-1)-Gap)');
        ylim(y_axis);
        hold on
    end
    yticks(0:WW:WW*EN)
    yticklabels(flip(ylabel))
    for i = 1:NumberOfTask
        A = InPort(1,6*i-5);
        B = InPort(1,6*i-4);
        C = InPort(1,6*i-2);
        xline(A,'-k','ST');
        xline(B,'-r','T1');
        xline(C,'-b','T2');
    end
    zoom 'xon'
    zoom(NumberOfTask/5)
end
end