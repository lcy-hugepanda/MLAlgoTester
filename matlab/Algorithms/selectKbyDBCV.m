function [centers, Index,k,tree,path,fdata,fapts,freach] = selectKbyDBCV(a, disM, nameClustAlgo,k)
for i = 2:k
     switch nameClustAlgo
        case 'kmeans'
            Idx{i} = feval(nameClustAlgo,a,i);
            
        case 'emclust'
            Idx{i} = feval(nameClustAlgo,a,[],i,[]);
        case 'hclust'            
            Idx{i} = feval(nameClustAlgo,disM,'complete',i);
        case 'modeseek'
            Idx{i} = feval(nameClustAlgo,disM,i);
        case 'kcentres'
            [Idx{i} center{i} DM{i}] = feval(nameClustAlgo,disM,i);
        case 'fcm'
            [center11,U,obj_fcn] = fcm(a.data,i);
            maxU = max(U);
            Idx{i} = zeros(length(a.data),1);
            for ii = 1:k  
                Idx{i}(find(U(ii,:) == maxU)) = ii;
            end 
        case 'dbscan'
            [Idx{i},type]=dbscan(a.data,i,[]) ;
            i = max(unique(Idx{i}));
     end
     [dbcv(i),ftree{i},A{i},data{i},apts{i},dmreach{i}] = MLAT_DBCV(a,Idx{i});
end
    [dbcv,i] = max(dbcv(2:end));
    
    for j = 1:i
        centers(j,:) = a.data(center{i}(j),:);
    end
    Index = Idx{i};
    k = i;
    tree = ftree{i};
    path = A{i};
    fdata = data{i};
    fapts = apts{i};
    freach = dmreach{i};
end