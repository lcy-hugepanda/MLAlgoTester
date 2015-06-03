% 人工数据集的生成函数，默认生成单类数据集，红色的点是target
function A  = MLAT_GenAritificialData(idx)
    if 1 == idx
        A = DataArtificialGenForOCC('banana',[200,200]);
    elseif 2 == idx
        A = DataArtificialGenForOCC('rectangle',[200,200],[2 2 1 1],20);
    elseif 3 == idx
        A = DataArtificialGenForOCC('sine',[150,50],[1 10 2 1],25);
    elseif 4 == idx % 双螺旋数据
        A = DataArtificialGenForOCC('spiral',[300,300],[],40);
    elseif 5 == idx
        A = DataArtificialGenForOCC('two circle',[200,200]);
    elseif 6 == idx
        A = DataArtificialGenForOCC('multi density',[100,100]);
    elseif 7 == idx  % 四个Gauss分布，用于A03论文
        A = DataArtificialGenForOCC('multi gauss for cluster stability analysis',[100,100]);
    elseif 8 == idx % 多密度分布，使用两个散布程度不一样的高斯分布说明情况
        A = DataArtificialGenForOCC('four bananas for multi density',[100,100]);
    elseif 9 == idx % 最简单的二分类，就是两个高斯
        A = DataArtificialGenForOCC('twin gauss',[100,100]);
    elseif 10 == idx % 二分类，有一边是多个高斯分布
        A = DataArtificialGenForOCC('multi-modality binary classification',[100,100]);
    elseif 11 == idx % OCC,四个gauss的多模态分布（四高斯数据集）
        A = DataArtificialGenForOCC('four gauss',[100,100]);
    elseif 12 == idx % OCC,三个不同密度gauss的多密度分布(葫芦数据集)
        A = DataArtificialGenForOCC('calabash',[100,100]);
    elseif 13 == idx % OCC,示意正类存在噪声的数据集（光环数据集）
        A = DataArtificialGenForOCC('halo',[100,100]);
    elseif 14 == idx % OCC,较为简单的两个聚类簇的香蕉型数据（烂香蕉数据集）
        A = DataArtificialGenForOCC('BrokenBanana',[100,100]);
    elseif 15 == idx % 非常基本的问题形态，正类是一个香蕉 分布，负类在空间内均匀分布
        A = DataArtificialGenForOCC('BasicBanana',[100,100]);
    elseif 16 == idx % 非常基本的问题形态，正类是一个高斯分布，负类在空间内均匀分布
        A = DataArtificialGenForOCC('BasicGauss',[100,100]);        
    end
end

