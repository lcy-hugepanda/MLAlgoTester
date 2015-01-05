function [k, result] = selectKbyEntropy(a, disM, nameClustAlgo,k)
   for i = 2:k
     switch nameClustAlgo
        case 'kmeans'
            Idx{i} = feval(nameClustAlgo,a,i);
        case 'emclust'
            Idx{i} = feval(nameClustAlgo,a,[],i,[]);
        case 'hclust'            
            Idx{i} = feval(nameClustAlgo,disM,'complete',i);
        case 'modeseek'
            Idx{i} = feval(nameClustAlgo,disM,i);
        case 'kcentres'
            [Idx{i} center{i} DM{i}] = feval(nameClustAlgo,disM,i);
        case 'fcm'
            [center11,U,obj_fcn] = fcm(a.data,i);
            maxU = max(U);
            Idx{i} = zeros(length(a.data),1);
            for ii = 1:k  
                Idx{i}(find(U(ii,:) == maxU)) = ii;
            end 
        case 'dbscan'
            [Idx{i},type]=dbscan(a.data,i,[]) ;
            i = max(unique(Idx{i}));
     end
%========================================================
%      ���ݾ�����ڵ�ĸ�����������ֵ
%      for j = 1:i 
%         w(i,j) = length(find(Idx{i} == j));
%      end
%      E(i) = -sum(w(i,:).*log(w(i,:)));
%  end
% %=======================================================
%      ���ݵ㵽�������ľ��룬������ֵdisM.data��i,j��Ϊi��j�ɴ�������
%   ���ӣ�������i������c���ĵľ���
%   ��ĸ��������i�����о������ľ���֮��
      for j = 1:i
          temp = find(Idx{i} == j);%�ҵ�����ض�Ӧ�ĵ�
          for nn = 1:length(temp)
              if temp(nn) == center{i}(j)%����ص����ĵ�����
                   w{i,j}(nn) = 1;%���������ĵ��Ȩֵ��Ϊ1������ֹ������logʱ����log(0)����
              else
                %������ӣ���ĸ�������
                w{i,j}(nn) = disM.data(center{i}(j),temp(nn))/sum(disM.data(temp(nn),center{i}));
              end
          end
          %����j���Eֵ
          E_temp(j) = sum(w{i,j}.*log(w{i,j}));%w(i,j)��ž�i�࣬��j���Ȩֵ��
      end
      %������i��������ֵ���
      E(i) = sum(E_temp);
   end
%=======================================================
%      �����仭������ͼ
   x = zeros(1,k);
   for i = 1:k
       x(i) = i;
   end
   figure;
   plot(x(1,2:end),E(1,2:end),'r.-');
%=======================================================
%      �����С��ֵ����������Ӧ�ľ������k��
    
   [maxE,k] = min(E);
   result = Idx{k};
   
end
