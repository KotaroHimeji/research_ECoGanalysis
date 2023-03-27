%Filter ECoG signal

%refered to article 'prediction of muscle activity from ECoG' not completly

%   1. re-referenced using CAR
%   2. 4-butterworth [10 240]
%   3. resampling
%   4. 4-butterworth to 7 kind of bands
%   5. rectified 
%   6. 4Hz low pass filter
%   7. z-score normalization
%   8. data - min(data)

function [preFilt,BFIL] = FiltECoG(Data,Hz,ResampleRate)
%%%%%%%%%%%%%%%%
filter.N = 2;
filter.Wn = [10 240];
filter.freq = 1375;
filter.type = 'bandpass';
%%%%%%%%%%%%%%%%
%- preparation of necessary information -%
N = numel(Data(:,1)); % the number of electrods
T = size(Data,2);  % the number after downsampling to ResampleRate

%- preparations for filtering -%
Hz_Band = {1.5,4,8,14,20,30,50,80,120,160,200};
numBands = length(Hz_Band)-1;
BFIL_list = {'delta','theta','alpha','Beta1','Beta2',...
    'Gamma1','Gamma2','high1','high2','high3'};  % frequency band
BFIL = BFIL_list(1:numBands);
preFilt = zeros(T,N*numBands);

%- Re-referenced using CAR -%
TMP = double(Data);
TMP = TMP - mean(TMP);

for iCh = 1:size(TMP,1)
    [oB,oA] = butter(filter.N, filter.Wn/filter.freq*2, filter.type);
    TMP(iCh, :) = filtfilt(oB,oA,TMP(iCh, :));
end
%- each band filter -%
for i = 1:N
    tmp = (resample(double(TMP(i,:)), ResampleRate, Hz)).';
    for j = 1:numBands % Each Band Matrix for ECoG
        [B,A] = butter(2,[Hz_Band{j} Hz_Band{j+1}]/(ResampleRate/2));
        tmp = filtfilt(B, A, tmp);
        tmp = abs(tmp);
        %tmp = Normalize(tmp,[1 500]);
        %tmp = zscore(tmp);
        [B,A] = butter(2,4/(ResampleRate/2),'low');
        tmp = filtfilt(B,A,tmp);
        %tmp = GaussianFilt(tmp,50,20);
        tmp = zscore(tmp);
        tmp = tmp - min(tmp);

        %%%%%
%        figure;
%        plot(tmp);
%        cd(fullfile('ECoG_EMG_Analysis',monkey,'PreFig','ECoG'));
%        filename = ['No' sprintf('%02d',i) '_' BFIL{j}];
%        saveas(gca, [filename '.png']);
%        cd ../../..
%        close
        %%%%%

        preFilt(:,N*(j-1)+i) = tmp;
    end
end

%- save the data -%
%- save -v7.3 を使�?場�? -append との併用不可 -%
% load (fullfile('ECoG_EMG_Analysis', monkey, [monkey '_FiltData'], [monkey day], ...
%     ['No' sprintf('%d',k)]), 'AllInPort')
% save(fullfile('ECoG_EMG_Analysis', monkey, [monkey '_FiltData'], [monkey day], ...
%     ['No' sprintf('%d',k)]), 'AllInPort', 'BFIL', 'ECoG_PreFilt', '-v7.3')
end


% coded by Kotato Himeji
% last modification : 2021.12.14