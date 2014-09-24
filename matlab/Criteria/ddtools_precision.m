function precision = ddtools_precision(A,W)
        [~,f] = dd_error(A,W);
        precision = f(1,1);
    end