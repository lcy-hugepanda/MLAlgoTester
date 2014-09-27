% ������ͼ����
% ���������
%   result -- MLAT_Main�����Ľ��
%   type -- ��ͼ����
%           1 -- ���ܲ������ߣ�����result��
%           2 -- ���ܱ仯���ߣ��������������������ÿһ����һ�ε����ĸ�������ָ�꣩
%   dataset -- ���ݼ����
%   algo -- �㷨���

function MLAT_Plot_Result( result, type, dataset, algo,crit_list )
%result = cell{dataset_size, 1}{repeat_time,num_cv}{algo_size,num_crit}

% ���ﶨ��ͼ�ߵ���ʽ
plot_style = {'-+b' '-*r' '-ok' '-xm'};
marker_size = [10 10 6 10];
line_width = 1.5;

if 1 == type  % ��ͼtype 1�����ܲ�������
    data = result{dataset};
    [m, n] = size(data);
    x = 1 : 1 : m*n;
    y = zeros(m*n, length(crit_list));
    for i = 1 : length(crit_list)
        for p = 1:m
            for q = 1:n
                y((p-1)*n + q, i) = data{p,q}{algo,i};
            end
        end
        set(0,'defaultfigurecolor','w');
        plot(x,y(:,i),plot_style{i});
    end
     
    legend(crit_list);
    grid on
end

if 2 == type  % ��ͼtype 2�����ɵ����������������
    iteration_time = size(result,1);
    num_crit = size(result{1},2);
    [num_repeat num_cv] = size(result{1}{1});
    x = 1 : 1 : iteration_time;
    set(0,'defaultfigurecolor','w');
     
    data = cell(1, num_crit);
    data_mean = cell(1, num_crit);
    for i = 1 : 1 : iteration_time
        for j = 1 : 1 : num_crit
            data{j} = [data{j} reshape(result{i}{j},num_repeat*num_cv,1)];
            data_mean{j} = [data_mean{j} mean(reshape(result{i}{j},num_repeat*num_cv,1))];
        end
    end
    
	for i = 1 : 1 : num_crit
        plot(x,data_mean{i},plot_style{i},'MarkerSize',marker_size(i),'LineWidth',line_width);
        hold on
    end
    legend_list = crit_list;
    for i = 1 : 1 : length(legend_list)
        legend_list{i} = strrep(legend_list{i},'_','\_');
    end
    legend(legend_list);
    
 	for i = 1 : 1 : num_crit
        for j = 1 : 1 : iteration_time
            line([j j], [max(data{i}(:,j)) min(data{i}(:,j))],'Color',plot_style{i}(3));
            line([j-0.1 j+0.1], [min(data{i}(:,j)) min(data{i}(:,j))],'Color',plot_style{i}(3));
            line([j-0.1 j+0.1], [max(data{i}(:,j)) max(data{i}(:,j))],'Color',plot_style{i}(3));
        end
    end
    
    grid on
end

end

