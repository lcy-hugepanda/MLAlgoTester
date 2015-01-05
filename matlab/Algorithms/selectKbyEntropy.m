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
%========================================================
%      根据聚类簇内点的个数，计算熵值
%      for j = 1:i 
%         w(i,j) = length(find(Idx{i} == j));
%      end
%      E(i) = -sum(w(i,:).*log(w(i,:)));
%  end
% %=======================================================
%      根据点到聚类中心距离，计算熵值disM.data（i,j）为i到j可达距离矩阵
%   分子，是样本i到聚类c中心的距离
%   分母，是样本i到所有聚类中心距离之和
      for j = 1:i
          temp = find(Idx{i} == j);%找到聚类簇对应的点
          for nn = 1:length(temp)
              if temp(nn) == center{i}(j)%聚类簇的中心点坐标
                   w{i,j}(nn) = 1;%将聚类中心点的权值设为1，，防止后面求log时出现log(0)报错。
              else
                %计算分子，分母，并相除
                w{i,j}(nn) = disM.data(center{i}(j),temp(nn))/sum(disM.data(temp(nn),center{i}));
              end
          end
          %计算j类的E值
          E_temp(j) = sum(w{i,j}.*log(w{i,j}));%w(i,j)存放聚i类，第j类的权值。
      end
      %将聚类i的所有熵值相加
      E(i) = sum(E_temp);
   end
%=======================================================
%      根据殇画出折线图
   x = zeros(1,k);
   for i = 1:k
       x(i) = i;
   end
   figure;
   plot(x(1,2:end),E(1,2:end),'r.-');
%=======================================================
%      求出最小熵值，并给出对应的聚类个数k。
    
   [maxE,k] = min(E);
   result = Idx{k};
   
end
