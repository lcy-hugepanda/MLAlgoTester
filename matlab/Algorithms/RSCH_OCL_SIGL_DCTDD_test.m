% ���ڲ���DCT_DD�㷨
% ����DCT_DD������E12�Ļ�������������������Ե�ʱ��Ҳ�ǰ���E12�ķ����������

% ����BrokenBanana�ͺã���cluster������
a_orig = MLAT_GenAritificialData(14);
a = target_class(a_orig);

k = 2;
disM = pdist(+a); % �������
clust = linkage(disM,'ward');  % ��ξ�����
Idx = cluster(clust,'maxclust',k);  % ������
[dbcv,ftree,apts,dmreach,data,clusterIdx,compcl,point_degree] = DBCV(+a,Idx,'normal');
    % dbcv: �þ�������DBCV����ֵ����������в�����Ҫ��
    % ftree��k��DCT���ı�(1xk��cell����)��ÿһ���ߵı�ʾ��ʽ��[���A ���B �߳�]
    % apts��DBCV����ʱ�õ���core distance
    % dmreach��k��DCT���Ŀɴ�������1xk��cell���飩�������ǶԳ���
    % data��k��DCT����ԭ����(1xk��cell����)���������+a��ʽһ��
    % clusterIdx��k��DCT����(1xk��cell����)��ÿһ����Ԫ����ԭa�е����
    % compcl����������ڵ��ܶ���С����ֵ��������ڿɴ�������ֵ��
    % point_degree��k��DCT����(1xk��cell����)��ÿһ�����degree
    
% ���¶���ÿһ����������ɶ�Ӧ��DCT_DD
w = cell(1,k); % ��������
for i = 1 : 1 : k
    w{i} = RSCH_OCL_SIGL_DCTDD(data{i},0.1,ftree{i},apts(clusterIdx{i}),compcl(i),point_degree{i});
end

% ���ӻ�
scatterd(a_orig);
hold on
for i = 1 : 1 : k
    plotc(w{i});
    hold on
end

