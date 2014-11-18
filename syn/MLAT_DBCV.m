%index 是一个标签数组，存储聚类标签。a为prdataset类型数据集。
function out = MLAT_DBCV(a,index)
  [lab,IA,IC] = unique(index);
  d = a.featsize;
  for i = 1:1:length(lab)
      data{i} = [];
      cluster{i} = find(index == lab(i));
      for j = 1 : 1 : length(cluster{i})
           data{i}(j,:) = a.data(cluster{i}(j),:);    
      end
      %data{i} = seldat(a,[],[], cluster{i});
  end
  %计算apts值
  for i = 1:1:length(lab)
      o = 1;
      n(i) = length(cluster{i});
      %得到距离矩阵
      dist{i} =  squareform( pdist(data{i}, 'euclidean'));  
      for j = 1:n(i)  
      %分子，求除点j外，点j到其他所有点距离倒数d次幂,最后求和。
      numerator = sum((1./dist{i}(j,1:j-1)) .^ d) + sum((1./dist{i}(j,j+1:n(i))).^ d);
      %分子除ni-1后的-1/d次幂。
       apts{i}(o) =  (numerator/ (n(i) - 1)) ^(-1/d) ;
       o = o + 1;
      end
  end
  %计算可达距离
  for k = 1:length(lab)
      for i = 1:length(apts{k})
          for j = 1:length(apts{k})
              d_mreach{k}(i,j) = max([apts{k}(i) apts{k}(j) dist{k}(i,j)]);              
          end
      end
      %conducting an MST
      [tree{k},A{k}]=mst(d_mreach{k});
      %找到最长边
      DSC(k) = max(max(A{k}));
  end
  %计算聚类之间密度表示DSPC
  distsum =  squareform( pdist(a.data, 'euclidean'));  
  for i= 1:length(lab)
      for j = i+1:length(lab)
         for p = 1:n(i)
             for q = 1:n(j) 
                 temp(p,q)=max([apts{i}(p) apts{j}(q) distsum(cluster{i}(p),cluster{j}(q))]); 
             end
         end
         DSPC(i,j) = min(min(temp));
         DSPC(j,i) =  DSPC(i,j);
         temp = [];
      end
      DSPC(i,i) =10000000;
  end
  %计算VC，DBCV
  DBCV = 0;
  for i = 1:length(lab)
     VC(i) = (min(DSPC(i,:)) - DSC(i))/max(min(DSPC(i,:)),DSC(i));
     DBCV = DBCV + n(i)/length(a.data) * VC(i);
  end
  out = DBCV;
end
