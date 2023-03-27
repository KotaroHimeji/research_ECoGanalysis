function [CC] = EMG_GapView
%EMG_GAPVIEW show test datasets and predicted dataset of 
%   if you want to save this graph, youmust go the directory and "Switch
%   on"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            Switch = 1;     % 1/0 = on/off
            SS = 8;         % dataset No. you want to see the most
            monkey = 'Ni';  % monkey
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
%%%%%%%%%%%%%%%%%%%% choose a file %%%%%%%%%%%%%%%%%%%%%%%
[file,path] = uigetfile('*.mat','Select a file',fullfile('ECoG_EMG_Analysis', monkey,'VBSR_result'));
    if isequal(file,0)
        disp('You selected Cancel')
        return
    else
        disp(['You selected "' file '"'])
    end

%% prepare data
load([path file],'Result')
cd(fullfile('ECoG_EMG_Analysis',monkey,'Figure'));
ff = fieldnames(Result.nRMSE);
F = fieldnames(Result.nRMSE.(ff{1}));
c = 0;
for i = 1:numel(F)
    if ~isnan(Result.nRMSE.(ff{1})(SS).(F{i}))
        c = c + 1;
        C(c) = i;
    end
end

N = numel(C); % number of EMG electrodes
% NN = numel(Result.timing(SS).Action);
%R = Result.nRMSE_mean.MEAN;
    U = -0.1;      W = 1.1;
    y_axis = [U W];
    
% switch Result.target.ECoG
%     case 'allBand'
%         x_axis = [0 1000];
%         load(fullfile('ECoG_EMG_Analysis',monkey,'FiltData',[monkey day]),'InPort')  % sokuseki!!!!!
%         IP = reshape(InPort(1,:),6,[])';
%         IP(:,1) = [];   IP(:,5) = [];   IP = IP - IP(:,1);
%         IP = mean(IP,1);
%     otherwise
%         x_axis = [0 400];
% end
CC = zeros(N,1);

%% plot
for j = 1:N
    name = [erase(file, '.mat') '_' EMGs{j} '_' Result.target.BrainMap '_' Result.target.ECoG];
    f = figure('Name',name,'NumberTitle','off');
    f.Position = [200 100 700 300];
    %    t = title((EMGs{C(j)}),['nRMSE = ' Result.nRMSE.(ff{1})(SS).(EMGs{C(j)})...
    %        ', CC = ' Result.CC.(ff{1})(SS).(EMGs{C(j)})]);
    %    t.FontSize = 16;
    
    X = Result.train.(ff{1})(SS).(EMGs{C(j)});
    X = X-min(X);
    Y = Result.test.(ff{1})(SS).(EMGs{C(j)});
    Y = (Y-min(Y));
    SY = sum(abs(Y));  SX = sum(abs(X)); G = SY/SX; %1st way
    %G = 1/R(C(j));                                  %2nd way
    X = X*G;
    X = X/max(X);
    Y = Y/max(Y);
    x_axis = [1:Result.target.frameNum]-floor(Result.target.frameNum/2);
    %M = mean(Y); V = var(Y);                        %3rd way
    %X = (X - M) / V;
    cc = corrcoef(Y,X);
    CC(j) = cc(1,2);
    
    plot(x_axis,X,'--r');
    hold on
    plot(x_axis,Y,'-k');
    ylim(y_axis);
    xlim([x_axis(1) x_axis(end)]);
%     for i = 1%:NN
%         A = Result.timing(SS).Action(:,i);
%         %A = IP + A; % sokuseki!!!!!!!
%         for k = 1:numel(A)
%             xline(A(k),':k');
%         end
%     end
%     for i = 1%:NN-1
%         %B = Result.timing(SS).CutPoint(i);
%         %xline(B,':b');
%     end
    if Switch == 1
        saveas(f,[name '.jpg']);
    end
end
cd ../../..

end

