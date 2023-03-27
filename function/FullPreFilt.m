% FULLPREFILT_CONTCLFP 対象の'monkey'の'SharedData'内のデータに対する前処理
% --仕様--
% RAW_dataとLFP_dataに対して解析可能な形に成形する。
% 'easyRawData'は周波数解析用のデータ（create_ECoCspec_lfp.mに使用）
% 'FiltData'は回帰分析用、脳波に関し１データを７つの周波数帯に分解している
% 「対象のサル」「各サルの情報設定」のみ、自分で設定する変数を扱う
clear all
global ResampleRate actionPointList
%%%%%%%%%%%%% 対象のサル %%%%%%%%%%%%
    monkey = 'testset';                  % 'Wa' or 'Ni' or 'testset'
%%%%%%%%%% 各サルの情報設定 %%%%%%%%%
switch monkey
    case 'Wa'
        need = {'CEMG','CRAW','CLFP','CInPort'};
        actionPointList = {'SPL1', 'EPL1', 'SPL2', 'EPL2'};  % SPL: start pulling lever
        ResampleRate = 500; % Hz                             % EPL: end pulling lever
    case 'Ni'
        need = {'CEMG','CRAW','CLFP'};
        actionPointList = {'ST', 'SON', 'SOF', 'ET'}; % ST: start task, SON: switch on
        ResampleRate = 1375; % Hz                     % ET: end task,   SOF: switch off
    case 'testset'      % nibaliの3チャンネルだけのデータセット
        need = {'CEMG','CRAW','CLFP'}; 
        actionPointList = {'ST', 'SON', 'SOF', 'ET'}; % ST: start task, SON: switch on
        ResampleRate = 1375; % Hz                     % ET: end task,   SOF: switch off
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FileInfo = dir(fullfile('ECoG_EMG_Analysis', monkey, 'SharedData', [monkey '*' '-0*']));
FileInfo  = {FileInfo.name};
FileInfo  = unique(extractBefore(FileInfo,'-'));
%DAY  = extract(FileInfo,digitsPattern);
for i = 1%:numel(DAY)
    Elem = dir(fullfile('ECoG_EMG_Analysis', monkey, 'SharedData', ['*' FileInfo{i} '-0*']));
    Elem = {Elem.name};     Elem = who('-file',Elem{1});
    Elem = unique(extractBefore(Elem,'_'));
    if sum(ismember(Elem, need)) == numel(need)
        disp(['Start preFiltering  with ' FileInfo{i} '  (i = ' sprintf('%d',i) ')']);
%         day = DAY{i};
        day = '20220516';
        toEasyData(monkey,day);
    else                     
       warning([FileInfo{i} '-****.mat is not available for analysis'])
    end
end


%% ある特定の１日のデータを対象とした前処理
function toEasyData(monkey,day)
%- 必要となるデータの取得 -%
global ResampleRate actionPointList
FileName = dir(fullfile('ECoG_EMG_Analysis', monkey, 'SharedData', [monkey day '-0*']));
FileName = {FileName.name};
load(FileName{1}, 'CRAW_001_KHz');
load(FileName{1}, 'CEMG_001_KHz');
load(FileName{1}, 'CLFP_001_KHz');
load(FileName{1}, 'CLFP_001_BitResolution');
load(FileName{1}, 'CLFP_001_Gain');
EMG_Hz  = str2double(string(CEMG_001_KHz)) * 1000;
ECoG_Hz = str2double(string(CRAW_001_KHz)) * 1000;
LFP_Hz = str2double(string(CLFP_001_KHz)) * 1000;

%- 連続１試行を１データにまとめるための準備 -%
% 計測機器の都合上、連続して計測したデータでもデータ容量が一定値に達すると、
% 途中で別のファイルとして保存されてしまう。よって、一回の計測データを一つの
% データセットとしてまとめる作業を行う必要がある。
FileNum = numel(FileName);
S = 1;   recTimes = 1;    % S:分割された連続データの先頭  % recTimes:計測回数
load(FileName{1}, 'CLFP_001_TimeBegin');
TimeBegin = CLFP_001_TimeBegin;
for i = 1 : FileNum-1
    load(FileName{i},'CLFP_001_TimeEnd')
    load(FileName{i+1},'CLFP_001_TimeBegin')
    if round(CLFP_001_TimeEnd - CLFP_001_TimeBegin,2) ~= 0
        series{recTimes} = [S i];      % [連続データの先頭　連続データの後尾]
        TimeLength{recTimes} = [TimeBegin, CLFP_001_TimeEnd] ;
        S = i + 1;      recTimes = recTimes + 1;
        TimeBegin = CLFP_001_TimeBegin;
    end
