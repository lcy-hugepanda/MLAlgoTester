function out = MLAT_ARI(cluster_index1,cluster_index2)
   N = length(cluster_index1);
   [k1,IA1,IC1] = unique(cluster_index1);
   [k2,IA2,IC2] = unique(cluster_index2);
   t1 = 0;
   t2 = 0;
   for i=1:1:length(k1)
       label1{i} = find(cluster_index1 == k1(i));
       t1 = t1 + nchoosek(length(label1{i}) ,2);       
   end
   for i=1:1:length(k2)
       label2{i} = find(cluster_index2 == k2(i));
       t2 = t2 + nchoosek(length(find( label2{i})) ,2) ;       
   end
   t3 = 2 * t1 * t2 /(N * (N - 1));
   for i=1:1:length(k1)
       for j=1:1:length(k2)
           sumc(i,j) = 0;
           for index = 1:length(label2{j})
               sumc(i,j) = sumc(i,j) + length(find(label1{k1(i)}==label2{k2(j)}(index)));             
           end  
           if( sumc(i,j) >= 2 )
               sumc(i,j) = nchoosek( sumc(i,j) ,2) ;
           end
       end
   end
   out = (sum(sum(sumc,1)) - t3)/((t1 + t2)/2-t3);  
end