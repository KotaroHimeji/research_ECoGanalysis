function [DATA] = NormalizeTime(data,InPort)
%NORMALIZETIME normalize for timeseriese
%   if data is not there, promote Lagrange primary complement

 if ischar(InPort)
    DATA = data;
    ratio = round(mean(data(end,:))) ./ data(end,:);
    for i = 1:numel(data(:,1))-3
        dt = data(1+i,:) - data(1,:);
        DATA(1+i,:) = DATA(1,:) + round(dt .* ratio);
    end
    dt = round(mean(data(end,:))) - data(end,:);
    DATA(end-1,:) = DATA(end-1,:) + dt;
    for i = 1:size(data,2)-1
        DATA(1:end-1,1+i) = DATA(1:end-1,1+i) + sum(dt(1:i));
    end
    DATA(end,:) = DATA(end-1,:) - DATA(1,:);
    
else
%     N = numel(unique(InPort(2,:)));

    %ts = find(IP(2,:) == IP(2,1));
    %te = find(IP(2,:) == IP(2,N));
    %t = IP(1,te) - IP(1,ts);
    
%     taskStart = find(InPort(2,:) == InPort(2,2));
%     taskEnd = find(InPort(2,:) == InPort(2,N-1));
%     eachTaskLength = InPort(1,taskEnd) - InPort(1,taskStart);
%     TaskLength = round(mean(eachTaskLength));
%     taskN = numel(eachTaskLength);
    
    
    M = size(data,1);           %data : M x T
    T = size(data,2);
    dT = T - sum(InPort(end,:));
    taskLengthMean = round(mean(InPort(end,:)));
    J = 0;  JJ = 0; tE = 0;
    DATA = zeros(M, dT + taskLengthMean * size(InPort,2)); 
    ratio = taskLengthMean ./ InPort(end,:);
    
    for i = 1:size(InPort,2)
        ds = InPort(1,i) - tE;
        JS = J + ds;
        JJS = JJ + ds;
        DATA(:,J+1:JS) = data(:,JJ+1:JJS);
        k = 1;
        for j = 1:taskLengthMean
            if j == k*ratio(i)
                DATA(:,JS+j) = data(:,JJS+k);
            else
                while j > k*ratio(i)
                    k = k + 1;
                end
                if JJS + k > T
                    DATA(:,JS+j) = data(:,JJS+k-1);
                else
                    %ddata = data(:,JJS+k) - data(:,JJS+k-1);
                    %dh = ddata * (j - (k-1)*ratio(i)) / ratio(i);
                    dh = (data(:,JJS+k) - data(:,JJS+k-1)) ...
                        * (j/ratio(i) -k+1);
                    DATA(:,JS+j) = data(:,JJS+k-1) + dh;
                end
            end
        end
        J = J + ds + taskLengthMean;
        JJ = JJ + ds + InPort(end,i);
        tE = InPort(end-1,i);
    end
    DATA(:,J:end) = data(:,JJ:end);
    
    
%     %T = round(mean(t));
%     M = numel(data(:,1));           %data : M x TT
%     TT = numel(data(1,:));
%     %dTT = TT - sum(t);
%     dTT = TT - sum(eachTaskLength);
%     J = 0;  JJ = 0; tE = 0;
%     DATA = zeros(M,dTT+TaskLength*taskN);
%     
%     for i = 1:taskN
%         %ds = IP(1,ts(i)) - tE;
%         ds = InPort(1,taskStart(i)) - tE;
%         JS = J + ds;
%         JJS = JJ + ds;
%         DATA(:,J+1:JS) = data(:,JJ+1:JJS);
%         %dT = T/t(i);
%         ratio = TaskLength/eachTaskLength(i);
%         k = 1;
%         %for j = 1:T
%         for j = 1:TaskLength
%             if j == k*ratio
%                 DATA(:,JS+j) = data(:,JJS+k);
%             else
%                 while j > k*ratio
%                     k = k + 1;
%                 end
%                 if JJS + k > TT
%                     DATA(:,JS+j) = data(:,JJS+k-1);
%                 else
%                     dd = data(:,JJS+k) - data(:,JJS+k-1);                  
%                     dh = dd * (j-(k-1)*ratio)/ratio;
%                     DATA(:,JS+j) = data(:,JJS+k-1) + dh;
%                 end
%             end
%         end
%         %J = J + ds + T;
%         %JJ = JJ + ds + t(i) ;
%         %tE = IP(1,te(i));
%         
%         J = J + ds + TaskLength;
%         JJ = JJ + ds + eachTaskLength(i) ;
%         tE = InPort(1,taskEnd(i));
%     end
%     DATA(:,J:end) = data(:,JJ:end);

end
end

