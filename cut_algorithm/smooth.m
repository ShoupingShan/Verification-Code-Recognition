function y=pinghua(s)
[m,n]=size(s);
if m==1
    s=s';
else
    n=m;
end
% y=floor(([s(2:n);0]+s+[0;s(1:n-1)])/3);
y=floor(([s(2:n);0]+[s(3:n); 0 ;0]+s+[0;0;s(1:n-2)]+[0;s(1:n-1)])/5);
