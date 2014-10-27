% 根据给出的子图个数num _p
% 自动规划出子图行列数m和n，同时给出子图位置参数pos
function [m,n,pos] = MLAT_PlanSubplot(num_p)
    if num_p < 2  % 子图数：1
        m  = 1;
        n = 1;
    elseif num_p < 4 %  子图数：2,3  排列为一行即可
        m = 1;
        n = num_p;
    elseif num_p < 9 % 子图数：4,5,6,7,8  两行
        m = 2;
        n = ceil(num_p / 2);
    elseif num_p < 13 % 子图数：9,10,11, 12  三行
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