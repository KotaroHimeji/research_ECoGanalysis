function savePPT()

savePPTName = 'resultSlide';

datDir = fullfile(pwd);
% ActiveX オブジェクトを作成
ppt = actxserver('powerpoint.application');
ppt.Visible = 1;
% ファイルのフルパスを指定し、既存のプレゼンテーションをオープン
% 新しいプレゼンテーションを作成
op = ppt.Presentations.Add();
% プレゼンテーションを4:3にする
op.PageSetup.SlideWidth  = 720;
% スライドレイアウト
layout3 = op.SlideMaster.CustomLayouts.Item(6); % タイトルのみのスライド

% [~, dataLabel, ~] = xlsread('AgINs_EMGreconst_forFunato_20201125(red_corrected)2.xlsx', 'Sheet1', 'A1:X3997');
% for i=1:(length(dataLabel)-1);
%     labelMat = strsplit(dataLabel{i+1});
%     dataLabel{i} = labelMat{1};
% %     dataLabel{i}
% end

dataLabel = cell(1,6);
for i=1:6
    dataLabel{i} = ['Sample' num2str(i)];
end



prop.height=6.61; % cm
prop.width =8.42; % cm
prop.diffTop  = 8; % 縦方向のずれ
prop.num      = 3; % 並べる数
%-結果を表示-%
pageNum = ceil(length(dataLabel)/6);
for pIndx = 1:pageNum
    nInit = 6*(pIndx-1)+1;
    nEnd  = min([6*(pIndx-1)+6, length(dataLabel)]);
    dataLabelPage = dataLabel(nInit:nEnd);
    dataIndxPage  = nInit:nEnd;

    sTitle = [num2str(nInit) '-' num2str(nEnd)];
    sTitle
    drawSlide(op, layout3, sTitle, prop, dataIndxPage, dataLabelPage, [datDir '/figs/sampleFig'])
end
%--%

    
% 新規作成したプレゼンテーションを特定の場所に保存
disp(['Save PPT: ' fullfile(pwd, [savePPTName '.ppt'])]);
op.SaveAs(fullfile(pwd, [savePPTName '.ppt']));
% パワーポイントを閉じ、オブジェクトを削除
op.Close;
ppt.Quit;
% ppt.delete;
end

function rgb=setRGB(col)
rgb = col(1)+256*col(2)+256^2*col(3);
end

%% cm をピクセルに変換
function datP = cm2P(datCM)
datP = datCM*720/25.4;
end

%% シナジーを表示するスライド
function drawSlide(op, layout, sTitle, prop, dataIndxPage, dataLabelPage, filenameOrg)
slide = op.Slides.AddSlide(get(op.Slides,'Count')+1,layout); % スライドの追加
set(slide.Shapes.Title.TextFrame.TextRange,'Text', sTitle);
set(slide.Shapes.Title, 'Top', 0);
leftInit = 0.05; % 左上の左
topInit  = 2.4; % 左上の上

left  =leftInit; % cm
for i=1: length(dataLabelPage)
    disp([num2str(dataIndxPage(i), '%02d') ': ' dataLabelPage{i}]);
    filename = [filenameOrg num2str(dataIndxPage(i), '%02d') '.png'];
    filename
    top = topInit+ floor((i-1)/prop.num)*prop.diffTop;
    % 図
    slide.Shapes.AddPicture(filename, 'msoFalse','msoTrue',cm2P(left),cm2P(top),cm2P(prop.width),cm2P(prop.height));
    % 枠
    rec=slide.Shapes.AddShape('msoShapeRectangle', cm2P(left),cm2P(top),cm2P(prop.width),cm2P(prop.diffTop));
    rec.fill.Visible = 'msoFalse';
    rec.line.Weight = 1; % 太さpt デフォルト: 1
    rec.line.ForeColor.RGB = setRGB([0,0,0]); % 線の色(黒)

    %- 名前 -%
    figTrialBox =slide.Shapes.AddTextbox(...
        'msoTextOrientationHorizontal',cm2P(left)+30,cm2P(top)+195,20*10,20);
    figTrialBox.TextFrame.TextRange.Text = [num2str(dataIndxPage(i), '%02d') '_' dataLabelPage{i}];
    figTrialBox.TextEffect.FontSize = 16;

    %--%
    left = left+prop.width;
    if(rem(i,prop.num)==0 || i==length(dataLabelPage))
        left=leftInit;
    end
end
end

