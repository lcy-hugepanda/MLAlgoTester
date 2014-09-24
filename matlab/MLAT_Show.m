% ����������Խ�������ַ�ʽ��ͼ����

gridsize(150)

%% ����ѡ����ȡ�Ѿ�������ϵĽ��
is_need_load = 0;
if is_need_load
    clear classes
    [filename, pathname] = uigetfile('*.mat', 'Pick an Mat-file of result','./results/');
    if ~isequal(filename,0)
       disp(['Result opened: ', fullfile(pathname, filename)])
    end
    
    load(fullfile(pathname, filename))
end


%% ���һЩ׼������
num_dataset = size(result,2);% ���ݼ�����
[num_repeat num_cv] = size(result{1}); % �ظ�����CV��
[~, num_crit] = size(crit_list); % ����ָ�����
[~,num_algo] = size(algo_list); % �㷨����

%% ����������ѡ��������֣��Ա���F5����
show_type = 201;
% show_type˵���Լ����Ե��趨
% ��ͼ��
%---------------------------------------------------------------------------
if 101 == show_type
% 101 : �������Ի�ͼ���̶�ĳһ�����ݼ�����ͼ˵�����㷨�����ܲ�������������á�
dataset_idx = 1; % �����������ݼ���ǩ
%---------------------------------------------------------------------------
elseif 102 == show_type
% 102 : �����㷨����ͼ���̶�ĳһ�����ݼ�����ͼ˵���������㷨�ĵ������ܲ������
dataset_idx = 2;
iteration_time = 50;  % ע��Ҫ������ʾ�����ĵ�������
%---------------------------------------------------------------------------
% 103 : �����㷨����ͼ���̶�ĳһ���㷨����ͼ˵�������ݼ��ϵĵ������ܲ������
elseif 103 == show_type
algo_idx = 1;
iteration_time = 50;% ע��Ҫ������ʾ�����ĵ�������
%---------------------------------------------------------------------------
% 104 : ���ݼ�/�㷨��������ͼ���̶�һ���㷨����ͼ˵�������ݼ��ϲ�������������á�
elseif 104 == show_type
algo_idx = 2;
%---------------------------------------------------------------------------
% 105 : �㷨1vs1ɢ��Ա�ͼ���Ա������㷨�ڶ�����ݼ��ϵ�Ч������ͼ˵��������ָ������
elseif 105 == show_type
algo_a_idx = 4;
algo_b_idx = 5;
% 106 : ���㷨�ڸ����ݼ��ϵ�ranking��ͼ������ȫ��Աȸ����㷨��ĳһ��ָ���ϵ�Ч��
elseif 106 == show_type
crit_idx = 1;
%
%===========================================================================
% �����
% 201:��һָ��Աȱ�񣬹̶�ĳһ������ָ�꣬���������ݼ��ϵĶԱȱ�
elseif 201 == show_type
crit_idx = 1;

%
%===========================================================================
% ��ά���ݿ��ӻ���
% 301:�̶�һ���㷨���������ڸ��˹����ݼ��ϵľ�����
elseif 301 == show_type
    algo_idx = 2;
% 302:�̶�һ�����ݼ������Ƹ����㷨�����ϵľ�����
elseif 302  == show_type
    dataset_idx = 1;
% 303:�̶����ݼ�����ʾ�����˹��������ɷ�������ע�⣬����Թ����޹أ�
elseif 303  == show_type
    dataset_idx = 3;
% 304:����ĳһ���㷨��ĳһ�����ݼ��ϵı��֣���ʾ���ڵ��������еĲ������ݼ�/�㷨���߽߱�仯���
elseif 304 == show_type
    algo_idx = 1;
    dataset_idx = 1;
    iterationShow = 1 : 1 : 12;
else
    return;
end

