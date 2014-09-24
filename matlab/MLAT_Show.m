% 用于整理测试结果，表现方式是图或表格

gridsize(150)

%% 【可选】读取已经测试完毕的结果
is_need_load = 0;
if is_need_load
    clear classes
    [filename, pathname] = uigetfile('*.mat', 'Pick an Mat-file of result','./results/');
    if ~isequal(filename,0)
       disp(['Result opened: ', fullfile(pathname, filename)])
    end
    
    load(fullfile(pathname, filename))
end


%% 完成一些准备工作
num_dataset = size(result,2);% 数据集个数
[num_repeat num_cv] = size(result{1}); % 重复数和CV数
[~, num_crit] = size(crit_list); % 评价指标个数
[~,num_algo] = size(algo_list); % 算法个数

%% 这里用数字选择采用哪种，以便于F5调试
show_type = 201;
% show_type说明以及各自的设定
% 绘图类
%---------------------------------------------------------------------------
if 101 == show_type
% 101 : 基本调试绘图，固定某一个数据集，子图说明各算法的性能波动情况【调试用】
dataset_idx = 1; % 这里设置数据集标签
%---------------------------------------------------------------------------
elseif 102 == show_type
% 102 : 集成算法迭代图，固定某一个数据集，子图说明各集成算法的迭代性能波动情况
dataset_idx = 2;
iteration_time = 50;  % 注意要给定显示出来的迭代次数
%---------------------------------------------------------------------------
% 103 : 集成算法迭代图，固定某一个算法，子图说明各数据集上的迭代性能波动情况
elseif 103 == show_type
algo_idx = 1;
iteration_time = 50;% 注意要给定显示出来的迭代次数
%---------------------------------------------------------------------------
% 104 : 数据集/算法初步测试图，固定一个算法，子图说明各数据集上测试情况【调试用】
elseif 104 == show_type
algo_idx = 2;
%---------------------------------------------------------------------------
% 105 : 算法1vs1散点对比图，对比两个算法在多个数据集上的效果，子图说明各评价指标的情况
elseif 105 == show_type
algo_a_idx = 4;
algo_b_idx = 5;
% 106 : 各算法在各数据集上的ranking盒图，用于全面对比各个算法在某一个指标上的效果
elseif 106 == show_type
crit_idx = 1;
%
%===========================================================================
% 表格类
% 201:单一指标对比表格，固定某一个评价指标，给出各数据集上的对比表
elseif 201 == show_type
crit_idx = 1;

%
%===========================================================================
% 二维数据可视化类
% 301:固定一个算法，绘制其在各人工数据集上的决策面
elseif 301 == show_type
    algo_idx = 2;
% 302:固定一个数据集，绘制各个算法在其上的决策面
elseif 302  == show_type
    dataset_idx = 1;
% 303:固定数据集，显示各种人工负类生成方法（请注意，与测试过程无关）
elseif 303  == show_type
    dataset_idx = 3;
% 304:对于某一个算法在某一个数据集上的表现，显示其在迭代过程中的采样数据集/算法决策边界变化情况
elseif 304 == show_type
    algo_idx = 1;
    dataset_idx = 1;
    iterationShow = 1 : 1 : 12;
else
    return;
end

%==========================具体实现==============================================
if 101 == show_type
% 以具体的某一个数据集为核心，每一个子图显示一种算法的性能波动
for p = 1 : 1 : num_algo
    subplot(2,3,p)
    MLAT_Plot_Result( result, 1, dataset_idx, p )
    title(strrep(algo_list{p}(1:find(algo_list{p}=='(')-1),'_','\_'))
end
end

if 102 == show_type
    [subp_m, subp_n, subp_pos] = MLAT_PlanSubplot(num_algo);
    result_iteration = cell(iteration_time, 1);
% 以具体的某一个数据集为核心，每一个子图显示每一种集成算法的迭代性能
    % 由于需要迭代过程中的评估数据，因此评估本身需要重新进行
    % 得到的迭代性能值放在一个矩阵中，横向是迭代次数，纵向是各评价指标
