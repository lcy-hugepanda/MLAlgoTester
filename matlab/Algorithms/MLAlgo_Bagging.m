function out = MLAlgo_Bagging(varargin)

argin = setdefaults(varargin,[],0.6,10,'gauss_dd');


if mapping_task(argin,'definition')
	out = define_mapping(argin,'untrained',['MLAlgo_Bagging_' int2str(argin{2})]);


elseif mapping_task(argin,'training')
    [a , rate ,t,Algo_name] = deal(argin{:});
    [ins_num ,att_num ]= size(a);
    N = floor(ins_num * rate);
    str_training = [Algo_name,'(A)'];
    for i = 1:t
        [A,b,ia,ib] = gendat(a,N);
        dataset_split{i,1} = A;
        dataset_split{i,2} = ia;
        
        W{i}= eval(str_training);
    end
    data.w = W;
    data.t = t;
    data.Algo_name = Algo_name;
    data.rate = rate;
    data.ins_num = ins_num;
    
    % pack arguments of trained classifier
    out = trained_classifier(a, data);

% Execution Path C: Testing
elseif mapping_task(argin,'execution')
	[a,v] = deal(argin{1:2}); 
	mapping = getdata(v);
    t = mapping.t;
    W = mapping.w;
    Algo_name = mapping.Algo_name;
    %split_num = mapping.split{1:5,2};
    %split_dataset = mapping.split{:,1};
    rate = mapping.rate;
     N = floor(length(a) * rate);
    for i = 1:t
        w = W{i};
        [A,b,ia,ib] = gendat(a,N);
        dataset_split{i,1} = A;
        dataset_split{i,2} = ia;
        str_testing = [Algo_name,'(A,w)'];
        result{i} = eval(str_testing);
        for j = 1:N
            flag(dataset_split{i,2}(j),i) = result{i}.nlab(j);
        end
    end
    for i = 1:length(a)
        if length(find(flag(i,:) == 1)) > length(find(flag(i,:) == 2))
            cflag(i,1) = 1;
            cflag(i,2) = 0;
        elseif length(find(flag(i,:) == 1)) < length(find(flag(i,:) == 2))
            cflag(i,2) = 1;
            cflag(i,1) = 0;
        else
            cflag(i,2) = 0;
            cflag(i,1) = 0;
        end
    end
    % pack arguments of the testing results
	out = setdat(a,cflag,v);
else
  error('Illegal call')
  
end
return 
