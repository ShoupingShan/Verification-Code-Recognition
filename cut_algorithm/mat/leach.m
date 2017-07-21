function img=leach(bw)
%广度优先搜索去除噪点
[m, n]=size(bw);
area=0;queue=zeros(m*n,2);
seen=zeros(m,n);
m_area=zeros(50,1);
for i=1:m
    for j=1:n
        if bw(i,j)==0&&seen(i,j)==0
            area=area+1;
            queue(1,:)=[i,j];
            front=1;tail=2;
            seen(i,j)=area;
            while front<tail
                x=queue(front,1);
                y=queue(front,2);
                seen(x,y)=area;
                m_area(area)= m_area(area)+1;
                front=front+1;
                if x+1<=m&&seen(x+1,y)==0&&bw(x+1,y)==0
                    queue(tail,:)=[x+1 ,y];
                    tail=tail+1;seen(x+1,y)=-1;
                end
                if x-1>=1&&seen(x-1,y)==0&&bw(x-1,y)==0
                    queue(tail,:)=[x-1 ,y];
                    tail=tail+1;seen(x-1,y)=-1;
                end
                if y+1<=n&&seen(x,y+1)==0&&bw(x,y+1)==0
                    queue(tail,:)=[x ,y+1];
                    tail=tail+1;seen(x,y+1)=-1;
                end
                if y-1>=1&&seen(x,y-1)==0&&bw(x,y-1)==0
                    queue(tail,:)=[x ,y-1];
                    tail=tail+1;seen(x,y-1)=-1;
                end
            end
        end
    end
end
s=find(m_area>0&m_area<=13);
img=bw;
for k=1:length(s)
    for i=1:m
    for j=1:n
    if(seen(i,j)==s(k))
        img(i,j)=1;
    end
    end
    end
end
