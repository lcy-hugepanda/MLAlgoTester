a = gendatb([10 10]);
index = kmeans(a,2);
out = MLAT_DBCV(a,index); 