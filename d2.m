clc, clear all, close all

% VideoPlayer ve VideoFileReader nesnelerini oluþtur
hVideoPlayer = vision.VideoPlayer;
hVideoFileReader = vision.VideoFileReader;
hVideoFileReader.Filename = 'kirmizitop.avi';


                          
%Topun etrafýný çizmek üzere bir kutu oluþtur. 
maviKutu = vision.ShapeInserter('Shape','Rectangles',...
                              'BorderColor','Custom',...
                              'CustomBorderColor',uint8([0 0 255]));

%Hýz göstergesi için bir dikdörtgen oluþtur. 
hizG = vision.ShapeInserter('Shape','Rectangles',...
                              'BorderColor','Custom',...
                              'CustomBorderColor',uint8([0 255 0]), ...
                              'Fill', true,...
                              'FillColor', 'Custom',...
                              'CustomFillColor', uint8([0 255 0]));
                          

%Hýz vektörünü çizmek üzere bir çizgi oluþtur                          
cizgi = vision.ShapeInserter('Shape', 'Lines', 'BorderColor', 'Custom',...
                             'CustomBorderColor', uint8([0 255 255]) );
                         
                         
%Hýz vektörü bilgisi için metin oluþtur.
bilgi = vision.TextInserter('%.2f', 'Color', uint8([255 255 255]), ...
                            'FontSize', 20, ...
                            'LocationSource', 'Input port');

 
%Frame numarasý için bir sayaç 
f = 0;

%Geçilen Noktalarýn hafýzada tutulmasý için iki boyutlu, boþ bir matris
gn = zeros(1,2);

%video bitmediði sürece döngüyü tekrarla
while ~isDone(hVideoFileReader)
    
    %Ýlgili kareyi al
    frame = step(hVideoFileReader);
    
    %Sayaca +1 ekle
    f = f + 1;
     
 
    % Görüntüyü gri ölçekli resme dönüþtür.
    hcsc = vision.ColorSpaceConverter;
    
    hcsc.Conversion = 'RGB to intensity';
    
    gframe = step(hcsc, frame);
    
    
   
    %Kýrmýzý objeleri izleyebilmek için resmin kýrmýzý bileþeninden gri
    %ölçekli resmi çýkar
    frame1 = imsubtract(frame(:,:,1), gframe);
    
        
    %Gürültüyü azaltmak için görüntüye 5x5'lik median filtresi uygula
    mf = vision.MedianFilter([5 5]);

    frame2 = step(mf, frame1);
    
    
    % Gri ölçekli görüntüyü siyah-beyaz görüntüye dönüþtür.  
    at = vision.Autothresholder;
    
    frame3 = step(at, frame2);
    
         
    %200 pikselden daha küçük olan beyaz bölgeleri kaldýr
    frame4 = bwareaopen(frame3,200);
    
    % Görüntüdeki birbirine baðlý bütün bileþenleri grupla
%     bw = bwlabel(frame4, 8);
    
    ccl = vision.ConnectedComponentLabeler;
    bw = step(ccl, frame4);
   

    %Görüntü blob analizi yapmak için regionprops fonksiyonu
    stats = regionprops(bw, 'BoundingBox', 'Centroid');
    
     

    
    %Kýrmýzý objeleri mavi kutu içine almak için döngü oluþtur
    for object = 2:length(stats)
        
        %[x y w h] þeklinde mavi kutu için gerekli koordinat ve boyutlarý
        %tespit et
    	bb = stats(object).BoundingBox;
        
        %Kýrmýzý topun merkezinin geçerli karede bulunduðu noktayý [x y]
        %þeklinde tespit et
        bc = stats(object).Centroid;
        

        %Geçerli görüntüye mavi kutuyu ekle
        frame = step(maviKutu, frame, [bc(1)-13 bc(2)-12 24 24]);
      
        
        %Geçerli karedeki topun merkez noktasýný gn matrisine kaydet
        gn(f,:) = [bc(1) bc(2)];
        
        %Eðer ilk kare deðilse
        if f > 1 
            %Geçerli karedeki ve bir önceki karedeki tespit edilen merkez
            %nokta sýfýrdan farklý ise
            if (gn(f,1) ~= 0 && gn(f,2) ~= 0) ...
               && (gn(f-1,1) ~= 0 && gn(f-1,2) ~= 0)
                %Bir önceki kare ile þu anki karedeki topun merkez noktalarýnýn
                %farklarýný hesapla
                dx = gn(f,1) - gn(f-1,1);
                dy = gn(f,2) - gn(f-1,2);

                                
                
                %Topun bir önceki karedeki pozisyonu ile geçerli karedeki
                %pozisyonu arasýndaki öklit uzaklýðýný hesapla.
                d = pdist([gn(f-1,1), gn(f-1,2); gn(f,1), gn(f,2)],'euclidean');
                
                
                
                %Görüntüye topun hýzýna iliþkin bilgi vermek amacýyla bir
                %hýz göstergesi ekle
                frame = step(hizG, frame, [0 0 20*d 20]);
                
                

                %hýz vektörü için çizilecek çizgiye ait baþlangýç ve bitiþ
                %koordinatlarýný belirle
                %Çizgi daha belirgin olmasý açýsýndan 4 ile çarpýlmýþtýr
                koor = [gn(f, 1) gn(f, 2) gn(f-1, 1) + 4*dx gn(f-1, 2) + 4*dy];


                %Geçerli görüntüye hýz vektörü çizgisini ekle
                %Hýz vektörünü temsil eden çizginin boyu, topun hýzýyla doðru
                %orantýlýdýr. 
                frame = step(cizgi, frame, koor);
                
                 
                %Hesaplanan öklit uzaklýðýný görüntü içinde göstermek üzere
                %görüntüye ekle
                frame = step(bilgi, frame, double(d), [5 0] );
            end
        end
       
    end
    
    % iþlenmiþ görüntüyü video player penceresinde göster
    step(hVideoPlayer, frame);
    
    %Akýþý yavaþlatmak için iþlemi duraklat.
    pause(0.2);
    
end

%vision.VideoFileReader ve vision.VideoPlayer nesnelerini hafýzadan sil.
release(hVideoFileReader);
release(hVideoPlayer);
