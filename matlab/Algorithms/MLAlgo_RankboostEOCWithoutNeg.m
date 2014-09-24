% ��dd_tools��rankboostc�Ļ����ϣ���һ���װ
% ����ʵ�ĸ����滻Ϊ�˹����ɵĸ���
% ������
%   A ԭ���ݼ�
%   fracrej outlier����
%   T ��������
%   genoutMethod �������ɷ���
%       'gendatout' �����������˹�����
%       'gendatoutg' ��˹�ֲ��������˹�����
%       'gendatblockout' block-shaped�������˹�����

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
    
    % ʹ���˹����������ʵ�ĸ��࣬����eval_A
	genout_str = sprintf('%s(A, 4*length(getnlab(A)))',genoutMethod);
    gened_outlier = eval(genout_str);
    gened_outlier = seldat(gened_outlier,'outlier');
    eval_A = gendatoc(target_class(A), gened_outlier);
    
    % ѵ��rankboost
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
	%out = setdat(A,out,W); % ��һ����û�б�Ҫ�ģ�ֱ�ӷ���rankboost�Ľ������

% Error invoking handling (commonly leave it unmodified)
else
  error('Illegal call')
  
end
return % END main prmapping function