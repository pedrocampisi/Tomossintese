function im8 = Contraste_carneiro(im)
    %WAVELET
    wnamew = 'coif5'; %nome da função wavelet, usada a 'coif5'; outras familias na tese do carlos

    [xaw,xhw,xvw,xdw] = dwt2(im,wnamew); %decomposição da imagem
    kw = 3; %constante que varia de 2 a 3 baseado no artigo, que está dentro do threshold "phase preserving denoising of images"

    %início do threshold baseado na distribuição de rayleigh
    vaw = var(xhw(:)); %variância
    Mw = sqrt(vaw) * sqrt((pi)/2); %média da distribuição de rayleigh, coeficiente horizontal
    Vw = sqrt( ((4-pi)/2)* vaw);
    Tw = Mw + (kw * Vw);

    vaw_v = var(xvw(:));  %coeficiente vertical
    Mw2 = sqrt(vaw_v) * sqrt((pi)/2);
    Vw2 = sqrt( ((4-pi)/2)* vaw_v);
    Tw2 = Mw2 + (kw * Vw2);

    vaw_d = var(xdw(:));  %coeficiente diagonal
    Mw3 =  sqrt(vaw_d) * sqrt((pi)/2);
    Vw3 = sqrt( ((4-pi)/2)* vaw_d);
    Tw3 = Mw3 + (kw * Vw3);
    %fim do threshold

    %início do denoising
    HR = wdencmp('gbl',xhw,wnamew,1,Tw,'s', 1); %função do matlab
    VR = wdencmp('gbl',xvw,wnamew,1,Tw2,'s', 1); %s = soft, h = hard
    DR = wdencmp('gbl',xdw,wnamew,1,Tw3,'s', 1);

    im6 = idwt2(xaw,HR,VR,DR,wnamew); %inversa da wavelet, pega a aproximação com as vert, diag, e horizontal 'denoisadas';

    if max(im6(:)>4095)
        im7 = im6;
        im7(im7>4095)=4095;  
    else 
        im7 = im6;
    end

    im7 = uint16(im6); %original + wavelet
    
    %CLAHE
    %Passa a CLAHE na aproximação da Wave 1;
    xaw_nova = xaw - (min(xaw(:))); %Tiramos a parte negativa subtraindo o menor valor

    % O adapthiseq não aceita valores double que seja > 1 ou < 0
    % Portanto, na hora de fazer o adapthisteq nós dividimos pelo máximo
    % Assim, fazemos a eq de valores entre 0 e 1, mas sem modificar a xa_nova
    clahe_15w = adapthisteq(xaw_nova/max(xaw_nova(:)),'NumTiles', [15 15]);

    % Agora voltamos o resultado (clahe_aprox) para valores referentes
    % ao XA (original), por meio da multiplicação pelo MAX de XA_NOVA
    % e da soma do menor valor de XA(xa_nova/max(xa_nova(:))
    clahe_15w = clahe_15w*max(xaw_nova(:)) + min(xaw(:));

    % Depois é só fazer a Wavelet inversa..
    C_WaveClahe2=idwt2(clahe_15w,HR,VR,DR,wnamew); %Wave inversa

    if max(C_WaveClahe2(:)>4095)
        im8 = C_WaveClahe2;
        im8(im8>4095)=4095;  
    else 
        im8 = C_WaveClahe2;
    end

    im8 = uint16(C_WaveClahe2);  %wavelet + clahe
end
