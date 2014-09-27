% Set pathes (Temporary)addpath('.\Criteria');addpath('.\Algorithms');%addpath('.\Plots');clear resultclear all%clear classes% Run conf.m to get the configurations% 各类设置在conf脚本中conf% Initialization (partial from conf.m)if 1 == test_type    dataset_list = dataset_list(3:length(dataset_list));    [~,dataset_size] = size(dataset_list);elseif 2 == test_type    dataset_size = length(dataset_list);    num_cv = 1;  num_repeat = 1; end[~,algo_size] = size(algo_list);[~, num_crit] = size(crit_list);%result = cell{dataset_size, 1}{repeat_time,num_cv}{algo_size,num_crit}% Main Loopfor i=1:dataset_size    if 1 == test_type        fprintf('[debug] Dataset: %s\n', dataset_list{1,i});        orig_dataset{1,i} = prload([dataset_path, dataset_list{1,i}]);        DataInfo(orig_dataset{1,i}.x);    elseif 2 == test_type        orig_dataset{1,i} = MLAT_GenAritificialData(dataset_list(i));        DataInfo(orig_dataset{1,i});    end        for j = 1:num_repeat         [trainingA{i,j},testingA{i,j}] = MLAT_SplitData(orig_dataset{1,i}, num_cv);            for q = 1: 1: num_cv               n = 1;                while n <= algo_size                    trained_w{q,n} = MLAT_RunAlgo(trainingA{i,j}{1,q},algo_list{1,n});                    fprintf('On dataset %d/%d (with Repeat %d/%d and CV %d/%d), eval algo %d/%d ,  [%.1f%%]\n',...                            i, dataset_size, j ,num_repeat, q, num_cv, n, algo_size, ...                           100*((i-1)*(1.0/dataset_size) + (j-1)*(1.0/dataset_size/num_repeat) + ...                          (q-1)*(1.0/dataset_size/num_repeat/num_cv)+...                           (n-1)*(1.0/dataset_size/num_repeat/num_cv/algo_size)));                    m = 1;                       while m <= num_crit                        test_result{n,m} = MLAT_EvaluateAlgo(testingA{i,j}{1,q}, trained_w{q,n}, crit_list{1,m});                        m = m+1;                    end                                         n = n+1;                end            temp_result{j,q} = test_result;            test_result = [];            end    result_w{i,j} = trained_w;    end        result{1,i} = temp_result;    temp_result{j,q} = [];endsave('..\results\result.mat','MLAT_Conf','result','orig_dataset','AlgoList','CritList','algo_list','crit_list','trainingA','testingA')%save('result.mat')fprintf('All Tests done. [100.0%%]\n')