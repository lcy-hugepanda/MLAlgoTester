% �ⲿ���г�����һЩ�����Ĳ�����Ŀ��Ҳ���ǲ�����ֱ��ʹ��MLAT_MAIN�õ�result������µĲ���
% ��Ҫ��һЩ�����չʾ�Ͷ��η���

clear all
close all
% ����������֮�以���������ʹ��cell����
% ���⣬Ϊ�˷�����ԣ�ÿһ��cell������ѡ��
func = 2;
% func 1 : ʹ��һ��csv������ranking��ͼ����
% func 2 : ʹ�ö��csv�����ӻ�ĳһ�������Զ���㷨��Ӱ��

if 1 == func
%% �����н���Ͻ���ranking��ͼ�Ŀ��ӻ�
% Դ���ݸ�ʽ���磺
%  dataset, Algo1, Algo2
%  Data1, 0.9, 0.8
%  Data2, 0.8, 0.7
% ����MATLAB��boxplot��PRTools��ͻ������clear classes
src_path = '..\\results\\E09_AUC_compare.csv';
fin=fopen(src_path,'r');
algo_name = fgetl(fin);
fclose(fin);
algo_name = regexp(algo_name, ',', 'split');
algo_name = algo_name(1,2:length(algo_name));
data = csvread(src_path,1,1);
[num_dataset, num_algo] = size(data);
rank_matrix = zeros(num_dataset, num_algo);
for d = 1 : 1 : num_dataset
    this_crit = data(d,:);
    this_rank = ones(1, num_algo);
    temp = ones(1, num_algo);
    while(true)
        if sum(temp) == 0
            break;
        end
        [max_value,~] = max(this_crit);
        max_idx = find(this_crit == max_value);
        temp(max_idx) = 0;
        if (length(max_idx)>1)
            this_rank(max_idx) = (2*this_rank(max_idx(1))+length(max_idx)-1)/2;
        end
        this_rank(find(temp == 1)) = this_rank(find(temp == 1))+length(max_idx);
        this_crit(max_idx) = -1;
    end
    rank_matrix(d,:) = this_rank;
end
boxplot(rank_matrix,'notch','off');
set(gca,'XTick',1:1:num_algo);
set(gca,'XTicklabel',algo_name);
axis([0 num_algo+1 0 num_algo ])

xtl=get(gca,'XTickLabel'); 
 % ��ȡxtick��ֵ
xt=get(gca,'XTick'); 
% ��ȡxtick��ֵ         
yt=get(gca,'YTick');   
% ����text��x����λ����         
xtextp=xt;                   
 % ����text��y����λ����      
ytextp=(yt(1)-0.2*(yt(2)-yt(1))-0.01)*ones(1,length(xt)); 
% rotation��������ת�Ƕȴ�����ʱ����ת����ת�������HorizontalAlignment�������趨��
% ��3������ֵ��left��right��center
text(xtextp,ytextp,xtl,'HorizontalAlignment','right','rotation',30,'fontname','TimesNewRoman','fontsize',12); 
% ȡ��ԭʼticklabel
set(gca,'xticklabel','');
ylabel('Ranks of algorithms','fontname','TimesNewRoman','fontsize',12);


elseif 2 == func
%% ʹ�ö��csv���ÿһ���㷨��Ӧһ�������ӻ���ʾĳһ���������㷨���ܵ�Ӱ�죨ÿһ�����ݼ�һ����ͼ��
src_path = {...
    '..\\results\\E09_Outlier_compare_OCCBoost1.csv',...
    '..\\results\\E09_Outlier_compare_OCCBoost2.csv',...
    '..\\results\\E09_Outlier_compare_Unif.csv',...
    '..\\results\\E09_Outlier_compare_Block.csv'
};
num_algo = length(src_path);
algo_name = {'OCCBoost1','OCCBoost2','Unif','Block'};
data_name = {...
    'Biomed (carrier)','Biomed (normal)','Breast (benign)','Breast (malignant)',...
    'Diabetes (absent)','Diabetes (present)','Glass (Float)','Glass (NonFloat)',...
    'Heart (absent)','Heart (present)','Liver (disorder)','Liver (healthy)',...
    'Wine (1)','Wine (2)','Wine (3)','Anneal (2)','Anneal (3)','Anneal (4)','Anneal (5)',...
    'Auto (above25)','Auto (below25)','Balance(B)','Balance(L)','Balance(R)'};
para_tick = {'0.01','0.02','0.03','0.04','0.05','0.06','0.07','0.08','0.09',...
    '0.1','0.2','0.3','0.4','0.5'};
data = cell(1, length(src_path));
for a = 1 : 1 : length(src_path)
    raw_data = csvread(src_path{a},1,1);
    data{a} = raw_data(:,1:2:end);
end
num_dataset = 24;
x = 1: 1 : length(para_tick);
style = {'rx-','m+-','b.-','ko-'};
h = cell(1,num_algo);
for d =1 : 1 : 24
%    [subp_m, subp_n, subp_pos] = MLAT_PlanSubplot(num_dataset);
%     subplot(subp_m, subp_n,d,'position',subp_pos(d,:))
    subplot(5,5,d)
    %grid on
    hold on
    box on
    for a = 1 : 1 :  num_algo
        h = plot(x, data{a}(d,:),style{a});
        set(gca,'fontname','TimesNewRoman','fontsize',12);
        axis tight
    end
    title(data_name{d},'fontname','TimesNewRoman','fontsize',12)
end
h_l = legend('OCCBoost1','OCCBoost2','Unif','Gauss',...
    'Location','EastOutside');
set(h_l,'fontname','TimesNewRoman','fontsize',12);

end