for p = 1 : 1 : num_algo
    subplot(subp_m, subp_n,p,'position',subp_pos(p,:))
    for i = 1 : 1 : iteration_time
        this_result = cell(1, num_crit); % 针对某一个算法的某一次迭代，以下对于各次重复和CV取平均
        for this_crit = 1 : 1 : num_crit
            this_result{this_crit} = zeros(num_repeat, num_cv);
        end
        for r = 1 : 1 : num_repeat
            for c = 1 : 1 : num_cv
                this_w = result_w{dataset_idx,r}{c,p}.data.subIterationW{i};
                this_a = testingA{dataset_idx,r}{c};
                for this_crit = 1 : 1 : num_crit
                    this_result{this_crit}(r,c) = MLAT_EvaluateAlgo(this_a, this_w, crit_list{1,this_crit});
                end
            end
        end
        result_iteration{i} = this_result;       
    end
    MLAT_Plot_Result( result_iteration, 2, [], [], crit_list );
    title(strrep(algo_list{p},'_','\_'))
end 
end

if 103 == show_type
    [subp_m, subp_n, subp_pos] = MLAT_PlanSubplot(num_dataset);
% 以具体的某一个集成算法为核心，每一个子图显示一个数据集上的迭代性能
    % 由于需要迭代过程中的评估数据，因此评估本身需要重新进行
    % 得到的迭代性能值放在一个矩阵中，横向是迭代次数，纵向是各评价指标
result_iteration = cell(iteration_time, 1);
for d = 1 : 1 : num_dataset
    subplot(subp_m, subp_n,d,'position',subp_pos(d,:))
    for i = 1 : 1 : iteration_time
        this_result = cell(1, num_crit); % 针对某一个算法的某一次迭代，以下对于各次重复和CV取平均
        for this_crit = 1 : 1 : num_crit
            this_result{this_crit} = zeros(num_repeat, num_cv);
        end
        for r = 1 : 1 : num_repeat
            for c = 1 : 1 : num_cv
                this_w = result_w{d,r}{c,algo_idx}.data.subIterationW{i};
                this_a = testingA{d,r}{c};
                for this_crit = 1 : 1 : num_crit
                    this_result{this_crit}(r,c) = MLAT_EvaluateAlgo(this_a, this_w, crit_list{1,this_crit});
                end
            end
        end
        result_iteration{i} = this_result;       
    end
    MLAT_Plot_Result( result_iteration, 2, [], [], crit_list );
    title(strrep(dataset_list{d},'_','\_'))
end 
end     

if 104 == show_type
% 以具体的某一个算法为核心，每一个子图显示每一个数据集的性能
% 主要用于判断某一个算法或者某一个数据集的运作是否正常
for d = 1 : 1 : num_dataset
	subplot(2,3,d)
    MLAT_Plot_Result( result, 1, d, algo_idx )
    title(strrep(dataset_list{d},'_','\_'))
end
end

if 105 == show_type
    [subp_m, subp_n, subp_pos] = MLAT_PlanSubplot(num_crit);
% 以两个算法为对比组，每一个子图对应一个评价指标，子图中对比它们在各数据集上的性能
% 主要用于对比两个算法的性能，在二维图上标记性能并比较对角线两侧点的个数
for  c = 1 : 1 : num_crit
	subplot(subp_m, subp_n,c,'position',subp_pos(c,:))
    axis([0 1 0 1])
    
    plot_points = zeros(num_dataset, 2);
    for d = 1 : 1 : num_dataset
        plot_points(d, 1) = MLAT_GetOneResult(result, d, algo_a_idx, c );
        plot_points(d, 2) = MLAT_GetOneResult(result, d, algo_b_idx, c );
    end
    
    scatter(plot_points(:,1), plot_points(:,2),'k+'); 
    
    box on
    grid on
	hold on
    line([0 1],[0 1],'color','k');
    xlabel(strrep(algo_list{algo_a_idx},'_','\_'))
    ylabel(strrep(algo_list{algo_b_idx},'_','\_'))
    title(strrep(crit_list{c},'_','\_'))
end
end

if 106 == show_type
% 单幅图，对于每一个算法在各个数据集上的排名状况作统计，绘制盒图
rank_matrix = zeros(num_dataset, num_algo);
for d = 1 : 1 : num_dataset
    this_crit = zeros(1,num_algo);
	for a = 1 : 1 : num_algo
        [m, v] = MLAT_GetOneResult(result, d, a, crit_idx);
        if isnan(m)
            m = 0;
        end
        this_crit(a) = m;
    end
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
set(gca,'XTicklabel',algo_list_display);

% 补充绘制平均值分布
for a = 1 : 1 : num_algo
	m = mean(rank_matrix(:,a));
    v = var(rank_matrix(:,a));
    line([a+0.3 a+0.3],[m-0.5*v m+0.5*v]);
    line([a+0.25 a+0.35],[m+0.5*v m+0.5*v]);
    line([a+0.25 a+0.35],[m m]);
    line([a+0.25 a+0.35],[m-0.5*v m-0.5*v]);
