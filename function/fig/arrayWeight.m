clear all

%%%%%%%%%%%%%%%% which monkey %%%%%%%%%%%%%%%%
                monkey = 'Ni';                  % 'Wa' or 'Ni'
%%%%%%%%%%%%%% select .mat file %%%%%%%%%%%%%%
Dname = 'Ni20220516_1';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
file = dir(fullfile('ECoG_EMG_Analysis',monkey,'lookForTimeGap',Dname));
path = file(1).folder;
file = {file.name};
cd(path); cd ..
mkdir([Dname '_figure']); cd([Dname '_figure']);


cx = 1:6; cy = flip(cx);
cx = repmat(cx,1,6); cy = repelem(cy,6);
cx([31 32 35 36]) = []; cy(33:end) =[];

t = linspace(0,2*pi,100);   
for i = 1:numel(file)-2
    fName = extractBefore(file{i+2},'.');
    mkdir(fName); cd(fName);
    load([path '\' file{i+2}],'Result');
    emg = Result.target.EMG;
    cc = Result.CC_mean; f = fieldnames(cc);
    c = 0;
    for j = 1:numel(f)-1
        if sum(cc.(f{j})) > c
            c = sum(cc.(f{j}));
            J = j;
        end
    end
    CC = cc.(f{J});
    ch = Result.model(J).ECoG.ix_act;
    w = Result.model(J).ECoG.W; w(w(:,1)==0,:)=[];
    w = w./repmat(max(abs(w),[],2),1,size(w,2));
    
    for j = 1:numel(emg)
        figure('Position',[50 50 1200 500]); hold on;
        N = 1; M = 1;
        for k = 1:10 %bandÇÃêî
            subplot(2,5,k);
            for l = 1:32
                patch(1/4*sin(t)+cx(l),1/4*cos(t)+cy(l),'k')
                if M <= size(w,2)
                    if N == ch(M)
                        if w(j,M) >= 0
                            patch(1/2*sin(t)+cx(l),1/2*cos(t)+cy(l),[1 0 0],'EdgeColor','none','FaceAlpha',w(j,M))
                        else
                            patch(1/2*sin(t)+cx(l),1/2*cos(t)+cy(l),[0 0 1],'EdgeColor','none','FaceAlpha',abs(w(j,M)))
                        end
                        M = M+1;
                    end
                end
                N = N+1;
            end
            axis([0,7,0,7])
            axis square
        end
        saveas(gcf,[emg{j} '.jpg'])
    end
    cd ..
    close all
end