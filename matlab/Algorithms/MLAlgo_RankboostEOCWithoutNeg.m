% 在dd_tools的rankboostc的基础上，加一层包装
% 将真实的负类替换为人工生成的负类
% 参数：
%   A 原数据集
%   fracrej outlier比例
%   T 迭代次数
%   genoutMethod 负类生成方法
%       'gendatout' 超球内生成人工负类
%       'gendatoutg' 高斯分布内生成人工负类
%       'gendatblockout' block-shaped内生成人工负类

function out = MLAlgo_RankboostEOCWithoutNeg(varargin)

% Set default parameters
argin = setdefaults(varargin,[],0,[]);

% Execution Path A: definition (construct an untrained prmapping)
if mapping_task(argin,'definition')
    % prepare the untrained prmapping, you should modify the name
	out = define_mapping(argin,'untrained','RankboostEOCWithoutNeg');

% Execution Path B: training
elseif mapping_task(argin,'training')
    % unpack all arguments, the name of parameters could be modified.
    % but the prdataset here always has a name of 'a' / 'A'
    [A,fracrej,T, genoutMethod] = deal(argin{:});
    
    % Prepare
        %[numInstances,numAttributes,numClasses] = getsize(A); 
    
    % 使用人工负类替代真实的负类，构成eval_A
	genout_str = sprintf('%s(A, 4*length(getnlab(A)))',genoutMethod);
    gened_outlier = eval(genout_str);
    gened_outlier = seldat(gened_outlier,'outlier');
    eval_A = gendatoc(target_class(A), gened_outlier);
    
    % 训练rankboost
    W = rankboostc(eval_A,fracrej,T);
                                    
    % Construct output
    data.W = W;
    out = trained_classifier(A, data);

% Execution Path C: Testing
elseif mapping_task(argin,'execution')
    % unpack arguments for testing
    % commonly there are two arguments
    %  1) the prdataset for testing
    %  2) the trained prmapping
	[A,W] = deal(argin{1:2}); 
    
    % retrieve the arguments of trained classifier (the 'data' in the training phase)
	v = getdata(W);

    % Evaluate the testing dataset
    classifier = v.W;
    
    % Construct output
    out = A*classifier;
	%out = setdat(A,out,W); % 这一句是没有必要的，直接返回rankboost的结果即可

% Error invoking handling (commonly leave it unmodified)
else
  error('Illegal call')
  
end
return % END main prmapping function