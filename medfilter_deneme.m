figure;
hold on;
for i= 1:9
    subplot(3,3,i);
    imshow( medfilt2(diff_im1, [i i]) );
    title(sprintf('[%d %d] filtreli', i ,i));
    
end

hold off;


figure;
hold on;

for i= 1:9
    subplot(3,3,i);
    imshow( im2bw(medfilt2(diff_im1, [i i]) , 0.18 ));
    title(sprintf('[%d %d] filtreli', i ,i));
    
end

hold off;