function result=MLAT_EvaluateAlgo(A,W, str_crit)
	global MLAT_Conf;
    [num_algo, ~] = size(MLAT_Conf.CritListAll);
    for i = 1 : 1 : num_algo;
        if (strcmp(str_crit, MLAT_Conf.CritListAll{i,1}));
            result = eval(MLAT_Conf.CritListAll{i,2});
        end
    end
end
