function [Wt,Pp]=mintree(n,W)
tmpa=find(W~=inf);
[tmpb,tmpc]=find(W~=inf);
w=W(tmpa);
e=[tmpb,tmpc];
[wa,wb]=sort(w);
E=[e(wb,:),wa,wb];
[nE,mE]=size(E);
temp=find(E(:,1)-E(:,2));
E=E(temp,:);
P=E(1,:);
k=length(E(:,1));
while rank(E)>0
    temp1=max(E(1,2),E(1,1));
    temp2=min(E(1,2),E(1,1));
    for i=1:k
        if E(i,1)==temp1
            E(i,1)=temp2;
        end
        if E(i,2)==temp1
            E(i,2)=temp2;
        end
    end
    a=find(E(:,1)-E(:,2));
    E=E(a,:);
    if rank(E)>0
        P=[P;E(1,:)];
        k=length(E(:,1));
    end
end
Wt=sum(P(:,3));
Pp=[e(P(:,4),:),P(:,3:4)];
% for i=1:length(P(:,3))
%     disp(['','e',num2str(P(i,4)),'',...
%         '(v',num2str(P(i,1)),'','v',num2str(P(i,2)),')']);
% end
% axis equal;%画最小生成树   
% hold on
% [x,y]=cylinder(1,n);
% xm=min(x(1,:));
% ym=min(y(1,:));
% xx=max(x(1,:));
% yy=max(y(1,:));
% axis([xm-abs(xm)*0.15,xx+abs(xx)*0.15,ym-abs(ym)*0.15,yy+abs(yy)*0.15]);
% plot(x(1,:),y(1,:),'ko');
% for i=1:n
%     temp=['v',int2str(i)];
%     text(x(1,i),y(1,i),temp);
% end
% for i=1:nE
%     plot(x(1,e(i,:)),y(1,e(i,:)),'b');
% end
% for i=1:length(P(:,4))
%     plot(x(1,Pp(i,1:2)),y(1,Pp(i,1:2)),'r');
% end
% text(-0.35,-1.2,['最小生成树的权为','',num2str(Wt)]);
% title('红色连线为最小生成树');
% axis off;
% hold off;
end
