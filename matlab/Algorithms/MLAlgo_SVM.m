function out = MLAlgo_SVM(varargin)

argin = setdefaults(varargin,[],'quadratic');

if mapping_task(argin,'definition')
	out = define_mapping(argin,'untrained',['MLAlgo_SVM_' int2str(argin{2})]);


elseif mapping_task(argin,'training')
    [a,kernel_function] = deal(argin{:});
    [ins_num ,att_num ]= size(a);
    flag = getnlab(a);
    STRUCT_SVM = svmtrain(a.data,flag,'kernel_function',kernel_function);
    
    data.STRUCT_SVM = STRUCT_SVM; 

    % pack arguments of trained classifier
    out = trained_classifier(a, data);

% Execution Path C: Testing
elseif mapping_task(argin,'execution')
	[a,w] = deal(argin{1:2}); 
    [ins_num ,att_num ]= size(a);
    data = a.data;
	v = getdata(w);
    flag = svmclassify(v.STRUCT_SVM, data);
    for i = 1:1:length(a)
        if flag(i,1) == 1
            cflag(i,1) = 1;
        else
            cflag(i,2) = 1;
        end
    end
    
   
    % pack arguments of the testing results
    out = setdat(a,cflag,w);
else
  error('Illegal call')
  
end
return 



