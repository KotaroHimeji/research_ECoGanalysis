% FULLPREFILT_CONTCLFP �Ώۂ�'monkey'��'SharedData'���̃f�[�^�ɑ΂���O����
% --�d�l--
% RAW_data��LFP_data�ɑ΂��ĉ�͉\�Ȍ`�ɐ��`����B
% 'easyRawData'�͎��g����͗p�̃f�[�^�icreate_ECoCspec_lfp.m�Ɏg�p�j
% 'FiltData'�͉�A���͗p�A�]�g�Ɋւ��P�f�[�^���V�̎��g���тɕ������Ă���
% �u�Ώۂ̃T���v�u�e�T���̏��ݒ�v�̂݁A�����Őݒ肷��ϐ�������
clear all
global ResampleRate actionPointList
%%%%%%%%%%%%% �Ώۂ̃T�� %%%%%%%%%%%%
    monkey = 'testset';                  % 'Wa' or 'Ni' or 'testset'
%%%%%%%%%% �e�T���̏��ݒ� %%%%%%%%%
switch monkey
    case 'Wa'
        need = {'CEMG','CRAW','CLFP','CInPort'};
        actionPointList = {'SPL1', 'EPL1', 'SPL2', 'EPL2'};  % SPL: start pulling lever
        ResampleRate = 500; % Hz                             % EPL: end pulling lever
    case 'Ni'
        need = {'CEMG','CRAW','CLFP'};
        actionPointList = {'ST', 'SON', 'SOF', 'ET'}; % ST: start task, SON: switch on
        ResampleRate = 1375; % Hz                     % ET: end task,   SOF: switch off
    case 'testset'      % nibali��3�`�����l�������̃f�[�^�Z�b�g
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


%% �������̂P���̃f�[�^��ΏۂƂ����O����
function toEasyData(monkey,day)
%- �K�v�ƂȂ�f�[�^�̎擾 -%
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

%- �A���P���s���P�f�[�^�ɂ܂Ƃ߂邽�߂̏��� -%
% �v���@��̓s����A�A�����Čv�������f�[�^�ł��f�[�^�e�ʂ����l�ɒB����ƁA
% �r���ŕʂ̃t�@�C���Ƃ��ĕۑ�����Ă��܂��B����āA���̌v���f�[�^�����
% �f�[�^�Z�b�g�Ƃ��Ă܂Ƃ߂��Ƃ��s���K�v������B
FileNum = numel(FileName);
S = 1;   recTimes = 1;    % S:�������ꂽ�A���f�[�^�̐擪  % recTimes:�v����
load(FileName{1}, 'CLFP_001_TimeBegin');
TimeBegin = CLFP_001_TimeBegin;
for i = 1 : FileNum-1
    load(FileName{i},'CLFP_001_TimeEnd')
    load(FileName{i+1},'CLFP_001_TimeBegin')
    if round(CLFP_001_TimeEnd - CLFP_001_TimeBegin,2) ~= 0
        series{recTimes} = [S i];      % [�A���f�[�^�̐擪�@�A���f�[�^�̌��]
        TimeLength{recTimes} = [TimeBegin, CLFP_001_TimeEnd] ;
        S = i + 1;      recTimes = recTimes + 1;
        TimeBegin = CLFP_001_TimeBegin;
    end
end
load(FileName{FileNum},'CLFP_001_TimeEnd')
series{recTimes} = [S FileNum];
TimeLength{recTimes} = [TimeBegin, CLFP_001_TimeEnd] ;

%- �^�C�~���O�f�[�^�̐��� -%
switch monkey
    case 'Wa'
        InPort = EpochInfo(FileName, series, monkey, day, TimeLength);
    case {'Ni','testset'}
        FileTime = dir(fullfile('ECoG_EMG_Analysis', monkey, 'SharedData', [monkey day '-timing.mat']));
        FileTime = {FileTime.name};
        InPort = EpochInfo(FileTime, series, monkey, day, TimeLength);
end
%- �A���P���s���P�f�[�^�ɂ܂Ƃ߂� -%
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
    %- ���g����͗p��3�����Ƀf�[�^�̌`��ς���ichannel * frame * task�j -%
    ECoG_raw = to3dim(ECoGOD, InPort);
    EMG_raw = to3dim(EMGOD, InPort);
    LFP_raw = to3dim(LFPOD, InPort);
    save(fullfile('ECoG_EMG_Analysis', monkey, 'FiltData', [monkey day...
        '_' sprintf('%d',i)]), 'BFIL', 'actionPointList', 'EMG_raw',...
        'ECoG_raw', 'LFP_raw', 'EMG_Hz', 'ECoG_Hz', 'LFP_Hz', '-append')
    %- �K�v�ȃf�[�^��������Ă��邩�̊m�F -%
    A = exist('InPort','var');
    if (A < 1) || (numel(InPort) == 0)
        warning([monkey day '_' sprintf('%d',part) ' do not have enough data!']);
        return
    elseif InPort(1,1) < 0
        warning([monkey day '_' sprintf('%d',part) ' have wrong InPort. There is "-" timing!']);
        return
    else
        %- VBSR�p�ɂR�����I�Ƀf�[�^�`�� -%
        ECoG_filt = to3dim(ecog.', InPort);
        EMG_filt = to3dim(emg.', InPort);
        LFP_filt = to3dim(lfp.', InPort);
        save(fullfile('ECoG_EMG_Analysis',monkey,'FiltData',...
            [monkey day '_' sprintf('%d',i)]),'EMG_filt','ECoG_filt',...
            'LFP_filt', '-append')
    end
end
end

%% �f�[�^�A��
function Data = Integrate(FileName, N, data)
electrodeNum = numel(struct2cell(load(FileName{1}, [data '*Hz'])));
Data = cell(electrodeNum,N);
for i = 1:N
    for j= 1:electrodeNum
        Data(j,i) =  struct2cell(load(FileName{i}, [data '_' sprintf('%03d',j)]));
    end
end
end

%% channel*frame�̓񎟌��f�[�^������ɁA���s�񐔂�ǉ����ĎO�����ŕ\��
function [Data] = to3dim(data, InPort)
global actionPointList
X = size(data,1);      %channel
T = round(0.25 * mean(InPort(5,:))); %���ڂ���^�C�~���O�̑O��̃t���[����
Z = size(InPort,2);    %���s��
%- ���ڂ���^�C�~���O�t�߂ɑ΂��� -%
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
% T = ResampleRate;   %�O��P�b�Ԃ̃f�[�^
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