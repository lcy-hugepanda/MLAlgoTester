     function recall = ddtools_recall(A,W)
        [~,f] = dd_error(A,W);
        recall = f(1,2);
    end