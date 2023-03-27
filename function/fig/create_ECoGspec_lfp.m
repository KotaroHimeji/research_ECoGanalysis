%% download and add  chronux_2_10 to the path
%% FFT of aligned data at the timing of some signal

clear all

monkey = 'Ni';
ecogChannel = [1:30];

% aligned_data; channel x time series x trial
% parameter of FFT
        movingwin=[0.2 0.005];  %0.2s window, 0.005s step, set the moving window dimensions
        params.Fs=1375;         %sampling frequency
        params.fpass=[1 200];   %FFT frequency, frequency of interest
        
% Filter 
PreprocessECoG.fFilter = 1;% ?t?B???^???|??P??????1?A????P????????0
PreprocessECoG.FilterN = 2;% ?|??P???t?B???^??????h
PreprocessECoG.FilterWn = [10 240];%?J?b?g?I?t???hg??h
PreprocessECoG.FilterType = 'bandpass';%?t?B???^??????
PreprocessECoG.SampFreq = 1375 ;% ?????M?????T??g?v????g?O???hg??h


% load your file and variable
% load('F20220516_M1_grasp_off.mat');%align_M1
[file,path] = uigetfile('*.mat','Select a file',fullfile('ECoG_EMG_Analysis', monkey,'FiltData'));
if isequal(file,0)
    disp('You selected Cancel')
    return
else
    disp(['You selected "' file '"'])
end
load([path file],'LFP_raw')

% aligned_data = aligned_M1(:,:,:);   
aligned_data = LFP_raw.All(ecogChannel,:,:);
[Ch, Time_series, Trial] = size(aligned_data);
M = mean(aligned_data,1);
aligned_data = aligned_data - M;

% パワースペクトラムで可視化
% figure(5); hold on;
% power = zeros(32,Time_series);
% for kk = 1:Trial
%     M = mean(aligned_data(1:32,:,kk),1);
%     M = repmat(M,32,1);
%     aligned_data(1:32,:,kk) = aligned_data(1:32,:,kk) - M;
%     
%     % fft check
%     for l = 1:32
%         power(l,:) = power(l,:) + abs(fft(aligned_data(l,:,kk))).^2/Time_series;
%     end
% end
% power = power/max(power,[],'all');
% for kk = 1:32
%     plot([0:Time_series-1],power(33-kk,:)+2*(kk-1));
% end
% ylim([0 66]);


% chronuxを使った周波数解析
for iCh = 1:Ch
    for itrial = 1:Trial
        [oB,oA] = butter(PreprocessECoG.FilterN,PreprocessECoG.FilterWn/PreprocessECoG.SampFreq*2, PreprocessECoG.FilterType);
        ECoG2(iCh, :, itrial) = filtfilt(oB,oA,aligned_data(iCh, :, itrial));
    end
end
    
%for M1 analysis
    map = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,33,34]; %M1
%     map = [6,12,18,24,30,36,5,11,17,23,29,35,4,10,16,22,28,34,3,9,15,21,27,33,2,8,14,20,26,32,13,19]; %M1
  
for k = 1:Ch
    data = [];
    data = reshape(ECoG2(k,:,:), Time_series, Trial);
    
    for i=1:Trial
        [S,t,f] = mtspecgramc(data(:,i), movingwin, params);
        S = S';
        [S_tate S_yoko] = size(S);                          %P_tate ... freq??ﾊ??, P_yoko ... time??ﾊ??
        
        normalized_S = S./(ones([S_yoko,1])*mean(S'))';     %normalization of power at each frequency
        deltaS = 10*log10(normalized_S);
        S_move = deltaS;
        
        FFT_signal(:,:,i,k) = S_move;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         figure(2);
%         subplot(6,6,map(k)); % for M1
%         
%         hold on
%         plot(ECoG2(k,:,i));
%         ylim([-100 100]);
%         ylim([-5 5]);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
    
    %FFT_signal(:,:,[27,33,34],:) = [];
    figure(2);
    %     subplot(2,1,i)
    
    subplot(6,6,map(k)); % for M1
    xl = (t(end)-t(1))/2;
    gcf = surf(t - xl, f, mean(FFT_signal(:,:,:,k), 3),'edgecolor','none');
    axis tight; view(0,90);
%     xl = xlim - xl;
    ylim([0 200]);                                         %frequency of display
    xlim([-0.5 0.5]);                                           %time of display (second)
    caxis([-2 4]);                                         %z axis of image [-2 4] % [-5 5]
    
    colormap jet
    
    hold on
    set(gca,'linewidth',1.5, 'YTick', [0:50:200],'XTick', [-2:1:4],'TickDir','out','Layer','top');
    set(gca, 'TickDir', 'out');
    set(gca, 'Linewidth', 1);
    set(gca, 'Layer', 'bottom');
    set(gca, 'Layer', 'top');
    set(gca, 'GridLineStyle', 'none');
    set(gca,'fontsize',7);
end


title('Nibali M1 pre surgery grasp off')

xlabel('time')
ylabel('frequency')

