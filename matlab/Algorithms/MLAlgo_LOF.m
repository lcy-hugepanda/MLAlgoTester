function out = MLAlgo_LOF(varargin)

argin = setdefaults(varargin,[],20,0.8);

if mapping_task(argin,'definition')
	out = define_mapping(argin,'untrained',['PRTools5_LOF_' int2str(argin{2})]);


elseif mapping_task(argin,'training')
    [a , k ,setlof] = deal(argin{:});
    [ins_num ,att_num ]= size(a);
    data = a.data;
    D = pdist(data);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     D = pdist(data,'euclidean');
    disp = squareform(D) ;
    for i = 1:1:ins_num;
        [sdisp(i,:),index(i,:)] = sort(disp(i,:));
         k_disp(1,i) = disp(i,index(i,k+1));
         reach_dist(i,:) = sdisp(i,:);
         j = 1;
         while reach_dist(i,j) <=  k_disp(1,i);
            reach_dist(i,j) = max ( k_disp(1,i) , disp(i,index(i,k+1)) );
            j = j+1;
         end;
    end;
    for i = 1:1:ins_num;
        b(1,i) = 0;
        for j = 2:1:ins_num;
            if reach_dist(i,j)<=(k_disp(1,i)+0.00001);
                b(1,i)=b(1,i)+1;
            end
        end
        lrd(1,i) = b(1,i) / sum(reach_dist( i,2:(b(1,i)+1) ),2) ;
    end;
    for i = 1:1:ins_num;
        temp(1,i) = 0 ;
        for j = 2:1:b(1,i);
            temp(1,i) = temp(1,i) + lrd(1,index(i,j)) / lrd(1,i);
        end;
    lof(1,i) = temp(1,i) / b(1,i);
    end
    data.lof = lof; 
    data.minpts = k;
    data.setlof = setlof;
    
    % pack arguments of trained classifier
    out = trained_classifier(a, data);

% Execution Path C: Testing
elseif mapping_task(argin,'execution')
	[a,w] = deal(argin{1:2}); 
	v = getdata(w);
    for i = 1:1:length(a)
    if v.lof(1,i) > v.setlof;
        cflag(i,2) = 1;
    else;
        cflag(i,1) = 1;
    end;
    end;
    % pack arguments of the testing results
	out = setdat(a,cflag,w);
else
  error('Illegal call')
  
end
return 
