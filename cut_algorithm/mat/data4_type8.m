%图像预处理
%获得输入文件路径
%灰度直方图去背景
%区域扫描去干扰线和孤立噪点
%腐蚀处理
clc;clear;close all;
flag=1;                 %调试开关1表示调试状态，0表示批处理状态
low=0.7;up=0.18;bound=4; %bound用于判断孤立点
ns=4;  %字符数
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

% %颜色聚类
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

%------根据灰度值出现次数过滤掉噪声-------%

a_hist=imhist(a_gray);
l=length(a_hist);
a_cum=floor(([a_hist(2:l); 0]+[a_hist(3:l); 0 ;0]+a_hist+[0;0;a_hist(1:l-2)]+[0;a_hist(1:l-1)]));
if (flag==1)
   subplot(3,2,3);
imshow(a_gray),title('灰度图');
  subplot(3,2,2);
bar(a_cum),title('前景和背景');
end
%----------确定直方图谷值
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

% ---------方法2单阈值处理
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
imshow(a_bw),title('二值图');
end
%-------------去除残余干扰线-----------------%
a_bw2=[ones(1,n+2);ones(m,1) a_bw ones(m,1);ones(1,n+2)];
for i=2:m+1
    for j=2:n+1
     if a_bw2(i,j)==0
         s=length(find(a_bw2(i-1:i+1,j-1:j+1)==0));
         if s<=bound    %若此3*3方格中0个数小于一定的阈值(需进一步调整)，将其颜色设为1
              a_bw2(i,j)=1;
         end
     end
    end
end
a_bw=a_bw2(2:m+1,2:n+1);
if (flag==1)
    subplot(3,2,5);
   imshow(a_bw),title('去除干扰线');
end
%----------连通分量去区域------------------%
a_bw=leach(a_bw);

ceshi=a_bw;
%--------------按列投影--------------------%
hor=m-sum(a_bw);
ph_hor=pinghua(hor);
if (flag==1)
     subplot(3,2,6);
bar( hor),title('灰度直方图');%做竖直投影直方图
end
%--------------------------图像分割----------------------------%
%计算可能起始位置
%寻找左右边界
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

segp=zeros(ns-1,1);%所有切割起点的位置向量
path=n*ones(m,ns-1);
%-------低谷算法
i=left+4;
k=1;


while i<right
%     if ph_hor(i)<=3&&(ph_hor(i-1)>=4||ph_hor(i-2)>=4)  %下降沿
%             init=ph_hor(i);
%             if k<=ns-1
%                 segp(k)=i;
%                 k=k+1;
%             end
%             while i<right&&abs(ph_hor(i)-init)<=1     %上升沿
%                 i=i+1;
%             end
            if hor(i)<3&&(hor(i-1)>=4||hor(i-2)>=4)  %下降沿
            init=hor(i);
            if k<=ns-1
                segp(k)=i;
                k=k+1;
            end
            while i<right&&abs(hor(i)-init)<=1     %上升沿
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
% %-------------方法一简单情况
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

%-------------方法二
% for i=1:3
%     bas=floor((right-left)*i/4+left);
%     le=bas-floor(n/12);
%     ri=bas+floor(n/12);
%     f=find(hor(le:ri)==0);
%     if f
%         path(:,i)=(le+f(end)-1)*ones(m,1); %若直方图中有零点，可直接分割
%          segp(i)=le+f(end)-1;
%     else
%         for j=le:ri
%             ave1=sum(hor(j-2:j));
%             ave2=sum(hor(j-1:j+1));
%             if abs(ave1-ave2)>=10   %可调参数
%                 segp(i)=j;%若无零点，则找到有突变的地方开始滴水算法
%             end    
%         end
%     end
%         
% end

%执行滴水算法

lastx=0;
lasty=0;
deltax=[1;1;1;0;0];deltay=[0;1;-1;1;-1];
for s=1:ns-1
    if segp(s)~=0
    j=segp(s);
    i=1;
    lastx=i;
    lasty=j;
    while(i<m)%当当前点达到图像底部时结束
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
%得到了ns-1条分割路径，分隔出单个验证码
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


%---------去除空白
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
    liwai=['c','i','j','k','o','p','s','u','v','w','x','z'];  %一些容易错分的字母进行特殊处理
    f=find(liwai==dirname(k));
    lenf=length(f);
    if lenf~=0&&dirname(k)>='a'&&dirname(k)<='z'
        writeroad=['C:\Users\shp\Desktop\程序包\samples\',upper(dirname(k)),'\'];
    elseif dirname(k)>='a'&&dirname(k)<='z'
        writeroad=['C:\Users\shp\Desktop\程序包\samples\',dirname(k),'1\'];
    else
        writeroad=['C:\Users\shp\Desktop\程序包\samples\',dirname(k),'\'];
    end
    hxx=[num2str((cnt-1)*ns+k+2000),'.jpg'];   %这里的2000是为了避免和之前文件命名的冲突
    %判断是否有纯色现象
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
