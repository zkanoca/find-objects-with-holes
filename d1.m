close all, clear all
clc;


resimler = {'sekil1.jpg','sekil2.jpg','sekil3.jpg'};
r = 3;

I = imread(resimler{r});

I2 = im2bw(I, graythresh(I));

%Komþuluk bulunmayan ayrý objeleri belirle
[L, NUM] = bwlabel(I2, 8);

delikli = 0;

disp(sprintf('Toplam %d adet parça tespit edildi.\n',NUM));

for i=1:NUM
    
    %Gruplardaki grup numarasýný 1 ile deðiþtir.
    r = changem(L==i, 1, i);
   
    %1 ve 0'lardan oluþan resmi ters çevir
    %objenin etrafý beyaz kendisi siyah olur.
    %eðer obje delikli ise birden fazla komþu olmayan beyaz parça
    %ortaya çýkar. Bu da o objenin delikli olduðunu gösterir.
    r2 = imcomplement(r);
   
    %Ters çevrilmiþ resim içinde ayrý parçacýk sayýsýný belirle.
    [rL rNUM] = bwlabel(r2,8);

    %Eðer Ters çevrilmiþ alt imgede ayrýk obje sayýsý 1'den fazla ise obje deliklidir.
    if rNUM > 1
        delikli = delikli + 1;
    end
    
end

mesaj = sprintf('Toplam %d objenin %d tanesi deliklidir.',NUM, delikli);

imshow(I);

title(mesaj);
disp(mesaj);

    
    
    