% % 调用示例：
% LC_DataArtificialGenForOCC('rectangle',[100,100],[2 2 1 1],20);
% LC_DataArtificialGenForOCC('sine',[150,50],[1 10 2 1],25);
% LC_DataArtificialGenForOCC('spiral',[300,100],[],40);
% LC_DataArtificialGenForOCC('multi density',[100,100]);
% LC_DataArtificialGenForOCC('two circle',[100,100]);
% LC_DataArtificialGenForOCC('twin sine',[100,100]);
function A = DataArtificialGenForOCC(type, nbSamples, args, snr, isOCC)
switch type
    case 'banana'
        %% 香蕉型数据
        A = gendatb(nbSamples);
        A = oc_set(A,'1');
        A.name = 'banana';
    case 'two circle'
        %% 双圆环数据
        numPoints = nbSamples;
        if(nargin < 3)
            radius = [2, 3, 5, 6];
        else
            radius = args;
        end
        
        num1 = numPoints(1);
        num2 = numPoints(2);

        t1 = 2 * pi * rand(num1,1);
        r1 = radius(1) + (radius(2) - radius(1)).*rand(num1,1);
        x1 = r1.*cos(t1);
        y1 = r1.*sin(t1);

        t2 = 2 * pi * rand(num2,1);
        r2 = radius(3) + (radius(4) - radius(3)).*rand(num2,1);
        x2 = r2.*cos(t2);
        y2 = r2.*sin(t2);

        data = [x1 y1];
        data = [data ; x2 y2];
        label_1 = ones(num1, 1);
        label_2 = ones(num2, 1);
        label = [label_1 ; label_2.*2];

        A = prdataset(data,label);
        A.name = 'two circle';
    case 'rectangle' 
        %% 带噪声的矩形数据
        % args(1) args(2) 是矩阵的长和宽 (args(3), args(4))是矩阵左下角的坐标
        fprintf('Generating Artificial Data for OCC--Rectangle 2-D Data...');
        fprintf('  Sample Count--[%d,%d] Rectangle Shape--[%.2f,%.2f] Position--(%.2f,%.2f)\n',...
            nbSamples(1), nbSamples(2), args(1) ,args(2),args(3) ,args(4));
        
        dataTarget = zeros(nbSamples(1), 2);
        dataOutlier = zeros(nbSamples(2), 2);
        labelTarget = ones(nbSamples(1), 1);
        labelOutlier = ones(nbSamples(2), 1) * 2;
        
        % 按照矩形的 南、东、北、西顺序决定随机样本的位置参数，作为Target类
        samplePos = (2*args(1) + 2*args(2)) * rand(1, nbSamples(1));
        for i = 1 : 1 : nbSamples(1)
            if (samplePos(i) <= args(1))
                dataTarget(i, 1) = samplePos(i) + args(3);
                dataTarget(i, 2) = args(4);
            elseif (samplePos(i) <= args(1) + args(2))
                dataTarget(i, 1) = args(1) + args(3);
                dataTarget(i, 2) = samplePos(i) - args(1) + args(4);                
            elseif (samplePos(i) <= 2*args(1) + args(2))
                dataTarget(i, 1) = args(3) + args(1) - (samplePos(i) - args(1)- args(2));
                dataTarget(i, 2) = args(2) + args(4);                 
            elseif (samplePos(i) <= 2*args(1) + 2*args(2))
                dataTarget(i, 1) = args(3);
                dataTarget(i, 2) = args(4) + (samplePos(i) - 2*args(1) - args(2));                 
            else
                fprintf('Fatal Error\n');
                return;                
            end
        end
        % 对Target类的坐标加扰动
        dataTarget = awgn(dataTarget, snr);
        
        % 随机生成Outlier类，范围是130%扩展的矩形
        outlierBoundryX = [args(3) - abs(args(3))*0.3 ; args(3) + args(1) + abs(args(3))*0.3];
        outlierBoundryY = [args(4) - abs(args(4))*0.3 ; args(4) + args(2) + abs(args(4))*0.3];
        dataOutlier(:, 1) = outlierBoundryX(1) + (outlierBoundryX(2)-outlierBoundryX(1)).*rand(nbSamples(2),1);
        dataOutlier(:, 2) = outlierBoundryY(1) + (outlierBoundryY(2)-outlierBoundryY(1)).*rand(nbSamples(2),1);
        
        % 生成数据集
        A = prdataset([dataTarget;dataOutlier],[labelTarget;labelOutlier]);
        A = oc_set(A,1);
        % END 生成矩形分布
    case 'sine'
        %% 带噪声的正弦形数据
        % args(1) args(2) 是 X轴方向的跨度，args(3)是Y轴的位置，args(4)是正弦的振幅
        fprintf('Generating Artificial Data for OCC--Sine 2-D Data...');
        fprintf('  Sample Count--[%d,%d] Sine X range--[%.2f,%.2f] Base Y--[%.2f] Amplitude--[%.2f]\n',...
            nbSamples(1), nbSamples(2), args(1) ,args(2),args(3) ,args(4));
        
        dataTarget = zeros(nbSamples(1), 2);
        dataOutlier = zeros(nbSamples(2), 2);
        labelTarget = ones(nbSamples(1), 1);
        labelOutlier = ones(nbSamples(2), 1) * 2;
        
        % 按照X轴的区间取随机值
        dataTarget(:,1) = args(1) + (args(2)-args(1)).*rand(nbSamples(1),1);
        dataTarget(:,2) = cos(dataTarget(:,1))*args(4) + args(3);
         % 对Target类的坐标加扰动
        dataTarget = awgn(dataTarget, snr);
        
        % 随机生成Outlier类，范围是130%扩展的矩形
        outlierBoundryX = [args(1) - abs(args(1))*0.3 ; args(2) + abs(args(2))*0.3];
        outlierBoundryY = [(args(3) -1 - abs(args(3))*0.3) ; (args(3) +1+ abs(args(3))*0.3)];
        dataOutlier(:, 1) = outlierBoundryX(1) + (outlierBoundryX(2)-outlierBoundryX(1)).*rand(nbSamples(2),1);
        dataOutlier(:, 2) = outlierBoundryY(1) + (outlierBoundryY(2)-outlierBoundryY(1)).*rand(nbSamples(2),1);
        
        % 生成数据集
        A = prdataset([dataTarget;dataOutlier],[labelTarget;labelOutlier]);
        A = oc_set(A,1);
        % END 生成正弦分布
	case 'spiral'
        %% 带噪声的双螺旋形数据
        % args(1) args(2) 是
        fprintf('Generating Artificial Data for OCC--Spiral 2-D Data...');
        fprintf('  Sample Count--[%d,%d] \n',...
            nbSamples(1), nbSamples(2));
        
        dataTarget = zeros(nbSamples(1), 2);
        dataOutlier = zeros(nbSamples(2), 2);
        labelTarget = ones(nbSamples(1), 1);
        labelOutlier = ones(nbSamples(2), 1) * 2;
        
        % 计算双螺旋线的基准位置，正负类各100个点
        i = (1:1:100)';
        alpha=pi*(i-1)/25;
        beta=0.4*((105-i)/104);
        targetBase_x=0.5+beta.*sin(alpha);
        targetBase_y=0.5+beta.*cos(alpha); % Target类基准点：共100个
        outlierBase_x=0.5-beta.*sin(alpha);
        outlierBase_y=0.5-beta.*cos(alpha); % Outlier类基准点：x1-y1 共100个
        
        % 按照所需的样本点数，随机定位到基准点，之后加入随机扰动得到实际样本点
        randTarget = round(1 + (100-1).*rand(nbSamples(1),1));
        dataTarget = [targetBase_x(randTarget) targetBase_y(randTarget)];
        dataTarget = awgn(dataTarget, snr);
        
        randOutlier = round(1 + (100-1).*rand(nbSamples(2),1));
        dataOutlier = [outlierBase_x(randOutlier) outlierBase_y(randOutlier)];   
        dataOutlier = awgn(dataOutlier, snr);

        % 生成数据集
        A = prdataset([dataTarget;dataOutlier],[labelTarget;labelOutlier]);
        A = oc_set(A,1);
        % END 生成双螺旋分布
	case 'four bananas for multi density'
        %% 生成四个高斯分布的banana分布target，密度不同
        N = [300 200 300 200];
        r = [10 45 10 45];s = [0.5 2 0.5 2];
        domain = 0.025*pi + rand(1,N(1))*1.25*pi; % 下方，内圈
        dataM_1   = [r(1)*sin(domain') r(1)*cos(domain')] + randn(N(1),2)*s(1) + ...
            ones(N(1),1)*[0.8*r(3)  -1*r(3)];
        domain = 0.3*pi + rand(1,N(2))*0.8*pi;     % 下方，外圈
        dataM_2   = [r(2)*sin(domain') r(2)*cos(domain')] + randn(N(2),2)*s(2);    
        domain = 0.2*pi - rand(1,N(3))*1.1*pi;   % 上方，内圈
        dataM_3   = [r(3)*sin(domain') r(3)*cos(domain')] + randn(N(3),2)*s(3) + ...
            ones(N(3),1)*[-2.2*r(3)  -0.5*r(3)];
        domain = 0.1*pi - rand(1,N(4))*0.9*pi;   % 上方，外圈
        dataM_4   = [r(4)*sin(domain') r(4)*cos(domain')] + randn(N(4),2)*s(4) + ...
            ones(N(4),1)*[-0.35*r(4) -0.35*r(4)];
        dataM_outlier = unifrnd(-65,45,fix(sum(N)/3),2);
          
        A = gendatoc([dataM_1 ; dataM_2; dataM_3; dataM_4], dataM_outlier);
        %A = OCLT_DataCombineDatasets(A, part3);
        % END 生成多个高斯分布
    case 'multi density'
        %% 生成多个不同密度分布的Target
        part1 = DataArtificialGenForOCC('sine',[200,200],[-6 2 6 2],20);
        part2 = oc_set(gendatb([120,120]),'2');
        %part2 = oc_set(gauss([150 30],[6 7; 5 5]),'1');
        A = OCLT_DataCombineDatasets(part1, part2);
        % END 生成多个不同密度分布的Target
    case 'multi gauss for cluster stability analysis'
        %% 生成多个高斯分布的Target，用于聚类稳定性分析
        part1 = oc_set(gauss([100 30],[0 0; 0 0]),'1');
        part2 = oc_set(gauss([100 30],[5 5; 5 5]),'1');
        part3 = oc_set(gauss([100 30],[0 5; 0 5]),'1');
        part4 = oc_set(gauss([100 30],[5 0; 5 0]),'1');
        A = OCLT_DataCombineDatasets(part1, part2);
        A = OCLT_DataCombineDatasets(A, part3);
        A = gendatoc(A);
        A = gendatoc(A, part4);       
        % END 生成多个高斯分布，用于聚类稳定性分析
    case 'twin sine'
        %% 生成两个相邻的正弦分布
        part1 = LC_DataArtificialGenForOCC('sine',[150,50],[1 10 2 1],25);
        part2 = LC_DataArtificialGenForOCC('sine',[150,50],[1 10 3 1],25);
        [part1_target, part1_outlier] = target_class(part1);
        [part2_target, part2_outlier] = target_class(part2);
        A_target = LC_DataCombineDatasets(part1_target, part2_target, 0);
        A_outlier = LC_DataCombineDatasets(part1_outlier, part2_outlier, 0);
        A = gendatoc(A_target, A_outlier);
    case 'twin gauss'
        %% 生成2个高斯分布的Target
        part1 = oc_set(gauss([150 0],[-1 -1; 0.5 -1]),'1');
        part2 = oc_set(gauss([150 0],[2 2; 0.5 -1]),'1');
        A = gendatoc(part1, part2);
        %A = LC_CombineDatasets(part1, part2, 1);
    case 'multi-modality binary classification'
        part1_1 = oc_set(gauss([100 0],[-3.5 -3.5; 0.5 -1]),'1');
        part1_2 = oc_set(gauss([100 0],[-3.5 3.5; 0.5 -1]),'1');
        part1_3 = oc_set(gauss([100 0],[3.5 -3.5; 0.5 -1]),'1');
        tempA =  OCLT_DataCombineDatasets(part1_1, part1_2);
        tempA =  OCLT_DataCombineDatasets(tempA, part1_3);
        part2 = oc_set(gauss([100 1],[2 2; 1.2 2.3]),'1');
        A = gendatoc(tempA, part2);
    case 'four gauss'
        part1_1 = oc_set(gauss([100 0],[-4 -4; 0.5 -1]),'1');
        part1_2 = oc_set(gauss([100 0],[-4 4; 0.5 -1]),'1');
        part1_3 = oc_set(gauss([100 0],[4 -4; 0.5 -1]),'1');   
        part1_4 = oc_set(gauss([100 0],[4 4; 0.5 -1]),'1');   
        tempA =  OCLT_DataCombineDatasets(part1_1, part1_2);
        tempA =  OCLT_DataCombineDatasets(tempA, part1_3);
        tempA =  OCLT_DataCombineDatasets(tempA, part1_4); 
        part2 = unifrnd(-6,6,200,2);
        A = gendatoc(tempA, part2);
	case 'calabash'
        part1_1 = oc_set(gauss([200 0],[-4 -4; 0.5 -1],cat(3,[6 0; 0 6],eye(2))),'1');
        part1_2 = oc_set(gauss([200 0],[1 1; 0.5 -1]),'1');   
        part1_3 = oc_set(gauss([200 0],[3 3; 0.5 -1],cat(3,[0.1 0;0 0.1],eye(2))),'1');   
        tempA =  OCLT_DataCombineDatasets(part1_1, part1_2);
        tempA =  OCLT_DataCombineDatasets(tempA, part1_3);
        part2 = unifrnd(-10,6,200,2);
        A = gendatoc(tempA, part2);
    case 'halo'
        part1 = oc_set(gauss([200 0],[0 0; 0.5 -1]),'1');   
        part2 = unifrnd(-6,6,100,2);
        A = gendatoc([+part1;5 0;0 5;-5 0;0 -5;3.5 3.5;-3.5 3.5;3.5 -3.5;-3.5 -3.5;...
            4.5 2;4.5 -2;-4.5 2;-4.5 -2;2 4.5;2 -4.5;-2 4.5;-2 -4.5], part2);
    case 'BrokenBanana'
        temp1 = gendatb([300 0]);
        temp1 = +temp1;
        delete_idx = [];
        for i = 1 : 1 : size(temp1,1)
            if temp1(i,2) < 1 && temp1(i,2) > -2
                delete_idx = [delete_idx i];
            end
        end
        temp1(delete_idx,:) = [];
        temp2 = unifrnd(-8,8,100,2);
        A = gendatoc(temp1, temp2);
    case 'BasicBanana'
        %part1 = oc_set(gauss([2000 0],[0 0; 0.5 -1],[2 1; 1 4]),'1');   
        part1 = oc_set(gendatb([800 0]),'1');   
        part2 = unifrnd(-6,6,50,2);
        A = gendatoc(part1, part2);
    case 'BasicGauss'
        part1 = oc_set(gauss(1000, [0 0], 0.05 * eye(2)),'1') ;
%         part1 = oc_set(gendatb([800 0]),'1');   
        part2 = unifrnd(-1,1,50,2);
        A = gendatoc(part1, part2);
end

end