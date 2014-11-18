 a = gendatb([100 100]);
 a = oc_set(a,'1');
 scatterd(a);
 w = cell(1,7);
 %w1 = ensemble_classification(a,3,'kmeans','gauss_dd','occ_wvotec');
%  w{2} = ensemble_classification(a,3,'kmeans','gauss_dd','occ_fvotec');
%  w{3} = ensemble_classification(a,3,'kmeans','gauss_dd','occ_prodfvotec');
 w{4} = ensemble_classification(a,3,'kmeans','gauss_dd','votec');
 w{5} = ensemble_classification(a,3,'kmeans','gauss_dd','occ_excvotec');
 w{6} = ensemble_classification(a,3,'kmeans','gauss_dd','meanc');
 w{7} = ensemble_classification(a,3,'kmeans','gauss_dd','occ_prodc');
 for i=4:7
      testc(a,w{i});

 end
 plotc(w{4},'r');
 plotc(w{5},'g');
 plotc(w{6},'b');
 plotc(w{7},'p');
%  testc(a,w1);
%   scatterd(a);
%   plotc(w);
% weight = [0.1,0.1,0.8];
% occ_wvotec(w,weight);