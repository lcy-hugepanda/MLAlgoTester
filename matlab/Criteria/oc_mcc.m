function mcc = oc_mcc(A,W)
    [fn, fp, tn, tp] = dd_error_modify(A,W);
    mcc = (tp * tn - fp * fn)/sqrt((tp+fp)*(tp+fn)*(tn+fp)*(tn+fn))
end

% 实际使用的是dd_tools里面的dd_error函数
% 但是修改了返回值，fn fp tn tp都是具体的数值（而不是百分数）
function [fn, fp, tn, tp] = dd_error_modify(x,w)
%DD_ERROR compute false negative and false positive rate for oc_classifier
%
%   E = DD_ERROR(X,W)
%   E = DD_ERROR(X*W)
%   E = X*W*DD_ERROR
%
% Compute the fraction of target objects rejected and the fraction of outliers
% accepted:
%    E(1) = target rejected     (false negative)
%    E(2) = outlier accepted    (false positive)
% for dataset X on the trained mapping W.
%
%   [E,F,G] = DD_ERROR(X,W)
%
% When two or three outputs are requested, the second output F will contain:
%    F(1) = precision
%    F(2) = recall
% and the third output contains:
%    G(1) = hit rate
%    G(2) = false alarm rate
%
% See also: dd_roc, gendatoc, plotroc

% Copyright: D.M.J. Tax, D.M.J.Tax@prtools.org
% Faculty EWI, Delft University of Technology
% P.O. Box 5031, 2600 GA Delft, The Netherlands

% Do it the same as testc:
% When no input arguments are given, we just return an empty mapping:
    fn = 1;
    fp = 1;
    tn = 1;
    tp = 1;
    
    x = x * w;
	% Now we are doing the actual work:

	% true target labels
	[nin,llin] = getnlab(x);
	Ittrue = strmatch('target',llin);
	if isempty(Ittrue), Ittrue = -1; end
	Ittrue = find(nin==Ittrue);
	% true outlier labels
	Iotrue = strmatch('outlier',llin);
	if isempty(Iotrue), Iotrue = -1; end
	Iotrue = find(nin==Iotrue);

	% classification labels:
	% (this is too slow:)
	%lout = labeld(x);
	%[nout,llout] = renumlab(lout);
    llout = getfeatlab(x);
	%[~,llout] = getnlab(x);
	[mx,nout] = max(+x,[],2);
	% objects labeled target:
	It = strmatch('target',llout);
	if isempty(It), It = -1; end
	It = (nout==It);
	% objects labeled outlier:
	Io = strmatch('outlier',llout);
	if isempty(Io), Io = -1; end
	Io = (nout==Io);

	% Finally the error:
	% Warning can be off, because we like to have NaN's when one of the
	% classes is empty:
    warning off MATLAB:divideByZero;
	fn = sum(It(Ittrue)==0);
	fp = sum(Io(Iotrue)==0);
    tp = sum(It(Ittrue)==1);
    tn = sum(Io(Iotrue)==1);
    warning on MATLAB:divideByZero;
	
	% compute the precision and recall when it is requested:
	if (nargout>1)
		warning off MATLAB:divideByZero;
        f(1) = sum(It(Ittrue)==1)/sum(It);
		f(2) = sum(It(Ittrue)==1)/length(Ittrue);
		warning on MATLAB:divideByZero;
	end

   % compute the hit rate and false alarm rate when it is requested
   if (nargout>2)
		warning off MATLAB:divideByZero;
      g(1) = sum(It(Ittrue)==1)/length(Ittrue);
      g(2) = sum(It(Iotrue)==1)/sum(It);
		warning on MATLAB:divideByZero;
   end

return
    
end
    
    
