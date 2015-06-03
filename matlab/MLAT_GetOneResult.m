% 该函数用于获取结果中，某一个数据集下某一个算法在某一个参数中的表现
function [ret_mean, ret_var] = MLAT_GetOneResult(result, dataset_idx, algo_idx, crit_idx)
    result_get = [];
        
    data = result{dataset_idx};
    [num_repeat, num_cv] = size(data);
    
    num_repeat = 1;

    for r = 1 : 1 : num_repeat
        for c = 1 : 1 : num_cv
            result_get = [result_get data{r,c}{algo_idx, crit_idx}];
        end
    end
    
    % FIX:  这里去掉NaN以避免问题
    result_get(isnan(result_get))=[];
    ret_mean = mean(result_get);
    ret_var = var(result_get);
end