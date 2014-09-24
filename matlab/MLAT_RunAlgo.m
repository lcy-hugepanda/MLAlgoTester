% 算法的实际调用逻辑，关键在于使用传入参数替换算法调用中用到的参数

function W = MLAT_RunAlgo(A, func)
    global MLAT_Conf;
    [num_algo, ~] = size(MLAT_Conf.AlgoListAll);
    for i = 1 : 1 : num_algo;
        if (strcmp(func(1:find(func=='(')-1), MLAT_Conf.AlgoListAll{i,1}(1:find(MLAT_Conf.AlgoListAll{i,1}=='(')-1)))
            % 命中，这里开始替换参数
            % step 1：解析参数
            arg_in = func(find(func=='(')+1: length(func)-1);
            arg_idx = find(arg_in == '#');
            arg_in_list = cell(0);
            for j = 1 : 2 : length(arg_idx)
                arg_in_list = [arg_in_list;arg_in(arg_idx(j)+1:arg_idx(j+1)-1)];
            end
            % step 2: 解析参数名
            algo_in = MLAT_Conf.AlgoListAll{i,1};
            algo_arg_idx = find(algo_in == '%');
            arg_in_name_list = cell(0);
            for j = 1 : 2 : length(algo_arg_idx)
                arg_in_name_list = [arg_in_name_list;algo_in(algo_arg_idx(j):algo_arg_idx(j+1))];           
            end
            % step 3:  替换参数得到实际调用串
            algo_invoke = MLAT_Conf.AlgoListAll{i,2};
            for j = 1 : 1 : length(algo_arg_idx)/2
                algo_invoke  = strrep(algo_invoke, arg_in_name_list{j}, arg_in_list{j});
            end

            % 调用算法
            W = eval(algo_invoke);
        end
    end
end



