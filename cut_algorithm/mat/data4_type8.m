%ͼ��Ԥ����
%��������ļ�·��
%�Ҷ�ֱ��ͼȥ����
%����ɨ��ȥ�����ߺ͹������
%��ʴ����
clc;clear;close all;
flag=1;                 %���Կ���1��ʾ����״̬��0��ʾ������״̬
low=0.7;up=0.18;bound=4; %bound�����жϹ�����
ns=4;  %�ַ���
road='C:\Users\shp\Desktop\CAPTCHA\4nngn1\';
name=textread('C:\Users\shp\Desktop\CAPTCHA\4nngn1\name.txt','%s'); %#ok<DTXTRD>

allsum=length(name);
cnt=1;
if(flag==1)
    allsum=cnt;
end
while cnt<=allsum
dirname=name{cnt};
dirname=dirname(39:length(dirname));
a=imread([road,dirname]);
subplot(3,2,1);
imshow(a),title(dirname(1:length(dirname)-4));
cnt=cnt+1;
disp(cnt)
if length(size(a))==3
a_gray=rgb2gray(a);
else
    a_gray=a;
end
[m,n]=size(a_gray);

% %��ɫ����
% im=zeros(m*n,3);
% k=1;
% for i=1:m
%     for j=1:n
%         im(k,:)=[a(i,j,1) a(i,j,2) a(i,j,3)];
%         k=k+1;
%     end
% end
% [idx C]=kmeans(im,5);
% for i=1:m
%     for j=1:n
%         for k=1:3
%             a(i,j,k)=C(idx((i-1)*n+j),k);
%         end
%     end
% end
% imshow(a);

%------���ݻҶ�ֵ���ִ������˵�����-------%

a_hist=imhist(a_gray);
l=length(a_hist);
a_cum=floor(([a_hist(2:l); 0]+[a_hist(3:l); 0 ;0]+a_hist+[0;0;a_hist(1:l-2)]+[0;a_hist(1:l-1)]));
if (flag==1)
   subplot(3,2,3);
imshow(a_gray),title('�Ҷ�ͼ');
  subplot(3,2,2);
bar(a_cum),title('ǰ���ͱ���');
end
%----------ȷ��ֱ��ͼ��ֵ
valley=zeros(1,10);
is_filter=ones(1,256);
valley(1)=1;
k=2;
for i=3:l-2
    if a_cum(i)<=8
    if a_cum(i)<=1&&((a_cum(i-1)>a_cum(i)&&a_cum(i-2)>=a_cum(i-1))||(a_cum(i+1)>a_cum(i)&&a_cum(i+2)>=a_cum(i+1)))
        valley(k)=i;
        k=k+1;
    end
    end
end
valley(k)=256;

% ---------����2����ֵ����
bw=graythresh(a_gray);
a_bw=im2bw(a_gray,bw);
% a_bw=im2bw(a_gray,0.5);

% for i=1:k-1
%     for j=i+1:k
%         percent=sum(a_hist(valley(i):valley(j)))/(m*n);
%         if percent>low&&percent<up
%             for x=1:m
%                 for y=1:n
%                     if a_gray(x,y)>=valley(i)&&a_gray(x,y)<=valley(j)
%                         a_bw(x,y)=0;
%                     else
%                         a_bw(x,y)=1;
%                     end
%                 end
%             end
%             break;
%         end
%     end
%     if percent>low&&percent<up
%          break;
%     end
% end
if (flag==1)
subplot(3,2,4);
imshow(a_bw),title('��ֵͼ');
end
%-------------ȥ�����������-----------------%
a_bw2=[ones(1,n+2);ones(m,1) a_bw ones(m,1);ones(1,n+2)];
for i=2:m+1
    for j=2:n+1
     if a_bw2(i,j)==0
         s=length(find(a_bw2(i-1:i+1,j-1:j+1)==0));
         if s<=bound    %����3*3������0����С��һ������ֵ(���һ������)��������ɫ��Ϊ1
              a_bw2(i,j)=1;
         end
     end
    end
end
a_bw=a_bw2(2:m+1,2:n+1);
if (flag==1)
    subplot(3,2,5);
   imshow(a_bw),title('ȥ��������');
end
%----------��ͨ����ȥ����------------------%
a_bw=leach(a_bw);

ceshi=a_bw;
%--------------����ͶӰ--------------------%
hor=m-sum(a_bw);
ph_hor=pinghua(hor);
if (flag==1)
     subplot(3,2,6);
bar( hor),title('�Ҷ�ֱ��ͼ');%����ֱͶӰֱ��ͼ
end
%--------------------------ͼ��ָ�----------------------------%
%���������ʼλ��
%Ѱ�����ұ߽�
left=1;
right=n;
for j=1:n
    if ph_hor(j)>0
        left=j;
        break;
    end
end
for j=n:-1:1
    if ph_hor(j)>0
        right=j;
        break;
    end
end

segp=zeros(ns-1,1);%�����и�����λ������
path=n*ones(m,ns-1);
%-------�͹��㷨
i=left+4;
k=1;


while i<right
%     if ph_hor(i)<=3&&(ph_hor(i-1)>=4||ph_hor(i-2)>=4)  %�½���
%             init=ph_hor(i);
%             if k<=ns-1
%                 segp(k)=i;
%                 k=k+1;
%             end
%             while i<right&&abs(ph_hor(i)-init)<=1     %������
%                 i=i+1;
%             end
            if hor(i)<3&&(hor(i-1)>=4||hor(i-2)>=4)  %�½���
            init=hor(i);
            if k<=ns-1
                segp(k)=i;
                k=k+1;
            end
            while i<right&&abs(hor(i)-init)<=1     %������
                i=i+1;
            end;
