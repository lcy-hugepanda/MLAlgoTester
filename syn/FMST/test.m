    j = 1
for i = 100:100:1000

a = gendatb([i i]);
tic;
[MST,tree]= FMST(a);
disp(['FMST运行时间：',num2str(toc)]); 
time(j,1) = toc;
tic;
[tree2,path] = mst(squareform( pdist(a.data, 'euclidean')));
disp(['mst次循环运行时间：',num2str(toc)]); 
time(j,2) = toc;
j = j+1;
end
x = [100 200 300 400 500 600 700 800 900 1000];
plot(x,time(:,1))
hold on;
plot(x,time(:,2),'r')