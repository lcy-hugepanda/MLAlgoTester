B = gauss(20,[10,10]);
C = gauss(20,[50,50])
outlier(1,1)= 10;
outlier(1,2) =50;
outlier(2,1)= 30;
outlier(2,2) =30;

DATA = [B.data;C.data; outlier];
LABS = [getnlab(B); getnlab(C);0;0];
x = prdataset(DATA,LABS);
x = set(x,'prior',[0.024,0.976],'name','combingset','featlab',['0';'1']);

