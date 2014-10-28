% ���ݸ�������ͼ����num _p
% �Զ��滮����ͼ������m��n��ͬʱ������ͼλ�ò���pos
function [m,n,pos] = MLAT_PlanSubplot(num_p)
    if num_p < 2  % ��ͼ����1
        m  = 1;
        n = 1;
    elseif num_p < 4 %  ��ͼ����2,3  ����Ϊһ�м���
        m = 1;
        n = num_p;
    elseif num_p < 9 % ��ͼ����4,5,6,7,8  ����
        m = 2;
        n = ceil(num_p / 2);
    elseif num_p < 13 % ��ͼ����9,10,11, 12  ����
        m = 3;
        n = ceil(num_p / 3);
    elseif num_p == 24
        m = 5;
        n = 5;
    end
    
        pos = PlotCalculateSubplotPos(m, n);
end

function position = PlotCalculateSubplotPos(row,col,axis)
%%%%%%%%%%%%% position = spp(row,col,axis)
%%%%%%%%%%%%%
    if ~exist('axis','var') | isempty(axis)
        axis = [0.07,0.07,1,1];
    end

    if(nargin==1) % case one , just number
        nplots = length(row);
        row = floor(sqrt(nplots));
        col = ceil(nplots/row);
    end
    
        axis(3) = axis(1)+axis(3);
        axis(4) = axis(2)+axis(4);
        
        rowid = linspace(axis(4),axis(2),row+1); 
        rowid = rowid(2:end);
        
        colid = linspace(axis(1),axis(3),col+1); 
        colid = colid(1:end-1);
        
        [posy, posx] = meshgrid(rowid, colid);
        posx = posx(:); 
        posy = posy(:);
        
        width = range(axis([1,3]))/col * 0.7;
        height = range(axis([2,4]))/row* 0.7;
        
    for i = 1: numel(posx)
        position(i,:) = [posx(i),posy(i),width,height];
    end
    
end 