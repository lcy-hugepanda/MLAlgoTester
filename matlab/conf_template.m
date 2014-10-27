%Configuration file of Machine Learning Algorithm Tester (MLAT)
% 
%  This is a template for conf.m.
%  Before run main.m, please copy this file and rename it to "conf.m".
%
% See also main.m

% Author: Yanan Sun
% Author: LCY-Hugepanda
% Copyright: lcy.hugepanda@gmail.org

% ����conf.m��ģ�壬Ϊ�˱���ͬ��ʱ���ܳ��ֵĻ��ң�conf.m���ٲ���ͬ��

global MLAT_Conf;

%% ----------Configuration Part (Please edit before run MLAT_Main.m) --------------
% Configurations about the displaying
format compact

% Configurations about the evaluating precedures
test_type = 1;  % ʵ��������ͣ�1--����ظ�CV�Ķ����ݼ���׼����   2--��ά���ݿ��ӻ�ʵ��

if 1 == test_type
    num_cv = 5; % Numbers of Cross Validation (CV)
    num_repeat = 1; % Numbers of repeats of CV
elseif 2 == test_type
    % ռλ
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
    dataset_list = [1 2 3];  % ��ά�˹����ݼ�ѡ��
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

% ��ȡ���в������ݼ�·��
if 1 == test_type
    fileFolder=fullfile(dataset_path);
    dirOutput=dir(fullfile(fileFolder,'*'));
    dataset_list ={dirOutput.name};
end
