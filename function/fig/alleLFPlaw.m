clear all

%%%%%%%%%%%%%%%%
monkey = 'Ni';
%%%%%%%%%%%%%%%%
[file,path] = uigetfile('*.mat','Select a file',fullfile('ECoG_EMG_Analysis', monkey,'FiltData'));
if isequal(file,0)
    disp('You selected Cancel')
    return
else
    disp(['You selected "' file '"'])
end
load([path file],'LFP_raw','BFIL','LFP_Hz')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
target = 'All';                     % 'ST', 'SON', 'SOF', 'ET', 'All'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%- preparations for filtering -%
Hz_Band = {1.5,4,8,14,20,30,50,80,120,160,200};
nband = length(Hz_Band)-1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

TMP = LFP_raw.(target);
t = [1:size(TMP,2)]-1;
map = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,33,34]; %M1
n = numel(map);
cha = [1:n];
TMP = TMP(cha,:,:);

cd fig
%- plot lfp raw data (pure) -%
figure('Position',[50 50 1400 900]); hold on;
sgtitle([monkey '-lfpRow'])
for j = 1:n
    tmp = reshape(TMP(j,:,:),[size(TMP,2),size(TMP,3)]);
    tmp = tmp./max(tmp,[],1);
    M = mean(tmp,2);
    S = std(tmp,0,2);
    subplot(6,6,map(j));
    a = area(t,[M-S 2*S]); hold on;
    a(1).FaceColor = 'None';
    a(2).FaceColor = [0.5 0.5 0.5];
    plot(t,M,'r');
    xlim([0 t(end)]);
    ylim([-0.3 0.3]);
end
saveas(gcf,[monkey '_lfp_row' '.jpg'])

%- plot lfp raw data (only with CAR)-%
for i = 1:size(TMP,3)
    tmp = reshape(TMP(:,:,i),[size(TMP,1),size(TMP,2)]);
    TMP(:,:,i) = tmp - mean(tmp);
end

figure('Position',[50 50 1400 900]); hold on;
sgtitle([monkey '-lfpRaw-CAR'])
for j = 1:n
    tmp = reshape(TMP(j,:,:),[size(TMP,2),size(TMP,3)]);
    tmp = tmp./max(tmp,[],1);
    M = mean(tmp,2);
    S = std(tmp,0,2);
    subplot(6,6,map(j));
    a = area(t,[M-S 2*S]); hold on;
    a(1).FaceColor = 'None';
    a(2).FaceColor = [0.5 0.5 0.5];
    plot(t,M,'r');
    xlim([0 t(end)]);
    ylim([-0.7 0.7]);
end
saveas(gcf,[monkey '_lfpRaw_CAR' '.jpg'])

%- plot lfp raw band data (only with CAR)-%
for i = 1:nband
    figure('Position',[50 50 1400 900]); hold on;
    sgtitle([monkey '-lfpBand-CAR-' BFIL{i}])
    for j = 1:n
        tmp = reshape(TMP(j,:,:),[size(TMP,2),size(TMP,3)]);
        [B,A] = butter(2,[Hz_Band{i} Hz_Band{i+1}]/(LFP_Hz/2));
        tmp = filtfilt(B, A, tmp);
        tmp = tmp./max(tmp,[],1);
        M = mean(tmp,2);
        S = std(tmp,0,2);
        subplot(6,6,map(j));
        a = area(t,[M-S 2*S]); hold on;
        a(1).FaceColor = 'None';
        a(2).FaceColor = [0.5 0.5 0.5];
        plot(t,M,'r');
        xlim([0 t(end)]);
        ylim([-0.5 0.5]);
    end
    saveas(gcf,[monkey '_lfpBand_CAR_' BFIL{i} '.jpg'])
end

%- plot lfp band data (with CAR and Gausian)-%
for i = 1:nband
    figure('Position',[50 50 1400 900]); hold on;
    sgtitle([monkey '-lfpBand-CARgausian-' BFIL{i}])
    for j = 1:n
        tmp = reshape(TMP(j,:,:),[size(TMP,2),size(TMP,3)]);
        [B,A] = butter(2,[Hz_Band{i} Hz_Band{i+1}]/(LFP_Hz/2));
        tmp = filtfilt(B, A, tmp);
        tmp = GaussianFilt(tmp,50,20,1);
        tmp = tmp./max(tmp,[],1);
        M = mean(tmp,2);
        S = std(tmp,0,2);
        subplot(6,6,map(j));
        a = area(t,[M-S 2*S]); hold on;
        a(1).FaceColor = 'None';
        a(2).FaceColor = [0.5 0.5 0.5];
        plot(t,M,'r');
        xlim([0 t(end)]);
        ylim([-0.5 0.5]);
    end
    saveas(gcf,[monkey '_lfpBand_CARausian_' BFIL{i} '.jpg'])
end

%- plot lfp band data (with CAR, and abs)-%
for i = 1:nband
    figure('Position',[50 50 1400 900]); hold on;
    sgtitle([monkey '-lfpBand-CARabs-' BFIL{i}])
    for j = 1:n
        tmp = reshape(TMP(j,:,:),[size(TMP,2),size(TMP,3)]);
        [B,A] = butter(2,[Hz_Band{i} Hz_Band{i+1}]/(LFP_Hz/2));
        tmp = filtfilt(B, A, tmp);
        tmp = abs(tmp);
        tmp = tmp./max(tmp,[],1);
        M = mean(tmp,2);
        S = std(tmp,0,2);
        subplot(6,6,map(j));
        a = area(t,[M-S 2*S]); hold on;
        a(1).FaceColor = 'None';
        a(2).FaceColor = [0.5 0.5 0.5];
        plot(t,M,'r');
        xlim([0 t(end)]);
        ylim([-0.1 1.1]);
    end
    saveas(gcf,[monkey '_lfpBand_CARabs_' BFIL{i} '.jpg'])
end

%- plot lfp band data (with CAR, abs and Gausian)-%
for i = 1:nband
    figure('Position',[50 50 1400 900]); hold on;
    sgtitle([monkey '-lfpBand-CARabsGausian-' BFIL{i}])
    for j = 1:n
        tmp = reshape(TMP(j,:,:),[size(TMP,2),size(TMP,3)]);
        [B,A] = butter(2,[Hz_Band{i} Hz_Band{i+1}]/(LFP_Hz/2));
        tmp = filtfilt(B, A, tmp);
        tmp = abs(tmp);
        tmp = GaussianFilt(tmp,50,20,1);
        tmp = tmp./max(tmp,[],1);
        M = mean(tmp,2);
        S = std(tmp,0,2);
        subplot(6,6,map(j));
        a = area(t,[M-S 2*S]); hold on;
        a(1).FaceColor = 'None';
        a(2).FaceColor = [0.5 0.5 0.5];
        plot(t,M,'r');
        xlim([0 t(end)]);
        ylim([-0.1 1.1]);
    end
    saveas(gcf,[monkey '_lfpBand_CARabsGausian_' BFIL{i} '.jpg'])
end
cd ..