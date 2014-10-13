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
      dist{i} =  squareform( pdist(data{i}, 'euclidean'));  
      for j = 1:n(i)  
       apts{i}(o) =  ((sum((1./dist{i}(j,1:j-1)) .^ d) + sum((1./dist{i}(j,j+1:n(i))) .^ d)) / (n(i) - 1)) ^(-1/d) ;
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
      [Wt{k},Pp{k}]=mintree(length(apts{k}),d_mreach{k});
      %找到最长边
      DSC(k) = max(Pp{k}(:,3));
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
     VC(i) = (min(DSPC(i,:)) - DSC(i))/max(min(DSPC(i,:),DSC(i)));
     DBCV = DBCV + n(i)/length(a.data) * VC(i);
  end
  out = DBCV;
end
%构建最小生成树
function [Wt,Pp]=mintree(n,W)
tmpa=find(W~=inf);
[tmpb,tmpc]=find(W~=inf);
w=W(tmpa);
e=[tmpb,tmpc];
[wa,wb]=sort(w);
E=[e(wb,:),wa,wb];
[nE,mE]=size(E);
temp=find(E(:,1)-E(:,2));
E=E(temp,:);
P=E(1,:);
k=length(E(:,1));
while rank(E)>0
    temp1=max(E(1,2),E(1,1));
    temp2=min(E(1,2),E(1,1));
    for i=1:k
        if E(i,1)==temp1
            E(i,1)=temp2;
        end
        if E(i,2)==temp1
            E(i,2)=temp2;
        end
    end
    a=find(E(:,1)-E(:,2));
    E=E(a,:);
    if rank(E)>0
        P=[P;E(1,:)];
        k=length(E(:,1));
    end
end
Wt=sum(P(:,3));
Pp=[e(P(:,4),:),P(:,3:4)];
end