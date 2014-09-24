x = target_class(gendatb([50 0]),'1')
w = svdd(x,0.1,7)
z = oc_set(gendatb(200),'1')
e = dd_roc(z,w)
plotroc(e);