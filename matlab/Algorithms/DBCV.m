function [valid,Edges,d_ucore_cl,mr,fdata,objcl,compcl] = DBCV(data,partition)
%version using kernel. still one intra and inter cluster value, but we got
%rid of parameter k, for the number of neighbors during core calculation.

  
clusters  = unique(partition);
dist             = squareform(pdist(data)).^2;

for i = 1:1:length(clusters)
      fdata{i} = [];
      cluster{i} = find(partition == clusters(i));
      for j = 1 : 1 : length(cluster{i})
           fdata{i}(j,:) = data(cluster{i}(j),:);    
      end
end
%treating singleton clusters... since they are going to receive score 0, we
%can say they are noise..
for i=1:length(clusters)
    if(sum(partition == clusters(i)) == 1)
        partition(partition == clusters(i)) = 0;
        clusters(i) = 0;
    end
end

clusters  = setdiff(clusters,0);

if (isempty(clusters) || (length(clusters) == 1))
    valid = 0;
    return;
end

data      = data(partition~=0,:);

dist      = dist(partition~=0,partition~=0);

poriginal = partition;
partition = partition(partition~=0);


nclusters = length(clusters);

[nobjects nfeatures] = size(data);


d_ucore_cl       = zeros(1,nobjects);
compcl           = zeros(1,nclusters);
int_edges        = cell(1,nclusters);
int_node_data   = cell(1,nclusters);
for i=1:nclusters
    
    objcl{i}   = find(partition == clusters(i));
    
    nuobjcl = length(objcl{i});
            
    [d_ucore_cl(objcl{i}) mr{i}] = matrix_mutual_reachability_distance(nuobjcl, dist(objcl{i},objcl{i}),nfeatures);  % ucore distance of each object in its own cluster
     
    G.no_vertices = nuobjcl;
    G.MST_edges   = zeros(nuobjcl-1,3);
    G.MST_degrees = zeros(nuobjcl,1);
    G.MST_parent  = zeros(nuobjcl,1);
    
    [Edges{i} Degrees] = MST_Edges(G, 1,mr{i});
    
    int_node     = find(Degrees~=1);
    int_edg1     = find(ismember(Edges{i}(:,1),int_node));    
    int_edg2     = find(ismember(Edges{i}(:,2),int_node));    
    int_edges{i} = intersect(int_edg1,int_edg2);
    
    
    if (~isempty(int_edges{i}))
        compcl(i)  = max(Edges{i}(int_edges{i},3));
    else 
        compcl(i) = max(Edges{i}(:,3));         
    end
    int_node_data{i} = objcl{i}(int_node);
    if isempty(int_node_data{i})
        int_node_data{i} = objcl{i}; 
    end
end

sep_point = zeros(nobjects,nobjects);
for i=1:(nobjects-1)
    for j=i:nobjects
        sep_point(i,j) = max([dist(i,j) d_ucore_cl(i) d_ucore_cl(j)]);        
        sep_point(j,i) = sep_point(i,j);
    end
end

valid = 0;
sepcl = Inf(nclusters,1);
for i=1:nclusters
    other_cls = setdiff(clusters,clusters(i)); 
    
    sep = zeros(1,length(other_cls));
    for j=1:length(other_cls)                
        sep(j) = min(min(sep_point(int_node_data{i},int_node_data{clusters==other_cls(j)}))); 
    end
    sepcl(i) = min(sep);
    dbcvcl = (sepcl(i) - compcl(i)) / max(compcl(i),sepcl(i));
    valid = valid + (dbcvcl * sum(partition == clusters(i)));
end

valid = valid / length(poriginal); 

end    
