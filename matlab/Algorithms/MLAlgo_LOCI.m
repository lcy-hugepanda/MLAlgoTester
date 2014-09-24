function out = MLAlgo_LOCI(varargin)

argin = setdefaults(varargin,[],0.5,20);

if mapping_task(argin,'definition')
	out = define_mapping(argin,'untrained',['PRTools5_LOF_' int2str(argin{2})]);


elseif mapping_task(argin,'training')
    [a , b, n_min] = deal(argin{:});
    [ins_num ,att_num ]= size(a);
    data = a.data;
    D = pdist(data);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     D = pdist(data,'euclidean');
    disp = squareform(D) ;
    r_max = 1/b * max(max(D));
    for i = 1:1:ins_num;
        [s_dist(i,:),index(i,:)] = sort(disp(i,:));
        d_list(i,:) = b * s_dist(i,:);
        N_list(i,1) = 0;
        for j = 1:1:ins_num;
            if s_dist(i,j) <= r_max;
               N_list(i,1) = N_list(i,1) + 1;
            end;
        end;
        end;

for i = 1:1:ins_num;
    N_list(i,2) = 0;
    for j = 1:1:N_list(i,1);
        n(i,j) = sum(sum( s_dist(i,:) <= ( b * s_dist( i , j )))) ;
        if n(i,j) <= n_min;
           N_list(i,2) = N_list(i,2) + 1;
        end
    end;
end
    for i = 1:1:ins_num;
        for j = N_list(i,2):1:N_list(i,1);
            for neighbor = 1:1:j
                n_temp(j,neighbor) = sum(sum( s_dist(index(i,neighbor),:) <= ( b * s_dist( i , j ))));
            end
            n_ave(i,j) = (sum(n_temp(j,:))) / j;
            n_std(i,j) = std(n_temp(j,:));
            MDEF(i,j) = 1 - ( n(i,j) / n_ave(i,j) );
            MDEF_STD(i,j) = n_std(i,j) / n_ave(i,j);
        end;
    end
    data.MDEF = MDEF; 
    data.MDEF_STD = MDEF_STD;
    data.N_list = N_list;
    
    % pack arguments of trained classifier
    out = trained_classifier(a, data);

% Execution Path C: Testing
elseif mapping_task(argin,'execution')
	[a,w] = deal(argin{1:2}); 
	v = getdata(w);
   for i = 1:1:length(a);
    flag(i,1) = 0;
       for j = v.N_list(i,2):1:v.N_list(i,1);
        if v.MDEF(i,j) > 3 * v.MDEF_STD(i,j);
            flag(i,1) = 1;
        end
        end;
        if flag(i,1) == 0;    
            flag (i,2) = 1;
        end
    end;
    % pack arguments of the testing results
    out = setdat(a,flag,w);
    
else
  error('Illegal call')
  
end
return 
