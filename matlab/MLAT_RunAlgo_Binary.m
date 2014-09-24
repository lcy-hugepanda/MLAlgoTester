function W = MLAT_RunAlgo_Binary(A,func)
    global MLAT_Conf;
    [num_algo, ~] = size(MLAT_Conf.AlgoListAll);
    for i = 1 : 1 : num_algo;
        if (strcmp(func, MLAT_Conf.AlgoListAll{i,1}))
            W = eval(MLAT_Conf.AlgoListAll{i,2});
        end
    end
end
