%Configuration file of Machine Learning Algorithm Tester (MLAT)
% 
%  Before run main.m, please edit this file first.
%
% See also main.m

% Author: Yanan Sun
% Author: LCY-Hugepanda
% Copyright: lcy.hugepanda@gmail.org

global MLAT_Conf;

%% ----------Configuration Part (Please edit before run MLAT_Main.m) --------------
% Configurations about the displaying
format compact

% Configurations about the evaluating precedures
test_type = 1;  % 实验测试类型：1--多次重复CV的多数据集标准测试   2--二维数据可视化实验

if 1 == test_type
    num_cv = 5; % Numbers of Cross Validation (CV)
    num_repeat = 1; % Numbers of repeats of CV
elseif 2 == test_type
    % 占位
end

% Algorithms to be evaluated
% 算法可能用到包括dd_tools,lcy-prototypealgo和
    % 实际测试，集成算法
% algo_list ={...
%     'Meta_Bagging(#''OCLT_AlgoLibsvmOCSVM(A, ''''default'''', 0.1, A)''#,#20#,#''votec''#)',...
%     'Meta_Bagging(#''parzen_dd(A,0.1)''#,#20#,#''votec''#)',...
%     'Meta_Bagging(#''gauss_dd(A,0.1)''#,#20#,#''votec''#)',...
%     'Meta_Bagging(#''mst_dd(A,0.1)''#,#20#,#''votec''#)',...
%     'Meta_Bagging(#''nndd(A,0.1)''#,#20#,#''votec''#)'...
%     };
    %单算法测试
algo_list ={...
    %'Libsvm_OCSVM(#0.1#)'
    %'DDTools_NNDD(#0.1#)',...
    %'DDTools_GaussDD(#0.1#)',...
     'Ensemble_Classification(#3#,#''kmeans''#,#''gauss_dd''#,#maxc#)',...
     'Ensemble_Classification(#3#,#''emclust''#,#''gauss_dd''#,#maxc#)',...
     'Ensemble_Classification(#3#,#''hclust''#,#''gauss_dd''#,#maxc#)',...
     'Ensemble_Classification(#3#,#''kcentres''#,#''gauss_dd''#,#maxc#)',...
     'Ensemble_Classification(#3#,#''modeseek''#,#''gauss_dd''#,#maxc#)'
%       'DDTools_GaussDD(#0.1#)',...
%       'DDTools_LOF(#0.1#)',...
%       'DDTools_SVDD(#0.1#)'
    %'DDTools_GaussDD(#0.1#)'
    %'DDTools_Rankboost(#0.1#,#100#)',...
    %'NoOutlier_Rankboost(#0.1#,#100#,#''gendatblockout''#)',...
    %'DDTools_LOF(#0.1#)',...
    %'DDTools_GaussDD(#0.1#)'
    %'Meta_Bagging(#''gauss_dd(A,0.1)''#,#20#,#''votec''#)'
    %'Meta_RSM(#''gauss_dd(A,0.1)''#,#20#,#''votec''#)',...
    %'Meta_RSM(#''gauss_dd(A,0.1)''#,#20#,#''votec''#)'
    %'Meta_Boosting(#''nndd(A,0.1)''#,#20#,#''prodc''#,#''gendatblockout''#)',...
    %'Meta_Boosting(#''nndd(A,0.1)''#,#20#,#''wvotec''#,#''gendatblockout''#)',...
    %'Meta_Boosting(#''nndd(A,0.1)''#,#20#,#''maxc''#,#''gendatblockout''#)',...
    %'Meta_Boosting(#''nndd(A,0.1)''#,#20#,#''meanc''#,#''gendatblockout''#)'   
    %'Meta_Bagging(#''nndd(A,0.1)''#,#20#,#''meanc''#)',...
    %'Meta_Bagging(#''nndd(A,0.1)''#,#20#,#''maxc''#)',...
    %'Meta_Bagging(#''nndd(A,0.1)''#,#20#,#''minc''#)'   
    %'Meta_Bagging(#''gauss_dd(A,0.1)''#,#15#,#''maxc''#)',...
    %'Meta_Bagging(#''gauss_dd(A,0.1)''#,#15#,#''meanc''#)',...  
};
algo_list_display = {...
    'Cluster3_Kmeans',...
    'Cluster3_Emclust',...
    'Cluster3_Hclust',...
    'Cluster3_Kcentres',...
    'Cluster3_Modeseek'
};
%algo_list ={'Meta_Bagging(#''parzen_dd(A,0.1)''#,#15#,#''prodc''#)',...
%    'DDTools_GaussDD(#0.1#)','DDTools_ParzenDD(#0.1#)','DDTools_MOG(#0.1#)'};
%algo_list ={'DDTools_GaussDD(#0.1#)','DDTools_ParzenDD(#0.1#)','DDTools_MOG(#0.1#)'};
  %  DDTools_lpDD','DDTools_MOG','PRTools_LMNC','PRTools_RBNC'}
   % ,'PRTools_NEURC','PRTools_RNNC','PRTools_SVC','PRTools_NUSVC','PRTools_KERNELC','PRTools_PERLC', 'PRTools_QUADRC','PRTools_POLYC','PRTools_SUBSC','PRTools_LDC','PRTools_QDC','PRTools_UDC','PRTools_MOGC','PRTools_KNNC','PRTools_PARZENC','PRTools_TREEC','PRTools_NAIVEBC','PRTools_KLLDC','PRTools_PCLDC','PRTools_LOGLC','PRTools_FISJERC','PRTools_NMC','PRTools_NMSC','DDTools_Gauss','DDTools_SVDD','DDTools_Autoenc_dd','DDTools_Kmeans_dd','DDTools_Kcenter_dd','DDTools_Pca_dd','DDTools_Som_dd','DDTools_Mst_dd','DDTools_nndd','DDTools_knndd','DDTools_dnndd','DDTools_MPM','DDTools_incSVDD','DDTools_ParzenDD','MLAlgo_LOF','MLAlgo_SVM'};
%'DDTools_Rob_gauss_dd'
FRACREJ = 0.1;

% Datasets to be evaluated
if 1 == test_type
    dataset_path = '../datasets/';
elseif 2 == test_type
    dataset_list = [1 2 3];  % 二维人工数据集选择
end


% Criteria to be evaluated
%crit_list = {'DDTools_F1','DDTools_AUC','OC_MCC'};
%crit_list = {'DDTools_AUC','PRTools_ERROR'};
crit_list = {'DDTools_F1'};

%% ----------Automatic Checking Part (DO NOT edit) --------------
% Import algorithm invoking templates
temp = importdata('..\config\MLAT_AlgoList.txt');
AlgoList = cell(ceil(length(temp)/3), 2);
for i = 1 : 3 : length(temp)
    AlgoList{round(i/3 + 1), 1} = temp{i};
    AlgoList{round(i/3 + 1), 2} = temp{i+1};
end
MLAT_Conf.AlgoListAll = AlgoList;

temp = importdata('..\config\MLAT_CritList.txt');
CritList = cell(ceil(length(temp)/3), 2);
for i = 1 : 3 : length(temp)
    CritList{round(i/3 + 1), 1} = temp{i};
    CritList{round(i/3 + 1), 2} = temp{i+1};
end
MLAT_Conf.CritListAll = CritList;

% 获取所有测试数据集路径
if 1 == test_type
    fileFolder=fullfile(dataset_path);
    dirOutput=dir(fullfile(fileFolder,'*'));
    dataset_list ={dirOutput.name};
end
