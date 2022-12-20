clc, clear all, close all

% VideoPlayer ve VideoFileReader nesnelerini olu�tur
hVideoPlayer = vision.VideoPlayer;
hVideoFileReader = vision.VideoFileReader;
hVideoFileReader.Filename = 'kirmizitop.avi';


                          
%Topun etraf�n� �izmek �zere bir kutu olu�tur. 
maviKutu = vision.ShapeInserter('Shape','Rectangles',...
                              'BorderColor','Custom',...
                              'CustomBorderColor',uint8([0 0 255]));

%H�z g�stergesi i�in bir dikd�rtgen olu�tur. 
hizG = vision.ShapeInserter('Shape','Rectangles',...
                              'BorderColor','Custom',...
                              'CustomBorderColor',uint8([0 255 0]), ...
                              'Fill', true,...
                              'FillColor', 'Custom',...
                              'CustomFillColor', uint8([0 255 0]));
                          

%H�z vekt�r�n� �izmek �zere bir �izgi olu�tur                          
cizgi = vision.ShapeInserter('Shape', 'Lines', 'BorderColor', 'Custom',...
                             'CustomBorderColor', uint8([0 255 255]) );
                         
                         
%H�z vekt�r� bilgisi i�in metin olu�tur.
bilgi = vision.TextInserter('%.2f', 'Color', uint8([255 255 255]), ...
                            'FontSize', 20, ...
                            'LocationSource', 'Input port');

 
%Frame numaras� i�in bir saya� 
f = 0;

%Ge�ilen Noktalar�n haf�zada tutulmas� i�in iki boyutlu, bo� bir matris
gn = zeros(1,2);

%video bitmedi�i s�rece d�ng�y� tekrarla
while ~isDone(hVideoFileReader)
    
    %�lgili kareyi al
    frame = step(hVideoFileReader);
    
    %Sayaca +1 ekle
    f = f + 1;
     
 
    % G�r�nt�y� gri �l�ekli resme d�n��t�r.
    hcsc = vision.ColorSpaceConverter;
    
    hcsc.Conversion = 'RGB to intensity';
    
    gframe = step(hcsc, frame);
    
    
   
    %K�rm�z� objeleri izleyebilmek i�in resmin k�rm�z� bile�eninden gri
    %�l�ekli resmi ��kar
    frame1 = imsubtract(frame(:,:,1), gframe);
    
        
    %G�r�lt�y� azaltmak i�in g�r�nt�ye 5x5'lik median filtresi uygula
    mf = vision.MedianFilter([5 5]);

    frame2 = step(mf, frame1);
    
    
    % Gri �l�ekli g�r�nt�y� siyah-beyaz g�r�nt�ye d�n��t�r.  
    at = vision.Autothresholder;
    
    frame3 = step(at, frame2);
    
         
    %200 pikselden daha k���k olan beyaz b�lgeleri kald�r
    frame4 = bwareaopen(frame3,200);
    
    % G�r�nt�deki birbirine ba�l� b�t�n bile�enleri grupla
%     bw = bwlabel(frame4, 8);
    
    ccl = vision.ConnectedComponentLabeler;
    bw = step(ccl, frame4);
   

    %G�r�nt� blob analizi yapmak i�in regionprops fonksiyonu
    stats = regionprops(bw, 'BoundingBox', 'Centroid');
    
     

    
    %K�rm�z� objeleri mavi kutu i�ine almak i�in d�ng� olu�tur
    for object = 2:length(stats)
        
        %[x y w h] �eklinde mavi kutu i�in gerekli koordinat ve boyutlar�
        %tespit et
    	bb = stats(object).BoundingBox;
        
        %K�rm�z� topun merkezinin ge�erli karede bulundu�u noktay� [x y]
        %�eklinde tespit et
        bc = stats(object).Centroid;
        

        %Ge�erli g�r�nt�ye mavi kutuyu ekle
        frame = step(maviKutu, frame, [bc(1)-13 bc(2)-12 24 24]);
      
        
        %Ge�erli karedeki topun merkez noktas�n� gn matrisine kaydet
        gn(f,:) = [bc(1) bc(2)];
        
        %E�er ilk kare de�ilse
        if f > 1 
            %Ge�erli karedeki ve bir �nceki karedeki tespit edilen merkez
            %nokta s�f�rdan farkl� ise
            if (gn(f,1) ~= 0 && gn(f,2) ~= 0) ...
               && (gn(f-1,1) ~= 0 && gn(f-1,2) ~= 0)
                %Bir �nceki kare ile �u anki karedeki topun merkez noktalar�n�n
                %farklar�n� hesapla
                dx = gn(f,1) - gn(f-1,1);
                dy = gn(f,2) - gn(f-1,2);

                                
                
                %Topun bir �nceki karedeki pozisyonu ile ge�erli karedeki
                %pozisyonu aras�ndaki �klit uzakl���n� hesapla.
                d = pdist([gn(f-1,1), gn(f-1,2); gn(f,1), gn(f,2)],'euclidean');
                
                
                
                %G�r�nt�ye topun h�z�na ili�kin bilgi vermek amac�yla bir
                %h�z g�stergesi ekle
                frame = step(hizG, frame, [0 0 20*d 20]);
                
                

                %h�z vekt�r� i�in �izilecek �izgiye ait ba�lang�� ve biti�
                %koordinatlar�n� belirle
                %�izgi daha belirgin olmas� a��s�ndan 4 ile �arp�lm��t�r
                koor = [gn(f, 1) gn(f, 2) gn(f-1, 1) + 4*dx gn(f-1, 2) + 4*dy];


                %Ge�erli g�r�nt�ye h�z vekt�r� �izgisini ekle
                %H�z vekt�r�n� temsil eden �izginin boyu, topun h�z�yla do�ru
                %orant�l�d�r. 
                frame = step(cizgi, frame, koor);
                
                 
                %Hesaplanan �klit uzakl���n� g�r�nt� i�inde g�stermek �zere
                %g�r�nt�ye ekle
                frame = step(bilgi, frame, double(d), [5 0] );
            end
        end
       
    end
    
    % i�lenmi� g�r�nt�y� video player penceresinde g�ster
    step(hVideoPlayer, frame);
    
    %Ak��� yava�latmak i�in i�lemi duraklat.
    pause(0.2);
    
end

%vision.VideoFileReader ve vision.VideoPlayer nesnelerini haf�zadan sil.
release(hVideoFileReader);
release(hVideoPlayer);
