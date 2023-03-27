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
load([path file],'LFP_filt','BFIL')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
target = 'All';                     % 'ST', 'SON', 'SOF', 'ET', 'All'
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

TMP = LFP_filt.(target);
t = [1:size(TMP,2)]-1;
nband = numel(BFIL);
map = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,33,34]; %M1
n = numel(map); N = size(TMP,1)/nband;
Cha = [1:n];   cha = Cha;
for i = 1:nband-1; cha = [cha Cha+N*i]; end
TMP = TMP(cha,:,:);
J = 0;
cd fig
for i = 1:nband
    figure('Position',[50 50 1400 900]); hold on;
    sgtitle([monkey '-lfp-low4Hz-' BFIL{i}])
    for j = 1:n
        J = J + 1;
        tmp = reshape(TMP(J,:,:),[size(TMP,2),size(TMP,3)]);
        
        tmp = tmp./max(tmp,[],1);
        M = mean(tmp,2);
        S = std(tmp,0,2);
        subplot(6,6,map(j));
        a = area(t,[M-S 2*S]); hold on;
        a(1).FaceColor = 'None';
        a(2).FaceColor = [0.5 0.5 0.5];
        plot(t,M,'r');
        xlim([0 t(end)]);
        ylim([-0.2 1.2]);
    end
    saveas(gcf,[monkey '_lfp_low4Hz_' BFIL{i} '.jpg'])
end
cd ..