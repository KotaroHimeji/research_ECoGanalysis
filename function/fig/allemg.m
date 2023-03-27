clear all

%%%%%%%%%%%%%%%%
monkey = 'Ni';
%%%%%%%%%%%%%%%%
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[file,path] = uigetfile('*.mat','Select a file',fullfile('ECoG_EMG_Analysis', monkey,'FiltData'));
if isequal(file,0)
    disp('You selected Cancel')
    return
else
    disp(['You selected "' file '"'])
end
load([path file],'EMG_filt','EMG_raw')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
target = 'All';                     % 'ST', 'SON', 'SOF', 'ET', 'All'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cd fig
%- plot lfp raw data (pure) -%
figure('Position',[50 50 1400 900]); hold on;
sgtitle([monkey '-emgRaw'])
emg = EMG_raw.(target);
t = [1:size(emg,2)]-1;
for i = 1:size(emg,1)
    tmp = reshape(emg(i,:,:),[size(emg,2),size(emg,3)]);
    tmp = tmp./max(tmp,[],1);
    M = mean(tmp,2);
    S = std(tmp,0,2);
    subplot(ceil(size(emg,1)/2),2,i);
    a = area(t,[M-S 2*S]); hold on;
    a(1).FaceColor = 'None';
    a(2).FaceColor = [0.5 0.5 0.5];
    plot(t,M,'r');
    xlim([0 t(end)]);
    ylim([-1.2 1.2]);
    title(EMGs{i})
end
saveas(gcf,[monkey '_emg_Raw' '.jpg'])

%- plot lfp raw data (only 50Hz high) -%
figure('Position',[50 50 1400 900]); hold on;
sgtitle([monkey '-emg50Hzhigh'])
for i = 1:size(emg,1)
    tmp = reshape(emg(i,:,:),[size(emg,2),size(emg,3)]);
    [B,A] = butter(2, 50/(1375/2), 'high');
    tmp = filtfilt(B,A,tmp);
    tmp = tmp./max(tmp,[],1);
    M = mean(tmp,2);
    S = std(tmp,0,2);
    subplot(ceil(size(emg,1)/2),2,i);
    a = area(t,[M-S 2*S]); hold on;
    a(1).FaceColor = 'None';
    a(2).FaceColor = [0.5 0.5 0.5];
    plot(t,M,'r');
    xlim([0 t(end)]);
    ylim([-0.5 0.5]);
    title(EMGs{i})
end
saveas(gcf,[monkey '_emg_50Hzhigh' '.jpg'])

%- plot lfp filt data -%
figure('Position',[50 50 1400 900]); hold on;
sgtitle([monkey '-emgFilt'])
emg = EMG_filt.(target);
for i = 1:size(emg,1)
    tmp = reshape(emg(i,:,:),[size(emg,2),size(emg,3)]);
    tmp = tmp./max(tmp,[],1);
    M = mean(tmp,2);
    S = std(tmp,0,2);
    subplot(ceil(size(emg,1)/2),2,i);
    a = area(t,[M-S 2*S]); hold on;
    a(1).FaceColor = 'None';
    a(2).FaceColor = [0.5 0.5 0.5];
    plot(t,M,'r');
    xlim([0 t(end)]);
    ylim([-0.2 1.2]);
    title(EMGs{i})
end
saveas(gcf,[monkey '_emg_filt' '.jpg'])


cd ..