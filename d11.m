close all; 
clear all;
clc;

I = imread('img1.jpg');

level = graythresh(I);

I2 = im2bw(I, level);

%Get object count
[L, NUM] = bwlabel(I2, 8);

punchedObj = 0;

disp(sprintf('%d objects detected.\n',NUM));

for i=1:NUM
    
    r = changem(L==i, 1, i);
    
    r2 = imcomplement(r);
   
    [rL rNUM] = bwlabel(r2,8);

    if rNUM > 1
        punchedObj = punchedObj + 1; 
    end
     
end

disp(sprintf('%d of objects are punched and remaining %d are solid.',...
    punchedObj, NUM-punchedObj));

imshow(I);