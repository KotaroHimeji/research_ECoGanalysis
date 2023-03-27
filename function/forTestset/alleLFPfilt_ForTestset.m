clear all

%%%%%%%%%%%%%%%%
monkey = 'testset';
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
[A,B,C] = fileparts(file);
TMP = LFP_filt.(target);
t = [1:size(TMP,2)]-1;
nband = numel(BFIL);
map = [1,2,3]; %M1
n = numel(map); N = size(TMP,1)/nband;
Cha = [1:n];   cha = Cha;
for i = 1:nband-1; cha = [cha Cha+N*i]; end
TMP = TMP(cha,:,:);         
J = 0;
cd ECoG_EMG_Analysis
cd testset
cd fig
for i = 1:nband
    figure('Position',[50 50 1400 900]); hold on;
    sgtitle([monkey '-lfp-low4Hz-' BFIL{i}])
    for j = 1:n
        J = J + 1;
        tmp = reshape(TMP(J,:,:),[size(TMP,2),size(TMP,3)])+0.001;
        tmp = tmp./(ones([size(tmp,1),1])*mean(tmp,1));
        tmp = 10*log10(tmp);
        tmp = tmp./max(abs(tmp));
%         tmp = tmp-min(tmp);
        M = mean(tmp,2);
        S = std(tmp,0,2);
        subplot(3,1,map(j));
        a = area(t,[M-S 2*S]); hold on;
        a(1).FaceColor = 'None';
        a(2).FaceColor = [0.5 0.5 0.5];
        plot(t,M,'r');
        xlim([0 t(end)]);
        ylim([-0.8 0.8]);
    end
%     saveas(gcf,[B '_' BFIL{i} '.jpg'])
end
cd ../../..