function savePPT()

savePPTName = 'resultSlide';

datDir = fullfile(pwd);
% ActiveX �I�u�W�F�N�g���쐬
ppt = actxserver('powerpoint.application');
ppt.Visible = 1;
% �t�@�C���̃t���p�X���w�肵�A�����̃v���[���e�[�V�������I�[�v��
% �V�����v���[���e�[�V�������쐬
op = ppt.Presentations.Add();
% �v���[���e�[�V������4:3�ɂ���
op.PageSetup.SlideWidth  = 720;
% �X���C�h���C�A�E�g
layout3 = op.SlideMaster.CustomLayouts.Item(6); % �^�C�g���݂̂̃X���C�h

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
prop.diffTop  = 8; % �c�����̂���
prop.num      = 3; % ���ׂ鐔
%-���ʂ�\��-%
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

    
% �V�K�쐬�����v���[���e�[�V���������̏ꏊ�ɕۑ�
disp(['Save PPT: ' fullfile(pwd, [savePPTName '.ppt'])]);
op.SaveAs(fullfile(pwd, [savePPTName '.ppt']));
% �p���[�|�C���g����A�I�u�W�F�N�g���폜
op.Close;
ppt.Quit;
% ppt.delete;
end

function rgb=setRGB(col)
rgb = col(1)+256*col(2)+256^2*col(3);
end

%% cm ���s�N�Z���ɕϊ�
function datP = cm2P(datCM)
datP = datCM*720/25.4;
end

%% �V�i�W�[��\������X���C�h
function drawSlide(op, layout, sTitle, prop, dataIndxPage, dataLabelPage, filenameOrg)
slide = op.Slides.AddSlide(get(op.Slides,'Count')+1,layout); % �X���C�h�̒ǉ�
set(slide.Shapes.Title.TextFrame.TextRange,'Text', sTitle);
set(slide.Shapes.Title, 'Top', 0);
leftInit = 0.05; % ����̍�
topInit  = 2.4; % ����̏�

left  =leftInit; % cm
for i=1: length(dataLabelPage)
    disp([num2str(dataIndxPage(i), '%02d') ': ' dataLabelPage{i}]);
    filename = [filenameOrg num2str(dataIndxPage(i), '%02d') '.png'];
    filename
    top = topInit+ floor((i-1)/prop.num)*prop.diffTop;
    % �}
    slide.Shapes.AddPicture(filename, 'msoFalse','msoTrue',cm2P(left),cm2P(top),cm2P(prop.width),cm2P(prop.height));
    % �g
    rec=slide.Shapes.AddShape('msoShapeRectangle', cm2P(left),cm2P(top),cm2P(prop.width),cm2P(prop.diffTop));
    rec.fill.Visible = 'msoFalse';
    rec.line.Weight = 1; % ����pt �f�t�H���g: 1
    rec.line.ForeColor.RGB = setRGB([0,0,0]); % ���̐F(��)

    %- ���O -%
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