%==========================����ʵ��==============================================
if 101 == show_type
% �Ծ����ĳһ�����ݼ�Ϊ���ģ�ÿһ����ͼ��ʾһ���㷨�����ܲ���
for p = 1 : 1 : num_algo
    subplot(2,3,p)
    MLAT_Plot_Result( result, 1, dataset_idx, p )
    title(strrep(algo_list{p}(1:find(algo_list{p}=='(')-1),'_','\_'))
end
end

if 102 == show_type
    [subp_m, subp_n, subp_pos] = MLAT_PlanSubplot(num_algo);
    result_iteration = cell(iteration_time, 1);
% �Ծ����ĳһ�����ݼ�Ϊ���ģ�ÿһ����ͼ��ʾÿһ�ּ����㷨�ĵ�������
    % ������Ҫ���������е��������ݣ��������������Ҫ���½���
    % �õ��ĵ�������ֵ����һ�������У������ǵ��������������Ǹ�����ָ��
for p = 1 : 1 : num_algo
    subplot(subp_m, subp_n,p,'position',subp_pos(p,:))
    for i = 1 : 1 : iteration_time
        this_result = cell(1, num_crit); % ���ĳһ���㷨��ĳһ�ε��������¶��ڸ����ظ���CVȡƽ��
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
% �Ծ����ĳһ�������㷨Ϊ���ģ�ÿһ����ͼ��ʾһ�����ݼ��ϵĵ�������
    % ������Ҫ���������е��������ݣ��������������Ҫ���½���
    % �õ��ĵ�������ֵ����һ�������У������ǵ��������������Ǹ�����ָ��
result_iteration = cell(iteration_time, 1);
for d = 1 : 1 : num_dataset
    subplot(subp_m, subp_n,d,'position',subp_pos(d,:))
    for i = 1 : 1 : iteration_time
        this_result = cell(1, num_crit); % ���ĳһ���㷨��ĳһ�ε��������¶��ڸ����ظ���CVȡƽ��
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
% �Ծ����ĳһ���㷨Ϊ���ģ�ÿһ����ͼ��ʾÿһ�����ݼ�������
% ��Ҫ�����ж�ĳһ���㷨����ĳһ�����ݼ��������Ƿ�����
for d = 1 : 1 : num_dataset
	subplot(2,3,d)
    MLAT_Plot_Result( result, 1, d, algo_idx )
    title(strrep(dataset_list{d},'_','\_'))
end
end

if 105 == show_type
    [subp_m, subp_n, subp_pos] = MLAT_PlanSubplot(num_crit);
% �������㷨Ϊ�Ա��飬ÿһ����ͼ��Ӧһ������ָ�꣬��ͼ�жԱ������ڸ����ݼ��ϵ�����
% ��Ҫ���ڶԱ������㷨�����ܣ��ڶ�άͼ�ϱ�����ܲ��Ƚ϶Խ��������ĸ���
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
% ����ͼ������ÿһ���㷨�ڸ������ݼ��ϵ�����״����ͳ�ƣ����ƺ�ͼ
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

% �������ƽ��ֵ�ֲ�
for a = 1 : 1 : num_algo
	m = mean(rank_matrix(:,a));
    v = var(rank_matrix(:,a));
    line([a+0.3 a+0.3],[m-0.5*v m+0.5*v]);
    line([a+0.25 a+0.35],[m+0.5*v m+0.5*v]);
    line([a+0.25 a+0.35],[m m]);
    line([a+0.25 a+0.35],[m-0.5*v m-0.5*v]);
end
end

%------�����-----------------------------------------------------------
if 201 == show_type
% ѡ��һ������ָ�꣬�Ա������㷨�ڸ�ָ���µ�ָ��
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
% �̶�һ���㷨���������ڸ����˹����ݼ��ϵľ�����
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
% �̶�һ�����ݼ������Ƹ����㷨�����ϵľ�����
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
% �̶�һ�����ݼ������Ƹ������������㷨���ɵ��˹�����
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
% �̶�һ�����ݼ������Ƹ����㷨�����ϵľ�����
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
