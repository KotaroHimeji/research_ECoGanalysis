function [DATA] = CutToEpoch(InPort,Switch,data,Type,DATA)
%CUTTOEPOCH     cut to each epoch.  Used in function "EachPrepareForVBSR"
TaskLength = round(mean(InPort(end,:)));

if Switch.SPL1 == 1
    Action = 'SPL1';
    ActionNo = 1;
    cutPoint = [-25 25];  %[a b] : cut at a% and b% point of task length from action point 
    [DATA] = Cutting(InPort,data,Type,TaskLength,DATA,Action,ActionNo,cutPoint);
    if Switch.Timing == 1
        [DATA] = Cutting(InPort,'TIME',Type,TaskLength,DATA,Action,ActionNo,cutPoint);
    end
end

if Switch.EPL1 == 1
    Action = 'EPL1';
    ActionNo = 2;
    cutPoint = [-25 25];
    [DATA] = Cutting(InPort,data,Type,TaskLength,DATA,Action,ActionNo,cutPoint);
    if Switch.Timing == 1
        [DATA] = Cutting(InPort,'TIME',Type,TaskLength,DATA,Action,ActionNo,cutPoint);
    end
end

if Switch.SPL2 == 1
    Action = 'SPL2';
    ActionNo = 3;
    cutPoint = [-25 25];
    [DATA] = Cutting(InPort,data,Type,TaskLength,DATA,Action,ActionNo,cutPoint);
    if Switch.Timing == 1
        [DATA] = Cutting(InPort,'TIME',Type,TaskLength,DATA,Action,ActionNo,cutPoint);
    end
end

if Switch.EPL2 == 1
    Action = 'EPL2';
    ActionNo = 4;
    cutPoint = [-25 25];
    [DATA] = Cutting(InPort,data,Type,TaskLength,DATA,Action,ActionNo,cutPoint);
    if Switch.Timing == 1
        [DATA] = Cutting(InPort,'TIME',Type,TaskLength,DATA,Action,ActionNo,cutPoint);
    end
end

if Switch.FullEM == 1 || Switch.FullEC == 1 || Switch.raw == 1
    Action = 'FullTask';
    ActionNo = 1;
    cutPoint = [-15 115];
    [DATA] = Cutting(InPort,data,Type,TaskLength,DATA,Action,ActionNo,cutPoint);
    if Switch.Timing == 1
        [DATA] = Cutting(InPort,'TIME',Type,TaskLength,DATA,Action,ActionNo,cutPoint);
    end
end
Switch.Timing = 0;
end

function [DATA] = Cutting(InPort,data,type,TaskLength,DATA,Action,ActionNo,cutPoint)
taskStart = InPort(ActionNo,:) + round(TaskLength.*cutPoint(1)*0.01); 
taskEnd = InPort(ActionNo,:) + round(TaskLength.*cutPoint(2)*0.01); 
if taskStart(1) < 1
    taskStart(1) = [];
    taskEnd(1) = [];
    T(1,:) = [];
end

if ischar(data)
    switch Action
        case 'FullTask'
            T = T(:,2:5);
            timingData = T - taskStart;
        otherwise
            timingData = (ActionTiming - taskStart);
    end
    taskLength = taskEnd - taskStart;
    for i = 1:numel(taskStart)
        DATA.(Action)(i).('Timing') = timingData(i,:);
        DATA.(Action)(i).('Length') = taskLength(i);
    end
else
    if taskEnd(end) > numel(data(1,:))  
        taskStart(end) = [];
        taskEnd(end) = [];
    end
    for i = 1:numel(taskStart)
        DATA.(Action)(i).(type) = data(:,[taskStart(i):taskEnd(i)]);
    end
end

end


% coded by Kotato Himeji
% last modification : 2021.1.21