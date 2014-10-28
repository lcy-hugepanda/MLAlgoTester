function [k, result] = selectKbyEntropy(a, disM, nameClustAlgo,k)
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
%      for j = 1:i 
%         w(i,j) = length(find(Idx{i} == j));
%      end
%      E(i) = -sum(w(i,:).*log(w(i,:)));
      for j = 1:i
          temp = find(Idx{i} == j);
          for nn = 1:length(temp)
              if temp(nn) == center{i}(j)
                   w{i,j}(nn) = 1;
              else
                w{i,j}(nn) = disM.data(center{i}(j),temp(nn))/sum(disM.data(temp(nn),center{i}));
              end
          end
          E_temp(j) = sum(w{i,j}.*log(w{i,j}));
      end
      E(i) = sum(E_temp);
    end
    
   [maxE,k] = min(E);
   result = Idx{k};
   
end