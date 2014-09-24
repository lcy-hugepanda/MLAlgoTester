function [training,testing]  = MLAT_SplitData(dataset, num_cv )
    if 1 == num_cv
        training{1} = dataset;
        testing{1} = dataset;
        return
    end

    repeat_time = 1;
    while true
        [training,testing] = cv_split(dataset, num_cv );
        need_repeat = false;
        for i = 1 : 1 : num_cv
            [It,Io] = find_target(training{i});
            if (0 == length(It)) || (0 == length(Io))
                need_repeat = true;
            end
        end
        for i = 1 : 1 : num_cv
            [It,Io] = find_target(testing{i});
            if (0 == length(It)) || (0 == length(Io))
                need_repeat = true;
            end
        end
        if ~ need_repeat
            break;
        end
        repeat_time = repeat_time + 1;
        if repeat_time > 20
            break;
        end
    end
end

function [training,testing] = cv_split(dataset, num_cv )
    I = num_cv;
    training = cell(1,I);
    testing = cell(1,I);
    dataset = dataset.x;
    for i=1:I
        [training{i},testing{i},I] = dd_crossval(dataset,I);
    end
end