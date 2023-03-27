%Filter EMG signal

%refer to article 'Neural basis for hand muscle synergies in the primate 
%spinal cord' mostly

%   1. down sample to 5.5kHz
%   2. 50Hz high pass filter
%   3. rectified
%   4. 4Hz low pass filter
%   5. data - min(data)
%   6. down sample to 500Hz

function [preFilt] = FiltEMG(Data,Hz,ResampleRate,monkey)
switch monkey
    case 'Wa'
        ResampleRate_pre = 5500;
    case {'Ni', 'testset'}
        ResampleRate_pre = 1375;
end
        N = size(Data,1); % the number of electrodes
        T = size(Data,2);
        preFilt = zeros(ceil(T * ResampleRate / Hz), N);
        
for i = 1:N
    tmp = (resample(double(Data(i,:)), ResampleRate_pre, Hz)).';
    [B,A] = butter(2, 50/(ResampleRate_pre/2), 'high');
    tmp = filtfilt(B,A,tmp);
    tmp = abs(tmp);
    [B,A] = butter(2, 4/(ResampleRate_pre/2), 'low');
    tmp = filtfilt(B,A,tmp);
    tmp = tmp - min(tmp);
    tmp = resample(tmp, ResampleRate, ResampleRate_pre);
%%%%%
%figure;
%plot(downsample(tmp,Rate));
%cd(fullfile('ECoG_EMG_Analysis', monkey, 'PreFig', 'EMG'));
%filename = ['No' sprintf('%02d',i)];
%saveas(gca, [filename '.png']);
%cd ../../..
%close
%%%%%%
    preFilt(:,i) = tmp;
end

    %% save the data
% save(fullfile('ECoG_EMG_Analysis', monkey, [monkey '_FiltData'], ...
%     [monkey day], ['No' sprintf('%d',k)]), 'EMG_PreFilt', '-append')
end


% coded by Kotato Himeji
% last modification : 2021.12.14