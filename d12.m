close all
clear all
clc

resimler = {'sekil1.jpg','sekil2.jpg','sekil3.jpg'};

r = 3;
% VideoPlayer ve VideoFileReader nesnelerini oluþtur
hVideoPlayer = vision.VideoPlayer;
hVideoFileReader = vision.VideoFileReader;
hVideoFileReader.Filename = resimler{r};

frame = step(hVideoFileReader);


% RGB görüntüyü gri ölçekli resme dönüþtür.
hcsc = vision.ColorSpaceConverter;
hcsc.Conversion = 'RGB to intensity';

frame = step(hcsc, frame);


%Gri ölçekli resmi siyah beyaz resme dönüþtür
at = vision.Autothresholder;

frame = step(at, frame);


%Birbirine komþu beyaz pikselleri grupla
ccl = vision.ConnectedComponentLabeler;
[L NUM] = step(ccl, frame);


delikliObjeSay = 0;

for i=1:NUM
    
    %Gruplardaki grup numarasýný 1 ile deðiþtir.
    framei = changem(L==i, 1, i);
   
    %1 ve 0'lardan oluþan resmi ters çevir
    %objenin etrafý beyaz kendisi siyah olur.
    %eðer obje delikli ise birden fazla komþu olmayan beyaz parça
    %ortaya çýkar. Bu da o objenin delikli olduðunu gösterir.
    framei = imcomplement(framei);
   
    %Ters çevrilmiþ resim içinde ayrý parçacýk sayýsýný belirle.
    [Li NUMi] = step(ccl, framei);

    %Eðer Ters çevrilmiþ alt imgede ayrýk obje sayýsý 1'den fazla ise obje deliklidir.
    if NUMi > 1
        delikliObjeSay = delikliObjeSay + 1;
    end
    
end

mesaj = sprintf('%d objenin %d tanesi deliklidir.',NUM,delikliObjeSay);
disp(mesaj);

%Mesajý resim üzerinde göstermek için metin oluþtur.
bilgi = vision.TextInserter('%d objenin %d tanesi deliklidir.',... 
                            'Location', [4 4],...
                            'Color', uint8([255, 0, 0]),...
                            'FontSize', 16);
                        
%Görüntüyü siyah - beyazdan RGB uzayýna dönüþtür.                        
frame = cat(3, frame, frame, frame);

%Görüntü içine yazýyý ekle
frame = step(bilgi, im2uint8(frame), int32([NUM delikliObjeSay]));

%Görüntüyü Video player penceresinde göster 
step(hVideoPlayer, frame); 

%Gereksiz nesneleri bellekten at
release(hVideoFileReader);
release(hVideoPlayer);


    
    
    