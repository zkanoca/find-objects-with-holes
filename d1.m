close all, clear all
clc;


resimler = {'sekil1.jpg','sekil2.jpg','sekil3.jpg'};
r = 3;

I = imread(resimler{r});

I2 = im2bw(I, graythresh(I));

%Kom�uluk bulunmayan ayr� objeleri belirle
[L, NUM] = bwlabel(I2, 8);

delikli = 0;

disp(sprintf('Toplam %d adet par�a tespit edildi.\n',NUM));

for i=1:NUM
    
    %Gruplardaki grup numaras�n� 1 ile de�i�tir.
    r = changem(L==i, 1, i);
   
    %1 ve 0'lardan olu�an resmi ters �evir
    %objenin etraf� beyaz kendisi siyah olur.
    %e�er obje delikli ise birden fazla kom�u olmayan beyaz par�a
    %ortaya ��kar. Bu da o objenin delikli oldu�unu g�sterir.
    r2 = imcomplement(r);
   
    %Ters �evrilmi� resim i�inde ayr� par�ac�k say�s�n� belirle.
    [rL rNUM] = bwlabel(r2,8);

    %E�er Ters �evrilmi� alt imgede ayr�k obje say�s� 1'den fazla ise obje deliklidir.
    if rNUM > 1
        delikli = delikli + 1;
    end
    
end

mesaj = sprintf('Toplam %d objenin %d tanesi deliklidir.',NUM, delikli);

imshow(I);

title(mesaj);
disp(mesaj);

    
    
    