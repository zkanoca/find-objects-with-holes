close all
clear all
clc

resimler = {'sekil1.jpg','sekil2.jpg','sekil3.jpg'};

r = 3;
% VideoPlayer ve VideoFileReader nesnelerini olu�tur
hVideoPlayer = vision.VideoPlayer;
hVideoFileReader = vision.VideoFileReader;
hVideoFileReader.Filename = resimler{r};

frame = step(hVideoFileReader);


% RGB g�r�nt�y� gri �l�ekli resme d�n��t�r.
hcsc = vision.ColorSpaceConverter;
hcsc.Conversion = 'RGB to intensity';

frame = step(hcsc, frame);


%Gri �l�ekli resmi siyah beyaz resme d�n��t�r
at = vision.Autothresholder;

frame = step(at, frame);


%Birbirine kom�u beyaz pikselleri grupla
ccl = vision.ConnectedComponentLabeler;
[L NUM] = step(ccl, frame);


delikliObjeSay = 0;

for i=1:NUM
    
    %Gruplardaki grup numaras�n� 1 ile de�i�tir.
    framei = changem(L==i, 1, i);
   
    %1 ve 0'lardan olu�an resmi ters �evir
    %objenin etraf� beyaz kendisi siyah olur.
    %e�er obje delikli ise birden fazla kom�u olmayan beyaz par�a
    %ortaya ��kar. Bu da o objenin delikli oldu�unu g�sterir.
    framei = imcomplement(framei);
   
    %Ters �evrilmi� resim i�inde ayr� par�ac�k say�s�n� belirle.
    [Li NUMi] = step(ccl, framei);

    %E�er Ters �evrilmi� alt imgede ayr�k obje say�s� 1'den fazla ise obje deliklidir.
    if NUMi > 1
        delikliObjeSay = delikliObjeSay + 1;
    end
    
end

mesaj = sprintf('%d objenin %d tanesi deliklidir.',NUM,delikliObjeSay);
disp(mesaj);

%Mesaj� resim �zerinde g�stermek i�in metin olu�tur.
bilgi = vision.TextInserter('%d objenin %d tanesi deliklidir.',... 
                            'Location', [4 4],...
                            'Color', uint8([255, 0, 0]),...
                            'FontSize', 16);
                        
%G�r�nt�y� siyah - beyazdan RGB uzay�na d�n��t�r.                        
frame = cat(3, frame, frame, frame);

%G�r�nt� i�ine yaz�y� ekle
frame = step(bilgi, im2uint8(frame), int32([NUM delikliObjeSay]));

%G�r�nt�y� Video player penceresinde g�ster 
step(hVideoPlayer, frame); 

%Gereksiz nesneleri bellekten at
release(hVideoFileReader);
release(hVideoPlayer);


    
    
    