end
end

%------表格类-----------------------------------------------------------
if 201 == show_type
% 选定一个评价指标，对比所有算法在该指标下的指标
data_show = cell(num_dataset, num_algo);
for d = 1 : 1 : num_dataset
	for a = 1 : 1 : num_algo
        [m, v] = MLAT_GetOneResult(result, d, a, crit_idx);
        data_show{d,a} = [m v];
    end
end
str_data = cell(num_dataset, 2*num_algo);

for d = 1 : 1 : num_dataset
	for a = 1 : 1 : num_algo
        str_data{d, 2*a-1} = sprintf('%.3f',data_show{d,a}(1));
        str_data{d, 2*a} = sprintf('%.3f',data_show{d,a}(2));
    end
end

str_algo = cell(1, 2 * num_algo);
for a = 1 : 1 : num_algo
    str_algo{1, 2*a-1} = algo_list{a};
    str_algo{1, 2*a} = 'var';
end

str_addition = cell(1, 1 + 2*num_algo);
str_addition{1,1} = '=B2=MAX($B2:$I2)';

str_show = [cell(1,1) str_algo; dataset_list' str_data; str_addition];
xlswrite('..\results\result.xls',str_show);
winopen('..\results\result.xls')

end


if 301 == show_type
    [subp_m, subp_n, subp_pos] = MLAT_PlanSubplot(num_dataset);
% 固定一个算法，绘制其在各个人工数据集上的决策面
for d = 1 : 1 : num_dataset
    subplot(subp_m, subp_n,d,'position',subp_pos(d,:));
    scatterd(trainingA{d,1}{1});
    plotc(result_w{d,1}{1,algo_idx});
	xlabel('')
    ylabel('')
    set(gca,'XTick',[]);
    set(gca,'YTick',[]);
end
end

if 302 == show_type
    [subp_m, subp_n, subp_pos] = MLAT_PlanSubplot(num_algo);
% 固定一个数据集，绘制各个算法在其上的决策面
for a = 1 : 1 : num_algo
    subplot(subp_m, subp_n,a,'position',subp_pos(a,:));
    scatterd(trainingA{dataset_idx,1}{1});
    plot_w = result_w{dataset_idx,1}{1,a};
    %plotc(plot_w.data.subW{9});
    plotc(plot_w);
	xlabel('')
    ylabel('')
    set(gca,'XTick',[]);
    set(gca,'YTick',[]);
    title(algo_list_display{a});
end
end

if 303 == show_type
algo_outlier = {
    'gendatout(A_orig, length(getnlab(A_orig)))',...
    'gendatoutg(A_orig, length(getnlab(A_orig)))',...
    'gendatblockout(A_orig, length(getnlab(A_orig)))'
%    'gendatouts(A_orig, length(getnlab(A_orig)))',...
};
[subp_m, subp_n, subp_pos] = MLAT_PlanSubplot(length(algo_outlier));
% 固定一个数据集，绘制各个负类生成算法生成的人工负类
for a = 1 : 1 : length(algo_outlier)
    subplot(subp_m, subp_n,a,'position',subp_pos(a,:));
    A_orig = trainingA{dataset_idx,1}{1};
    scatterd(A_orig);hold on
    A_outlier = eval(algo_outlier{a});
    [It,Io] = find_target(A_outlier);
    A_outlier = seldat(A_outlier,'outlier');
    scatterd(A_outlier, 'kx');
   
	xlabel('')
    ylabel('')
    set(gca,'XTick',[]);
    set(gca,'YTick',[]);
end
end

if 304 == show_type
    target_w = result_w{dataset_idx,1}{1,algo_idx};
    subA = target_w.data.subA;
    [subp_m, subp_n, subp_pos] = MLAT_PlanSubplot(length(iterationShow));
% 固定一个数据集，绘制各个算法在其上的决策面
    subW = target_w.data.subW;
    subIterationW = target_w.data.subIterationW;
for i = 1 : 1 : length(iterationShow)
    subplot(subp_m, subp_n,i,'position',subp_pos(i,:));
    scatterd(subA{i});
    plotc(subW{i},'g');
    hold on 
    plotc(subIterationW{i});
	xlabel('')
    ylabel('')
    set(gca,'XTick',[]);
    set(gca,'YTick',[]);
    title(sprintf('Iteration %d',i));
end
end
