function [mstout,tree_c] = DAC(d,k,IDX,C)
   data = cell(k,1);
   dist = cell(k,1);
   tree = cell(k,1);
   path = cell(k,1);
   index = cell(k,1);
   n = length(d);
   mst1 = zeros(n,n);
   for i = 1:k
       index{i} = find(IDX==i);
       data{i} = d(index{i},:);
       dist{i} = squareform( pdist(data{i}, 'euclidean'));  
       [tree{i},path{i}]=mst(dist{i});
       if ~isempty(tree{i})
           for j = 1:length(tree{i})
               mst1(index{i}(tree{i}(j,1)),index{i}(tree{i}(j,2))) = path{i}(tree{i}(j,1),tree{i}(j,2));
               mst1(index{i}(tree{i}(j,2)),index{i}(tree{i}(j,1))) = path{i}(tree{i}(j,1),tree{i}(j,2));
           end
       end
   end
   
   
   %CA Combine Algorithm
   dist_c = squareform( pdist(C, 'euclidean'));  
   [tree_c,]=mst(dist_c);
   for i = 1:k-1
       p = tree_c(i,1);
       q = tree_c(i,2);
       connect = zeros(length(data{q}),1);
       for j = 1:length(data{q})
        connect(j) = norm(data{q}(j,:)-C(p));
       end
       [y,I1] = min(connect);
       connect = zeros(length(data{p}),1);
       for j = 1:length(data{p})
        connect(j) = norm(data{p}(j,:)-C(q));
       end
        [y,I2] = min(connect);
        mst1(index{q}(I1),index{p}(I2)) = norm(data{q}(I1,:)-data{p}(I2,:));  
        mst1(index{p}(I2),index{q}(I1)) = norm(data{q}(I1,:)-data{p}(I2,:));  
   end
   mstout = mst1;
end