function [] = makeDataset(monkey,day,part)
%EACHPREPAREFORVBSR  Each Preparation For VBSR ,NEXT...Analysis
%1st.combine, 
%2nd.separate to each epoch and tasks

%   !caution!
%   if you nead, you should change contents of ReadyFor.m)

%%%%%%%%%% Switch for data type %%%%%%%%%%%
Switch.ECOG     = 1;    
Switch.EMG      = 1;    %0/1 = n/y          
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
Switch.Timing = 1;                       %% DON'T CHANGE!!!!!!!!!!
%%%%%%%% Switch for target action %%%%%%%%%
Switch.SPL1 = 1;        Switch.SPL2 = 1;    %SPL : start pulling lever
Switch.EPL1 = 1;        Switch.EPL2 = 1;    %EPL : end pulling lever
Switch.FullEM = 1;      Switch.FullEC = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Checkking if you have enough data
load(fullfile('ECoG_EMG_Analysis',monkey,[monkey '_FiltData'],...
    [monkey day],['No' part]),'AllInPort')
A = exist('AllInPort','var');
if (A < 1) || (numel(AllInPort) == 0)
    warning([monkey day '\No' part ' do not have enough data!']);
    return
elseif AllInPort(1,1) < 0
    warning([monkey day '\No' part ' have wrong AllInPort. There is "-" timing!']);
    return
else
%% AllInPort to nPort (time normalize for AllInPort)
    InPort = NormalizeTime(AllInPort,'IP');
    
%% 1st.combine, 2nd.cut each epoch(each task)
    EpochData = struct;
%    EpochData_rec = struct;  % only for ECoG_wid, ECoG_rec, ECoG_koi
    if Switch.ECOG == 1
        Type = 'ECoG';
        [ECoG,EN] = ToOneMatrix(monkey,day,part,'ECoG_PreFilt');
        if EN ~= 0
            ECoG = NormalizeTime(ECoG,AllInPort);
            EpochData = CutToEpoch(InPort,Switch,ECoG,Type,EpochData);
        end
        Switch.FullEC = 0;
    end

    if Switch.EMG == 1         %switch for EMG
        Type = 'EMG';
        [EMG,EN] = ToOneMatrix(monkey,day,part,'EMG_PreFilt');
        if EN ~= 0
            EMG = NormalizeTime(EMG,AllInPort);
            EpochData = CutToEpoch(InPort,Switch,EMG,Type,EpochData);
        end
    end
    
    NumberOfTask = size(InPort,2);
    Epoch_Full = EpochData.FullTask;
    Epoch_SPL1 = EpochData.SPL1;
    Epoch_EPL1 = EpochData.EPL1;
    Epoch_SPL2 = EpochData.SPL2;
    Epoch_EPL2 = EpochData.EPL2;

    mkdir(['F:\ECoG_EMG_Analysis\' monkey '_VBSR'],[monkey day])
    save(fullfile('ECoG_EMG_Analysis',monkey,[monkey '_VBSR'],...
        [monkey day],['No' part]),'InPort','NumberOfTask',...
        'Epoch_Full','Epoch_SPL1','Epoch_EPL1','Epoch_SPL2','Epoch_EPL2')
    addpath(fullfile('ECoG_EMG_Analysis',monkey,[monkey '_VBSR'],[monkey day]))
end
end


function [Z,NE] = ToOneMatrix(monkey,day,part,data)
%TOONEMATEMG to one matrix.  Used in function "EachPrepareForVBSR"

preDATA = load(fullfile('ECoG_EMG_Analysis',monkey,[monkey '_FiltData'],[monkey day],['No' part]),data);
name = fieldnames(preDATA);
if numel(name) == 0
    Z = 0;
    NE = 0;
    BadMessage = [data 'could not be found!'];
    warning(BadMessage);
else
    DATA = preDATA.(name{1});
    switch data
        case 'EasyRawData'
            Z = DATA;
            NE =  numel(DATA(:,1));  %number of Electrodes
    
        case 'ECoG_PreFilt'
            NE = numel(fieldnames(DATA));  %number of Electrodes
            NB = numel(DATA.No_01);  %number of Band
            NT = numel(DATA.No_01{1});  %number of timming
            A = zeros(NT,NE*NB);
            for i = 1:NE
                for j = 1:NB
                    A(:,NE*(j-1)+i) = DATA.(['No_' sprintf('%02d',i)]){j};
                end
            end
            Z = A';
    
        otherwise
            NE = numel(fieldnames(DATA));  %number of Electrodes
            NT = numel(DATA.No_01);  %number of timming 
            A = zeros(NT,NE);
            for i = 1:NE
                A(:,i) = DATA.(['No_' sprintf('%02d',i)]);
            end
            Z = A';
    end
end
end

% coded by Kotato Himeji
% last modification : 2021.1.28