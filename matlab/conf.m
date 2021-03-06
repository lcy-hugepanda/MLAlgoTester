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
algo_list ={...
%     'E12_DBCV_MST(#5#,#0.1#)',...
%     'E10_DBM_EOC_GAUSS(#0.01#,#0.0005#,#1#,#0.9#)',...
%         'E10_DBM_EOC_GAUSS(#0.001#,#0.0005#,#1#,#0.95#)',...
%    'E10_DBM_EOC_GAUSS(#0.01#,#0.065#,#1#,#0.99#)',...
%         'DDTools_MSTCD(#0.05#)',...
%      'Meta_ClustEOCC(#''direct''#,#3#,#''kmeans''#,#''mst_dd(A,0.05)''#,#maxc#)',...
%      'Meta_ClustEOCC(#''direct''#,#3#,#''hclust''#,#''mst_dd(A,0.05)''#,#maxc#)',...
%    'E13_FMST(#''gauss_dd(A,0.05,0.8)''#,#maxc#)'
%   'E13_FMST(#''mst_dd(A,0.05)''#,#maxc#)'
%    'E13_FMST(#''knndd(A,0.1,2,''''gamma'''')''#,#maxc#)'
	'DDTools_GaussDD(#0.05#)',...
% 	'DDTools_MOG(#0.05#)',...
% 	'DDTools_NNDD(#0.05#)',...
% 	'DDTools_MSTCD(#0.05#)',...
% 	'Libsvm_OCSVM(#0.05#)',...
% 	'DDTools_SVDD(#0.05#)',...
% 	'DDTools_KNNDD(#0.05#)',...
% 	'DDTools_NNDD(#0.05#)',...
%     'DDTools_LOF(#0.05#)',...
%     'DDTools_LOCI(#0.05#)',...
%      'Meta_ClustEOCC(#''direct''#,#3#,#''kmeans''#,#''mst_dd(A,0.05)''#,#mergec#)',...
%      'Meta_ClustEOCC(#''direct''#,#4#,#''kmeans''#,#''mst_dd(A,0.05)''#,#mergec#)',...
};
algo_list_display = {...
   'FMST',...
    'Gauss',...
    'ParzenDD'
};
FRACREJ = 0.1;

% Datasets to be evaluated
if 1 == test_type
    dataset_path = '../datasets/test_XS/';
elseif 2 == test_type
    dataset_list = [14];  % 二维人工数据集选择
end


% Criteria to be evaluated
%crit_list = {'DDTools_F1','DDTools_AUC','OC_MCC'};
% crit_list = {'OC_MCC'};
crit_list = {'DDTools_AUC','DDTools_Precision','DDTools_Recall','DDTools_F1','OC_MCC'};
% crit_list = {'DDTools_Precision','DDTools_Recall','DDTools_F1','OC_MCC'};

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
