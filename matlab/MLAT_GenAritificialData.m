function A  = MLAT_GenAritificialData(idx)
    if 1 == idx
        A = DataArtificialGenForOCC('banana',[200,200]);
    elseif 2 == idx
        A = DataArtificialGenForOCC('rectangle',[200,200],[2 2 1 1],20);
    elseif 3 == idx
        A = DataArtificialGenForOCC('sine',[150,50],[1 10 2 1],25);
    elseif 4 == idx
        A = DataArtificialGenForOCC('spiral',[200,200],[],40);
    elseif 5 == idx
        A = DataArtificialGenForOCC('two circle',[200,200]);
    end
end

% % ����ʾ����
% LC_DataArtificialGenForOCC('rectangle',[100,100],[2 2 1 1],20);
% LC_DataArtificialGenForOCC('sine',[150,50],[1 10 2 1],25);
% LC_DataArtificialGenForOCC('spiral',[300,100],[],40);
% LC_DataArtificialGenForOCC('multi density',[100,100]);
% LC_DataArtificialGenForOCC('two circle',[100,100]);
% LC_DataArtificialGenForOCC('twin sine',[100,100]);
function A = DataArtificialGenForOCC(type, nbSamples, args, snr, isOCC)
switch type
    case 'banana'
        %% �㽶������
        A = gendatb(nbSamples);
        A = oc_set(A,'1');
        A.name = 'banana';
    case 'two circle'
        %% ˫Բ������
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
        %% �������ľ�������
        % args(1) args(2) �Ǿ���ĳ��Ϳ� (args(3), args(4))�Ǿ������½ǵ�����
        fprintf('Generating Artificial Data for OCC--Rectangle 2-D Data...');
        fprintf('  Sample Count--[%d,%d] Rectangle Shape--[%.2f,%.2f] Position--(%.2f,%.2f)\n',...
            nbSamples(1), nbSamples(2), args(1) ,args(2),args(3) ,args(4));
        
        dataTarget = zeros(nbSamples(1), 2);
        dataOutlier = zeros(nbSamples(2), 2);
        labelTarget = ones(nbSamples(1), 1);
        labelOutlier = ones(nbSamples(2), 1) * 2;
        
        % ���վ��ε� �ϡ�����������˳��������������λ�ò�������ΪTarget��
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
        % ��Target���������Ŷ�
        dataTarget = awgn(dataTarget, snr);
        
        % �������Outlier�࣬��Χ��130%��չ�ľ���
        outlierBoundryX = [args(3) - abs(args(3))*0.3 ; args(3) + args(1) + abs(args(3))*0.3];
        outlierBoundryY = [args(4) - abs(args(4))*0.3 ; args(4) + args(2) + abs(args(4))*0.3];
        dataOutlier(:, 1) = outlierBoundryX(1) + (outlierBoundryX(2)-outlierBoundryX(1)).*rand(nbSamples(2),1);
        dataOutlier(:, 2) = outlierBoundryY(1) + (outlierBoundryY(2)-outlierBoundryY(1)).*rand(nbSamples(2),1);
        
        % �������ݼ�
        A = prdataset([dataTarget;dataOutlier],[labelTarget;labelOutlier]);
        A = oc_set(A,1);
        % END ���ɾ��ηֲ�
    case 'sine'
        %% ������������������
        % args(1) args(2) �� X�᷽��Ŀ�ȣ�args(3)��Y���λ�ã�args(4)�����ҵ����
        fprintf('Generating Artificial Data for OCC--Sine 2-D Data...');
        fprintf('  Sample Count--[%d,%d] Sine X range--[%.2f,%.2f] Base Y--[%.2f] Amplitude--[%.2f]\n',...
            nbSamples(1), nbSamples(2), args(1) ,args(2),args(3) ,args(4));
        
        dataTarget = zeros(nbSamples(1), 2);
        dataOutlier = zeros(nbSamples(2), 2);
        labelTarget = ones(nbSamples(1), 1);
        labelOutlier = ones(nbSamples(2), 1) * 2;
        
        % ����X�������ȡ���ֵ
        dataTarget(:,1) = args(1) + (args(2)-args(1)).*rand(nbSamples(1),1);
        dataTarget(:,2) = cos(dataTarget(:,1))*args(4) + args(3);
         % ��Target���������Ŷ�
        dataTarget = awgn(dataTarget, snr);
        
        % �������Outlier�࣬��Χ��130%��չ�ľ���
        outlierBoundryX = [args(1) - abs(args(1))*0.3 ; args(2) + abs(args(2))*0.3];
        outlierBoundryY = [(args(3) -1 - abs(args(3))*0.3) ; (args(3) +1+ abs(args(3))*0.3)];
        dataOutlier(:, 1) = outlierBoundryX(1) + (outlierBoundryX(2)-outlierBoundryX(1)).*rand(nbSamples(2),1);
        dataOutlier(:, 2) = outlierBoundryY(1) + (outlierBoundryY(2)-outlierBoundryY(1)).*rand(nbSamples(2),1);
        
        % �������ݼ�
        A = prdataset([dataTarget;dataOutlier],[labelTarget;labelOutlier]);
        A = oc_set(A,1);
        % END �������ҷֲ�
	case 'spiral'
        %% ��������˫����������
        % args(1) args(2) ��
        fprintf('Generating Artificial Data for OCC--Spiral 2-D Data...');
        fprintf('  Sample Count--[%d,%d] \n',...
            nbSamples(1), nbSamples(2));
        
        dataTarget = zeros(nbSamples(1), 2);
        dataOutlier = zeros(nbSamples(2), 2);
        labelTarget = ones(nbSamples(1), 1);
        labelOutlier = ones(nbSamples(2), 1) * 2;
        
        % ����˫�����ߵĻ�׼λ�ã��������100����
        i = (1:1:100)';
        alpha=pi*(i-1)/25;
        beta=0.4*((105-i)/104);
        targetBase_x=0.5+beta.*sin(alpha);
        targetBase_y=0.5+beta.*cos(alpha); % Target���׼�㣺��100��
        outlierBase_x=0.5-beta.*sin(alpha);
        outlierBase_y=0.5-beta.*cos(alpha); % Outlier���׼�㣺x1-y1 ��100��
        
        % ������������������������λ����׼�㣬֮���������Ŷ��õ�ʵ��������
        randTarget = round(1 + (100-1).*rand(nbSamples(1),1));
        dataTarget = [targetBase_x(randTarget) targetBase_y(randTarget)];
        dataTarget = awgn(dataTarget, snr);
        
        randOutlier = round(1 + (100-1).*rand(nbSamples(2),1));
        dataOutlier = [outlierBase_x(randOutlier) outlierBase_y(randOutlier)];   
        dataOutlier = awgn(dataOutlier, snr);

        % �������ݼ�
        A = prdataset([dataTarget;dataOutlier],[labelTarget;labelOutlier]);
        A = oc_set(A,1);
        % END ����˫�����ֲ�
	case 'multi gauss'
        %% ���ɶ����˹�ֲ���Target
        part1 = oc_set(gauss([150 30],[-1 -1; 3 3]),'1');
        part2 = oc_set(gauss([150 30],[8 8; 5 5]),'1');
        part3 = oc_set(gauss([150 30],[-1 8; 4 4]),'1');
        A = LC_CombineDatasets(part1, part2, 1);
        A = LC_CombineDatasets(A, part3, 1);
        % END ���ɶ����˹�ֲ�
    case 'multi density'
        %% ���ɶ����ͬ�ܶȷֲ���Target
        part1 = LC_DataArtificialGenForOCC('sine',[200,200],[-6 2 6 2],20);
        part2 = oc_set(gendatb([120,120]),'2');
        %part2 = oc_set(gauss([150 30],[6 7; 5 5]),'1');
        A = LC_DataCombineDatasets(part1, part2, 1);
        % END ���ɶ����ͬ�ܶȷֲ���Target
    case 'multi gauss for cluster stability analysis'
        %% ���ɶ����˹�ֲ���Target�����ھ����ȶ��Է���
        part1 = oc_set(gauss([100 30],[0 0; 0 0]),'1');
        part2 = oc_set(gauss([100 30],[5 5; 5 5]),'1');
        part3 = oc_set(gauss([100 30],[0 5; 0 5]),'1');
        part4 = oc_set(gauss([100 30],[5 0; 5 0]),'1');
        A = LC_DataCombineDatasets(part1, part2, 1);
        A = LC_DataCombineDatasets(A, part3, 1);
        A = gendatoc(A);
        A = gendatoc(A, part4);       
        % END ���ɶ����˹�ֲ������ھ����ȶ��Է���
    case 'twin sine'
        %% �����������ڵ����ҷֲ�
        part1 = LC_DataArtificialGenForOCC('sine',[150,50],[1 10 2 1],25);
        part2 = LC_DataArtificialGenForOCC('sine',[150,50],[1 10 3 1],25);
        [part1_target, part1_outlier] = target_class(part1);
        [part2_target, part2_outlier] = target_class(part2);
        A_target = LC_DataCombineDatasets(part1_target, part2_target, 0);
        A_outlier = LC_DataCombineDatasets(part1_outlier, part2_outlier, 0);
        A = gendatoc(A_target, A_outlier);
    case 'twin gauss'
        %% ����2����˹�ֲ���Target
        part1 = oc_set(gauss([150 100],[-1 -1; 0.5 -1]),'1');
        part2 = oc_set(gauss([150 100],[2.5 3; 1.2 2.3]),'1');
        A = gendatoc(part1, part2);
        %A = LC_CombineDatasets(part1, part2, 1);
end

end