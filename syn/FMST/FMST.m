%FMST
%input a prdataset
function [MST,tree]= FMST(a)
    n = length(a.data);
    k = floor(sqrt(n));
    %DAC Divide and Conquer Using K-means
   [IDX, C] = kmeans(a.data, k);
   [mst_1 tree_c]= DAC(a.data,k,IDX,C)  ;
   for i = 1:length(tree_c)
       cluster(i,:) = (C(tree_c(i,1),:)+ C(tree_c(i,2),:))/2;
   end
   [IDX2, C2] = kmeans(a.data, k-1,'Start',cluster, 'Replicates',1);
   mst_2 = DAC(a.data,k-1,IDX2,C2);
   
   for i = 1:n
       for j = 1:n
           if mst_2(i,j) > mst_1(i,j)
               dist(i,j) = mst_2(i,j);
           else
               dist(i,j) = mst_1(i,j);
       end
   end
   end
   [tree,MST]=mst(dist);
end