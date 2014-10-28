%Configuration file of Machine Learning Algorithm Tester (MLAT)
% 
%  This is a template for conf.m.
%  Before run main.m, please copy this file and rename it to "conf.m".
%
% See also main.m

% Author: Yanan Sun
% Author: LCY-Hugepanda
% Copyright: lcy.hugepanda@gmail.org

% 这是conf.m的模板，为了避免同步时可能出现的混乱，conf.m不再参与同步

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
	'DDTools_GaussDD(#0.05#)',...
    'DDTools_ParzenDD(#0.05#)',...
    'DDTools_NNDD(#0.05#)',...
};
algo_list_display = {...
    'GaussDD',...
    'ParzenDD',...
    'NNDD',...
};
FRACREJ = 0.05;

% Datasets to be evaluated
if 1 == test_type
    dataset_path = '../datasets/test_XS/';
elseif 2 == test_type
    dataset_list = [1 2 3];  % 二维人工数据集选择
end

% Criteria to be evaluated
crit_list = {'DDTools_F1','DDTools_AUC'};

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
