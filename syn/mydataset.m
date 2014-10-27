% when k = 1 ,the output is combination dataset of three gauss distribution.
function out = mydataset(k)
if k == 1
    x1 = gauss(100,[10 1]);
    x2 = gauss(100,[0 1]);
    x3 = gauss(100,[5 1]);
    r1(:,1) = 10.*rand(20,1);
    r1(:,2) = 4+2.*rand(20,1);
    flag = ones(20,1)*2;
    r2(:,1) = 10.*rand(20,1);
    r2(:,2) = -4+2.*rand(20,1);
    x = prdataset([x1.data;x2.data;x3.data;r1;r2],[x1.nlab;x2.nlab;x3.nlab;flag;flag]);
    out =  x;
end
end