%     elseif ph_hor(i)>2&&ph_hor(i)<10&&(sum(ph_hor(i-3:i-1))>5*ph_hor(i)) 
%         init=ph_hor(i);
%             if k<=ns-1
%                 segp(k)=i;
%                 k=k+1;
%             end
%             while i<right&&abs(ph_hor(i)-init)<=1
%                 i=i+1;
%             end
            end;
    i=i+1;
end
% %-------------����һ�����
% i=max(left+1,3);
% k=1;
% while i<right
%     if hor(i)<=1&&(hor(i-1)>1||hor(i-2)>1)
%             if k<=ns-1
%                 segp(k)=i;
%                 k=k+1;
%             end
%             while i<right&&hor(i)<=1
%                 i=i+1;
%             end
%     end
%     i=i+1;
% end

%-------------������
% for i=1:3
%     bas=floor((right-left)*i/4+left);
%     le=bas-floor(n/12);
%     ri=bas+floor(n/12);
%     f=find(hor(le:ri)==0);
%     if f
%         path(:,i)=(le+f(end)-1)*ones(m,1); %��ֱ��ͼ������㣬��ֱ�ӷָ�
%          segp(i)=le+f(end)-1;
%     else
%         for j=le:ri
%             ave1=sum(hor(j-2:j));
%             ave2=sum(hor(j-1:j+1));
%             if abs(ave1-ave2)>=10   %�ɵ�����
%                 segp(i)=j;%������㣬���ҵ���ͻ��ĵط���ʼ��ˮ�㷨
%             end    
%         end
%     end
%         
% end

%ִ�е�ˮ�㷨

lastx=0;
lasty=0;
deltax=[1;1;1;0;0];deltay=[0;1;-1;1;-1];
for s=1:ns-1
    if segp(s)~=0
    j=segp(s);
    i=1;
    lastx=i;
    lasty=j;
    while(i<m)%����ǰ��ﵽͼ��ײ�ʱ����
        W=0;
        ww=zeros(5,1);
        for k=1:5
            if j+deltay(k)>n
                j=j-1;
            end
            if j+deltay(k)<1
                j=j+1;
            end
            ww(k)=a_bw(i+deltax(k),j+deltay(k))*(6-k);
        end
        W=max(ww);
        if W==0
            if rand<0.8
                W=5;
            else
                W=4;
            end
        end
        if W==1
           if lasty<j
               W=2;
           end
        end
        if W==2
           if lasty>j
               W=1;
           end
        end
        lastx=i;
        lasty=j;
        i=i+deltax(6-W);
        j=j+deltay(6-W);
        path(i,s)=min(path(i,s),j);
    end
    path(m,s)=path(m-1,s);
    end
end
%�õ���ns-1���ָ�·�����ָ���������֤��
bw=zeros(m,n,ns);

for i=1:ns
    bw(:,:,i)=a_bw;
end
for k=1:ns
    if k==1
        for i=1:m
         bw(i,path(i,k)+1:n,k)=1;
        end
    elseif k==ns
        for i=1:m
            bw(i,1:path(i,k-1),k)=1;
        end
    else
        for i=1:m
            bw(i,1:path(i,k-1),k)=1;
            bw(i,path(i,k)+1:n,k)=1;
        end
    end
end
if (flag==1)
    figure(2);
    for k=1:ns
        subplot(2,3,k);imshow(bw(:,:,k));
    end
end


%---------ȥ���հ�
if flag==1  
figure(3);
end
for k=1:ns
    rowsum=sum(bw(:,:,k)');
    colsum=sum(bw(:,:,k));
    le=1;
    ri=n;
    up=1;
    do=m;
    for i=1:m-1
        if rowsum(i)==n&&rowsum(i+1)<n
            up=i;
            break;
        end
    end
    for i=m:-1:2
        if rowsum(i)==n&&rowsum(i-1)<n
            do=i;
            break;
        end
    end
    for j=1:n-1
        if colsum(j)==m&&colsum(j+1)<m
            le=j;
            break;
        end
     end
    for j=n:-1:2
        if colsum(j)==m&&colsum(j-1)<m
            ri=j;
            break;
        end
    end
    img=bw(up+1:do-1,le+1:ri-1,k);
    img2=imresize(img,[16 16]);
    if flag==1  
         subplot(2,3,k);imshow(img2);
    end
    liwai=['c','i','j','k','o','p','s','u','v','w','x','z'];  %һЩ���״�ֵ���ĸ�������⴦��
    f=find(liwai==dirname(k));
    lenf=length(f);
    if lenf~=0&&dirname(k)>='a'&&dirname(k)<='z'
        writeroad=['C:\Users\shp\Desktop\�����\samples\',upper(dirname(k)),'\'];
    elseif dirname(k)>='a'&&dirname(k)<='z'
        writeroad=['C:\Users\shp\Desktop\�����\samples\',dirname(k),'1\'];
    else
        writeroad=['C:\Users\shp\Desktop\�����\samples\',dirname(k),'\'];
    end
    hxx=[num2str((cnt-1)*ns+k+2000),'.jpg'];   %�����2000��Ϊ�˱����֮ǰ�ļ������ĳ�ͻ
    %�ж��Ƿ��д�ɫ����
    issave=1;
    img2=im2bw(img2);
    write=0;black=0;
    for i=1:16
        for j=1:16
            if img2(i,j)==1
                write=write+1;
            elseif img2(i,j)==0
                black=black+1;
            end;
        end;
    end;
    if write>16*16*0.90||black>16*16*0.90
        issave=0;
    end;
    
    if ~flag&&issave
    imwrite(img2,[writeroad,hxx]);
    end;
end
end
