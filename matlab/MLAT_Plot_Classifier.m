function  MLAT_Plot(a,w)

    %output = scatterd(A);
    %hold;
    %plotc(w);
    b = 1;
    c = 1;
    for i = 1:1:length(a)
        if a.nlab(i,1) == 1
            x1(b,1) = a.data(i,1);
            y1(b,1) = a.data(i,2);
            b = b+1;
        else
            x2(c,1) = a.data(i,1);
            y2(c,1) = a.data(i,2);
            c = c + 1;
        end
    end

     plot(x1,y1,'r+');
     hold on;
     plot(x2,y2,'b*');
 
    hold on;
    plotc(w);


end

