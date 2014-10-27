% 这部分列出的是一些独立的测试项目，也就是不方便直接使用MLAT_MAIN得到result的情况下的测试
% 主要是一些结果的展示和二次分析

clear all
close all
% 各个子内容之间互相独立，请使用cell导航
% 此外，为了方便调试，每一个cell在这里选择
func = 2;
% func 1 : 使用一个csv表格进行ranking盒图绘制
% func 2 : 使用多个csv表格可视化某一个参数对多个算法的影响

if 1 == func
%% 在已有结果上进行ranking盒图的可视化
% 源数据格式形如：
%  dataset, Algo1, Algo2
%  Data1, 0.9, 0.8
%  Data2, 0.8, 0.7
% 由于MATLAB的boxplot与PRTools冲突，请先clear classes
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
 % 获取xtick的值
xt=get(gca,'XTick'); 
% 获取xtick的值         
yt=get(gca,'YTick');   
% 设置text的x坐标位置们         
xtextp=xt;                   
 % 设置text的y坐标位置们      
ytextp=(yt(1)-0.2*(yt(2)-yt(1))-0.01)*ones(1,length(xt)); 
% rotation，正的旋转角度代表逆时针旋转，旋转轴可以由HorizontalAlignment属性来设定，
% 有3个属性值：left，right，center
text(xtextp,ytextp,xtl,'HorizontalAlignment','right','rotation',30,'fontname','TimesNewRoman','fontsize',12); 
% 取消原始ticklabel
set(gca,'xticklabel','');
ylabel('Ranks of algorithms','fontname','TimesNewRoman','fontsize',12);


elseif 2 == func
%% 使用多个csv表格（每一个算法对应一个）可视化表示某一个参数对算法性能的影响（每一个数据集一个子图）
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