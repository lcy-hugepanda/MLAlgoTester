function out = ensemble_classification(varargin)
argin = setdefaults(varargin,[],3,'kmeans','svdd',maxc);
if mapping_task(argin,'definition')
	out = define_mapping(argin,'untrained',['MLAlgo_Ensemble_' int2str(argin{2})]);
elseif mapping_task(argin,'training')
    [a ,k ,Clus_name,Algo_name,Emsemble] = deal(argin{:});
    a = target_class(a);
    d = sqrt(distm(a));
    switch Clus_name
        case 'kmeans'
            Idx = feval(Clus_name,a,k);
        case 'emclust'
            Idx = feval(Clus_name,a,[],k,[]);
        case 'hclust'            
            Idx = feval(Clus_name,d,'complete',k);
        case 'modeseek'
            Idx = feval(Clus_name,d,k);
        case 'kcentres'
            Idx = feval(Clus_name,d,k);
        case 'fcm'
            [center,U,obj_fcn] = fcm(a.data,k);
            maxU = max(U);
            Idx = zeros(length(a.data),1);
            for i = 1:k  
                Idx(find(U(i,:) == maxU)) = i;
            end            
    end
    for i = 1:1:k
        cluster{i} = find(Idx==i);
        data{i} = [];
%         for j = 1 : 1 : length(cluster{i})
%             data{i}(j,:) = a.data(cluster{i}(j),:);    
%             flag{i}(j,:) = a.nlab(cluster{i}(j,1));
%         end
%         d{i} = prdataset(data{i},flag{i});
%         d{i} = genocdat(data{i},data{i});
        data{i} = seldat(a, [],[], cluster{i});
        A = data{i};
        str_training = [Algo_name,'(A)'];
        W{i}= eval(str_training);
    end
    data.Idx = Idx;
    data.w = W;
    data.k = k;
    data.ensemble = Emsemble;
    out = trained_classifier(a, data);
elseif mapping_task(argin,'execution')
    [a,v] = deal(argin{1:2}); 
	mapping = getdata(v);
    w = mapping.w;
    for i = 1:1:length(w)
       W{i} = w{i} * dd_normc ;
    end
    ensemble = mapping.ensemble;
    W_out = [W{:}] * ensemble;
    out = a * W_out;
     
end
end