end
load(FileName{FileNum},'CLFP_001_TimeEnd')
series{recTimes} = [S FileNum];
TimeLength{recTimes} = [TimeBegin, CLFP_001_TimeEnd] ;

%- タイミングデータの整理 -%
switch monkey
    case 'Wa'
        InPort = EpochInfo(FileName, series, monkey, day, TimeLength);
    case {'Ni','testset'}
        FileTime = dir(fullfile('ECoG_EMG_Analysis', monkey, 'SharedData', [monkey day '-timing.mat']));
        FileTime = {FileTime.name};
        InPort = EpochInfo(FileTime, series, monkey, day, TimeLength);
end
%- 連続１試行を１データにまとめる -%
ECoGod = Integrate(FileName, FileNum, 'CRAW');
EMGod  = Integrate(FileName, FileNum, 'CEMG');
LFPod  = Integrate(FileName, FileNum, 'CLFP');
for i = 1:recTimes
    ECoGOD = cell2mat(ECoGod(:, series{i}(1):series{i}(2)));
    EMGOD  = cell2mat(EMGod(:, series{i}(1):series{i}(2)));
    LFPOD  = cell2mat(LFPod(:, series{i}(1):series{i}(2)));
    LFPOD  = LFPOD.*CLFP_001_BitResolution./CLFP_001_Gain;
    [ecog, BFIL] = FiltECoG_gausAbs(ECoGOD, ECoG_Hz, ResampleRate);
%     [ecog, BFIL] = FiltECoG_absGaus(ECoGOD, ECoG_Hz, ResampleRate);
    lfp = FiltECoG_gausAbs(LFPOD, LFP_Hz, ResampleRate);
%     lfp = FiltECoG_absGgaus(LFPOD, LFP_Hz, ResampleRate);
    emg = FiltEMG(EMGOD, EMG_Hz, ResampleRate, monkey);
    %- 周波数解析用の3次元にデータの形を変える（channel * frame * task） -%
    ECoG_raw = to3dim(ECoGOD, InPort);
    EMG_raw = to3dim(EMGOD, InPort);
    LFP_raw = to3dim(LFPOD, InPort);
    save(fullfile('ECoG_EMG_Analysis', monkey, 'FiltData', [monkey day...
        '_' sprintf('%d',i)]), 'BFIL', 'actionPointList', 'EMG_raw',...
        'ECoG_raw', 'LFP_raw', 'EMG_Hz', 'ECoG_Hz', 'LFP_Hz', '-append')
    %- 必要なデータがそろっているかの確認 -%
    A = exist('InPort','var');
    if (A < 1) || (numel(InPort) == 0)
        warning([monkey day '_' sprintf('%d',part) ' do not have enough data!']);
        return
    elseif InPort(1,1) < 0
        warning([monkey day '_' sprintf('%d',part) ' have wrong InPort. There is "-" timing!']);
        return
    else
        %- VBSR用に３次元的にデータ形成 -%
        ECoG_filt = to3dim(ecog.', InPort);
        EMG_filt = to3dim(emg.', InPort);
        LFP_filt = to3dim(lfp.', InPort);
        save(fullfile('ECoG_EMG_Analysis',monkey,'FiltData',...
            [monkey day '_' sprintf('%d',i)]),'EMG_filt','ECoG_filt',...
            'LFP_filt', '-append')
    end
end
end

%% データ連結
function Data = Integrate(FileName, N, data)
electrodeNum = numel(struct2cell(load(FileName{1}, [data '*Hz'])));
Data = cell(electrodeNum,N);
for i = 1:N
    for j= 1:electrodeNum
        Data(j,i) =  struct2cell(load(FileName{i}, [data '_' sprintf('%03d',j)]));
    end
end
end

%% channel*frameの二次元データをさらに、試行回数を追加して三次元で表す
function [Data] = to3dim(data, InPort)
global actionPointList
X = size(data,1);      %channel
T = round(0.25 * mean(InPort(5,:))); %注目するタイミングの前後のフレーム数
Z = size(InPort,2);    %試行回数
%- 注目するタイミング付近に対して -%
for i = 1:numel(actionPointList)
    tmp = zeros(X,2*T+1,Z);
    pre = InPort(i,:) - T;
    post = InPort(i,:) + T;
    for z = 1:Z
        tmp(:,:,z) = data(:,pre(z):post(z));
    end
    Data.(actionPointList{i}) = tmp;
end
%- full task -%
% T = ResampleRate;   %前後１秒間のデータ
T = 1350;
tmp = zeros(X,2*T+1,Z);
pre = InPort(4,:) - T;
post = InPort(4,:) + T;
for z = 1:Z
    tmp(:,:,z) = data(:,pre(z):post(z));
end
Data.All = tmp;
end

% coded by Kotato Himeji
% last modification : 2022.7.19