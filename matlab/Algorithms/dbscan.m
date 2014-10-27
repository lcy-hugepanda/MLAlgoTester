% Output:  
% class - vector specifying assignment of the i-th object to certain  
% cluster (m,1) 
% type - vector specifying type of the i-th object  
% (core: 1, border: 0, outlier: -1) 
function [class,type,clusteridx]=dbscan(x,k,Eps) 
x=zscore(x);
[m,~]=size(x);  
if nargin<3||isempty(Eps) 
    [Eps]=epsilon(x,k); 
end  
x=[(1:m)',x]; 
[m,n]=size(x); 
type=zeros(1,m); 
no=1; 
touched=zeros(m,1);  
for i=1:m 
    if touched(i)==0;        
        ob=x(i,:); 
        D=dist(ob(2:n),x(:,2:n));       
        ind=find(D<=Eps);      
       if length(ind)>1 && length(ind)<k+1                  
           type(i)=0;           
           class(i)=0;        
       end 
       if length(ind)==1           
           type(i)=-1;           
           class(i)=-1;             
           touched(i)=1;        
       end  
       if length(ind)>=k+1;            
           type(i)=1; 
          class(ind)=ones(length(ind),1)*max(no);            
          while ~isempty(ind)                 
              ob=x(ind(1),:);                 
              touched(ind(1))=1;                 
              ind(1)=[]; 
              D=dist(ob(2:n),x(:,2:n));                 
              i1=find(D<=Eps);       
                if length(i1)>1                    
                    class(i1)=no; 
                   if length(i1)>=k+1;                       
                       type(ob(1))=1;                    
                   else 
                      type(ob(1))=0;                    
                   end  
                   for k1=1:length(i1) 
                       if touched(i1(k1))==0                           
                           touched(i1(k1))=1;                           
                           ind=[ind,i1(k1)];                              
                           class(i1(k1))=no; 
                       end
                   end
                end
          end
          no=no+1;         
       end
    end
end
i1=find(class==0); 
class(i1)=-1; 
type(i1)=-1; 
maxlab=max(class);
clusteridx=[]; 
clun=[]; 
for ck=1:maxlab 
    tidx=find(class==ck);  
    clusteridx=[clusteridx;
    [tidx,zeros(1,m-length(tidx))]];     
    clun=[clun,length(tidx)]; 
end 
disp(clun); 
end
function [Eps]=epsilon(x,k)  
% Function: [Eps]=epsilon(x,k) % 
% Aim:  
% Analytical way of estimating neighborhood radius for DBSCAN % 
% Input:  
% x - data matrix (m,n); m-objects, n-variables 
% k - number of objects in a neighborhood of an object % (minimal number of objects considered as a cluster)    
[m,n]=size(x);  
Eps=((prod(max(x)-min(x))*k*gamma(.5*n+1))/(m*sqrt(pi.^n))).^(1/n); 
disp('EPS:'); 
disp(Eps);   
end
 function [D]=dist(i,x)  
% function: [D]=dist(i,x) % 
% Aim:  
% Calculates the Euclidean distances between the i-th object and all objects in x   %             % Input:  
% i - an object (1,n) 
% x - data matrix (m,n); m-objects, n-variables      
%                                                                  % Output:  
% D - Euclidean distance (m,1) 
[m,n]=size(x); 
D=sqrt(sum((((ones(m,1)*i)-x).^2)'));
if n==1 
   D=abs((ones(m,1)*i-x))'; 
end 
 end
%******************************************************** 