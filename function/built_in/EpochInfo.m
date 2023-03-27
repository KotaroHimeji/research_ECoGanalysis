function [InPort] = EpochInfo(FileName,series,monkey,day,TimeLength)

%%%%%%%%%% Neseccary Task Number for Analysis %%%%%%%%%%%
TS   = 1092;   %trial start
SPL1 = 1296;   %start pulling lever 1
EPL1 =   80;   %end pulling lever 1
SPL2 = 1104;   %start pulling lever 2
EPL2 =  336;   %end pulling lever 2
ST   = 1024;   %success trial
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
TaskPoint = [TS, SPL1, EPL1, SPL2, EPL2, ST];
TaskPointNum = numel(TaskPoint);
global ResampleRate
switch monkey
    case {'Ni', 'testset'}
        for i = 1:numel(series)
            load(FileName{1}, 'success_timing', 'timing_Hz')
            InPort = success_timing;
            InPort = round(InPort .* ResampleRate ./ timing_Hz);
            S = std(InPort(end,:));
            M = mean(InPort(end,:));
            BadTrial = M - 2*S > InPort(end,:) | InPort(end,:) > M + 2*S;
            InPort(:,BadTrial) = [];
            InPort(:,1) = [];
            InPort(1:end-1,:) = InPort(1:end-1,:) - round(ResampleRate/10);
            %- save the Data -%
            save(fullfile('ECoG_EMG_Analysis', monkey, 'FiltData', ...
                [monkey day '_' sprintf('%d',i)]), 'InPort', '-v7.3')
        end
        
    case 'Wa'
        load(FileName{1}, 'CInPort_001_KHz')
        for i = 1:numel(series)
            %- combine continuous data -%
            InPort_cell = cell(1, series{i}(2)-series{i}(1)+1);
            k = 1;
            for j = series{i}(1):series{i}(2)
                load(FileName{j}, 'CInPort_001')
                InPort_cell{k} = CInPort_001;
                k = k+1;
            end
            InPort = cell2mat(InPort_cell);
            %- delete the unneseccary data -%
            I = numel(InPort(1,:));
            AllInPort_eva = ismember(InPort(2,:), TaskPoint);
            k = 1;
            for j= 1:I
                if AllInPort_eva(1,j)
                    k = k+1;
                else
                    InPort(:,k) = [];
                end
            end
            %- deleate what isn't consist 6 task -%
            TS_location = find (ismember(InPort(2,:), TS));
            TS_num = numel(TS_location);
            gap = 0;
            for  j = 1:TS_num-1
                NUM = TS_location(j+1) - TS_location(j);
                if NUM ~= TaskPointNum
                    for L = 1:NUM
                        InPort(:, TS_location(j)+gap) = [];
                    end
                    gap = gap - NUM;
                end
            end
            %- adjust 'trial start' to head and delete surplus data at back -%
            if numel(InPort(2,:)) < 6
                warning(['In the File FiltData\' monkey day '_' sprintf('%d',i) ', Timing Data is broken or There is no data']);
                NoInPort = 'Broken';
                save(fullfile('ECoG_EMG_Analysis', monkey, 'FiltData', ...
                    [monkey day '_' sprintf('%d',i)]), 'NoInPort')
            else
                for j = 1:TS_location(1)-1
                    InPort(:,1) = [];
                end
                HME = size(InPort, 2)/TaskPointNum;
                if HME ~= floor(HME)
                    J = round((HME-floor(HME))*TaskPointNum);
                    for j = 1:J
                        InPort(:,floor(HME)*TaskPointNum+1) = [];
                    end
                end
                %- Are the file's ordars correct? -%
                TS_Epoch = 1;
                for j = 1:floor(HME)
                    TS_Epoch_end = TS_Epoch + TaskPointNum - 1;
                    PreMatrix = InPort(2, [TS_Epoch:TS_Epoch_end]);
                    if isequal(PreMatrix,TaskPoint)
                        TS_Epoch = TS_Epoch_end + 1;
                    else
                        for O = 1:TaskPointNum
                            InPort(:, TS_Epoch) = [];
                        end
                    end
                end
                %- adjust Start timing and Sampling rate -%
                CInPort_001_Hz = CInPort_001_KHz * 1000;
                InPort(1,:) = InPort(1,:) - TimeLength{i}(1) * CInPort_001_Hz;
                InPort(1,:) = floor(InPort(1,:)/(CInPort_001_Hz/ResampleRate));
                %- delete too long or short data -%
                InPort = reshape(InPort(1,:),TaskPointNum,[]);
                InPort(1,:) = [];
                InPort(end,:) = InPort(end-1,:) - InPort(1,:);
                S = std(InPort(end,:));
                M = mean(InPort(end,:));
                BadTrial = M - S > InPort(end,:) | InPort(end,:) > M + S;
                InPort(:,BadTrial) = [];
                InPort(:,1) = [];
                %- save the Data -%
                save(fullfile('ECoG_EMG_Analysis', monkey, 'FiltData', ...
                    [monkey day '_' sprintf('%d',i)]),'InPort','ResampleRate')
            end
        end
end
end