    function auc = ddtools_auc(A,W)
       e = dd_roc(A,W);
       auc = dd_auc(e);
    end