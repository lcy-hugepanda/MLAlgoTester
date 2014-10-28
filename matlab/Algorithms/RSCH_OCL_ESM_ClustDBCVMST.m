% E12论文使用的新方法
% 参数
%   A: 训练数据
%   nameClustAlgo: 聚类算法名
%   k: 聚类中心个数上限
%   frej: 拒绝率
function out = RSCH_OCL_ESM_ClustDBCVMST(varargin)
argin = setdefaults(varargin,[],'kmeans',6,0.1);

if mapping_task(argin,'definition')
	out = define_mapping(argin,'untrained',['RSCH_DBCVMST' int2str(argin{2})]);
elseif mapping_task(argin,'training')
    [A ,nameClustAlgo,k,frej] = deal(argin{:});
    % 单独提取正类样本用于训练
    A_target = target_class(A);
    
    % 聚类分析
    dbcv = zeros(1,k);
    msts = cell(1,k);
    dbcv_best = -100;
    best_i = 0;
    for i = 2 : 1 : k
        % 调用聚类算法（先只使用kmeans测试）
        switch nameClustAlgo
            case 'kmeans'
                Idx = feval(nameClustAlgo,A_target,i);
            case 'emclust'
                Idx = feval(nameClustAlgo,a,[],k,[]);
            case 'hclust'            
                Idx = feval(nameClustAlgo,disM,'complete',k);
            case 'modeseek'
                Idx = feval(nameClustAlgo,disM,k);
            case 'kcentres'
                Idx = feval(nameClustAlgo,disM,k);
            case 'fcm'
                [center,U,obj_fcn] = fcm(a.data,k);
                maxU = max(U);
                Idx = zeros(length(a.data),1);
                for i = 1:k  
                    Idx(find(U(i,:) == maxU)) = i;
                end 
            case 'dbscan'
                [Idx,type]=dbscan(a.data,k,[]) ;
                k = max(unique(Idx));
        end
        [dbcv(i),trees{i},adjM{i}] = SYN_DBCV(A_target,Idx);  
        if dbcv(i) > dbcv_best
            dbcv_best = dbcv(i);
            best_i = i;
            best_Idx = Idx;
        end
    end
    
    % 对每一个聚类簇的MST直接构建MST单类分类模型
    subW = cell(1,best_i);
    for i = 1:1:best_i
        subW{i}= RSCH_OCL_ESM_ClustDBCVMST_subMST(A_target,frej,trees{best_i}{i},adjM{best_i}{i});
    end
    
    % 构建trained的prmapping
    data.Idx = best_Idx;
    data.subW = subW;
    data.k = best_i;
    data.mst = trees{best_i};
    out = trained_classifier(A_target, data);
    
% 测试部分
elseif mapping_task(argin,'execution')
    [a,v] = deal(argin{1:2}); 
	mapping = getdata(v);
    w = mapping.subW;
%     for i = 1:1:length(w)
%        W{i} = w{i} * dd_normc ;
%     end
    W_out = [w{:}] * mergec;
    out = a * W_out;
     
end
end


%index 是一个标签数组，存储聚类标签。a为prdataset类型数据集。
function [DBCV, tree, A] = SYN_DBCV(a,index)
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
  
end

function [tree,A] = mst(d)
% [tree,A] = mst(d)
% minimum spanning tree
% 
% INPUT
%           d       [m x m] distance matrix
% OUTPUT
%           tree    [m-1 x 2] list of edges
%           A       [m x m] adjecency matrix
%
% See also mst_dd,datasets, mappings

%  Copyright: Piotr Juszczak, p.juszczak@tudelft.nl
%  Information and Communication Theory Group,
%  Faculty of Electrical Engineering, Mathematics and Computer Science,         
%  Delft University of Technology,            
%  The Netherlands

if isdataset(d), d = +d; end

[i,j,dd] = find(+d); %find edges
edges = [i,j];
costs = [dd]; 

% Process (x,y) points, or z points (complex).

if size(edges, 2) == 1
	if nargin == 1
		z = edges;
	elseif nargin == 2
		x = edges;
		y = costs;
		z = x + sart(-1)*y;
	end
	npts = length(z);
	[from, to] = meshgrid(1:npts, 1:npts);
	from = from(:);
	to = to(:);
	f = find(from < to);   % Unique edges only.
	from = from(f);
	to = to(f);
	edges = [from to];
	costs = abs(z(to) - z(from));
end

% Sort the edges by their cost.

[costs, indices] = sort(costs);
edges = edges(indices, :);

from = edges(:, 1);
to = edges(:, 2);

parent = 1:max(max(edges));
rank = zeros(size(parent));
keep = logical(zeros(size(parent)));

% Join sub-trees until no more links to process.

for i = 1:length(from)
	x = sfind(parent, from(i));
	parent(from(i)) = x;   % Acceleration strategy.
	y = sfind(parent, to(i));
	parent(to(i)) = y;   % Acceleration strategy.
	if x ~= y
		[parent, rank] = slink(x, y, parent, rank);
		keep(i) = ~~1;
	end
end

result = edges(keep, :);

% Check for disconnected graph, if desired.
%  For a single connected graph, everyone
%  will have the same root-parent.  Isolated
%  points are not considered part of the
%  graph system.

if (1)
	p = zeros(size(parent));
	for i = 1:length(parent)
		p(i) = sfind(parent, i);
	end
	if ~all(p == p(1))
		count = sum(diff(sort(p)) ~= 0) + 1;
		disp([' ## Not a connected graph.'])
		disp([' ## Contains ' int2str(count) ' independent graphs.'])
	end
end

% Sort indices for ease of reading.

for i = 2:-1:1
	[ignore, indices] = sort(result(:, i));
	result = result(indices, :);
end

if nargout > 0, tree = result; end

A = zeros(size(d));

for k=1:size(tree,1)
	A(tree(k,1),tree(k,2) ) = +d(tree(k,1),tree(k,2));
	A(tree(k,2),tree(k,1) ) = +d(tree(k,1),tree(k,2));
end

end	

	
% ---------- sfind ---------- %


function z = sfind(p, x)

% sfind -- Root of a set.
%  sfind(p, x) returns the root parent of the set
%   containing index x, given parent-list p.  The
%   speed is O(lon(n)).

y = x;

while y ~= p(y)
	y = p(y);
end

z = p(y);

end

% ---------- slink ---------- %
function [p, rank] = slink(x, y, p, rank)

% slink -- Link two sets.
%  [p, rank] = slink(x, y, p, rank) links two sets,
%   whose roots are x and y, using parent array p,
%   and rank(x),  a measure of the depths of the
%   tree from root x.  The speed is O(n).

if rank(x) < rank(y)
	p(x) = y;
else
	if rank(y) < rank(x)
		p(y) = x;
	else
		p(x) = y;
		rank(y) = rank(y) + 1;
	end
end

return;
end