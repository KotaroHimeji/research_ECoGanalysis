function [model_set,Counter,fre_band,PreEpochData] = Which_band_better(monkey,day,part)
%WHICH_BAND_BETTER この関数の概要をここに記述
%   詳細説明をここに記述


load(fullfile('ECoG_EMG_Analysis',monkey,[monkey '_VBSR'],[monkey day],['No' part]),...
    'PreEpochData','COT','BFIL')

ReadyFor
J = numel(BFIL);
necog = numel(PreEpochData.X.ECoG001(:,1));
N_ECoG = necog/J;  %Number of ECoG

%% make frequency band matrix

fre_band = cell(1,J-1); %Frequency band
for j = 1:J-1
    h = J-j+1;
    fre_band{j} = [BFIL{1} '_' BFIL{h}];
end

%% sparse regression by reducing aspecific band data 

for i = 1:COT
    
    X = PreEpochData.X.(['ECoG' sprintf('%03d',i)]);
    Y = PreEpochData.Y.(['EMG' sprintf('%03d',i)]);
%    Y = PreEpochData.Z.(['EMGFS' sprintf('%03d',i)]);
    
    for j = 1:J-1
        h = J-j+1;
        
        if j ~= 1
            del_head = N_ECoG*h+1;  %head element to delete
            del_back = N_ECoG*(h+1);  %head element to delete
            X(del_head:del_back,:) = []; %delete data of a specific electrisity
        end
        
        [model] = linear_sparse_space(X,Y,Model,parm);
        
        model_set.(fre_band{j})(i) = model;
    end
end


%% which data is necessary

[Counter] = CounterECoGEle(model_set,fre_band);

end

