function [] = VisualizeByGraph(Data,subject,type)
%VISUALIZEBYGRAPH   Visualize some dataset By Graph and save them
%   'Data' should be struct form
%   'Low','High' : range of y axis 
%   TN : trial number
%   WK : what kind of data
%   VN : vertical number of table
%   SN : side number of table

%% variable decidion
fields = fieldnames(Data);
FN = numel(fields); % field number
%TN = numel(Data);
TN = 50; 
switch subject
    case 'frequency'
        I = FN; J = TN;
        if TN > 150
            VN = 12; SN = 17;
            if TN > 204
                J = 204;
            end
        else
            VN = 10; SN = 15;
        end
    case 'trial'
        I = TN; J = FN; 
        if FN > 1
            VN = 2; SN = 5;
        else 
            VN = 1; SN = 1;
        end
end
switch type
    case 'ECoG'
        Low = -10; High = 10;
    case 'EMG'
        Low = -20; High = 120;
    case 'Raw'
        Low = -500; High = 500;
end
%% visualize
for i = 1:I
    if I > 10
        name = ['trial_No.' num2str(i)];
    else
        name = fields{i};
    end
    f = figure('Name',name,'NumberTitle','off');
    f.Position = [200 100 1680 945];
    for j = 1:J
        subplot(VN,SN,j);
        if I > 10
            plot((Data(i).(fields{j}))');
        else
            plot((Data(j).(fields{i}))');
        end
        ylim([Low High]);
    end
    saveas(f,[name '.jpg']);
    close
end
end

% coded by Kotato Himeji
% last modification : 2021.1.14