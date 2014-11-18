% ����˵��
% a: ѵ�����ݼ�
% numClust: ���ȷ���������
%       --'direct'   ��ֱ�Ӹ����������
%       --'entropy' ������ȷ���������
%       --'DBCV' ����DBCVȷ���������
% k: �������
%       -- ���numClust��'direct'����k��������ľ������
%       -- ���numClust�������Զ�ȷ����������ķ�������k���������������
%       -- ��������㷨����Ҫָ�������������k�Ǹþ����㷨�ı������������DBSCAN��
% numClustAlgo: �����㷨����
%       -- kmeans
%       -- enclust
%       -- hclust
%       -- modeseek
%       -- kcenters
%       -- fcm
%       -- dbscan
% OCCAlgo: ��������������ʽ����ʹ��ֱ�ӵ��õĸ�ʽ
% combineRule: ���������ļ��ɷ���
%       -- mergec ��󻯾��߽߱缯��

function out = RSCH_OCL_ESM_ClustFramework(varargin)
argin = setdefaults(varargin,[],'direct',3,'kmeans','svdd',maxc);
if mapping_task(argin,'definition')
	out = define_mapping(argin,'untrained',['MLAlgo_Ensemble_' int2str(argin{2})]);
elseif mapping_task(argin,'training')
    [a ,numClust,k ,nameClustAlgo,OCCAlgo,combineRule] = deal(argin{:});
    % ������ȡ������������ѵ��
    a_origin = a;
    a = target_class(a);
    % �������������ľ�����󣨾����㷨��Ҫ��
    disM = sqrt(distm(a));
        
    % ȷ���������
    if strcmp(numClust,'direct')
         % ֱ��ʹ�ò���k
    elseif strcmp(numClust, 'entropy')
        [k,Idx] = selectKbyEntropy(a, disM, 'kcentres',k);
    elseif strcmp(numClust,'DBCV')
        [centers, Idx,k,tree,path,fdata,apts,dmreach] = selectKbyDBCV(a, disM, 'kcentres',k);
    end
    
    % ���þ����㷨,�������������k����������ȫ������Ĭ��ֵ���滻��λ
    if strcmp(numClust, 'direct')
        switch nameClustAlgo
            case 'kmeans'
                Idx = feval(nameClustAlgo,a,k);
            case 'emclust'
                Idx = feval(nameClustAlgo,a,[],k,[]);
            case 'hclust'            
                Idx = feval(nameClustAlgo,disM,'complete',k);
            case 'modeseek'
                Idx = feval(nameClustAlgo,disM,k);
            case 'kcentres'
                Idx = feval(nameClustAlgo,disM,k);
            case 'fcm'
                [center,U,obj_fcn] = fcm(a.data,k);
                maxU = max(U);
                Idx = zeros(length(a.data),1);
                for i = 1:k  
                    Idx(find(U(i,:) == maxU)) = i;
                end 
            case 'dbscan'
                [Idx,type]=dbscan(a.data,k,[]) ;
                k = max(unique(Idx));
        end
    end
    
    if strcmp(OCCAlgo, 'mst')
        mstdata.center = centers;
        mstdata.tree = tree;
        mstdata.path = path;
        mstdata.fdata = fdata; 
        mstdata.apts = apts;
        mstdata.dmreach = dmreach; 
        mstdata.Idx = Idx;
    else
    % ��ÿһ����������ɵ������ģ��
        subW = cell(1,k);
        for i = 1:1:k
            thisClusterIdx = find(Idx==i);
            A = seldat(a, [],[], thisClusterIdx);
            subW{i}= eval(OCCAlgo);
        end
        data.subW = subW;
    end
    
    % ����trained��prmapping
    data.Idx = Idx;
    
    data.k = k;
    data.OCCAlgo = OCCAlgo;
    data.mst = mstdata;
    data.combineRule = combineRule;
    out = trained_classifier(a_origin, data);
    
% ���Բ���
elseif mapping_task(argin,'execution')
    [a,v] = deal(argin{1:2}); 
    a = prdataset(a);
	mapping = getdata(v);
    
    if strcmp(mapping.OCCAlgo,'mst')
        dist =  pdist2(a.data,mapping.mst.center,'Euclidean');
        [mmin,Idx] = min(dist,[],2);
        for i = 1:a.objsize
            dist = [];
            dist = pdist2(mapping.mst.fdata{Idx(i)},a.data(i,:),'Euclidean');
            numerator = sum((1./dist(find(dist ~= 0))) .^ a.featsize);
            %���ӳ�ni-1���-1/d���ݡ�
            apts(i) = (numerator/length(mapping.mst.fdata{Idx(i)})) ^(-1/a.featsize);
            %aptsΪ���Լ���ÿ�����aptֵ��mapping.mst.aptsΪѵ�����е��aptֵ��
            for j = 1:length(mapping.mst.fdata{Idx(i)})
                d_reach{i}(j) = max([apts(i) mapping.mst.apts{Idx(i)}(j) dist(j)]);
            end
        end
        %d_reachΪ���Լ��е㵽�þ���ص�Ŀɴ���롣
        
        % �趨ÿһ������ص��ж���ֵ
        thr = zeros(1,mapping.k);
        for i = 1 : 1 : mapping.k
            mst_path = mapping.mst.path{i};
            thr(i) = max(max(mst_path)) * (1 - 0.1);
        end
        
        % ������ֵ�ж����Ե�Ĺ���
        result = zeros(a.objsize, 2);
        for i = 1 : 1 : a.objsize
            result(i,1) = min(d_reach{i}) - thr(Idx(i));
        end
        
        out = setdat(a,result,v);
    else
        w = mapping.subW;
        combineRule = mapping.combineRule;
        W_out = [w{:}] * combineRule;
        out = a * W_out;
    end
     
end
end
