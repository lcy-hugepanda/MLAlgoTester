a = mydataset(1);
a = target_class(a,1);
scatterd(a);
for i =2:6
index = kmeans(a,i);
out(i) = MLAT_DBCV(a,index);  
end