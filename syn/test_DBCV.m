% prload('Wine recognition data_cultivar 1.mat');
% a = x;
a = mydataset(1);
a = target_class(a,1);
scatterd(a);
%mst_dd(a);
for i =2:6
index = kmeans(a,i);
out(1,i) = MLAT_DBCV(a,index);  
end                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            