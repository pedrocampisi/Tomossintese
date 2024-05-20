function imagem_sintetica = MIP(img)
    img = squeeze(img);

    for i = 1:size(img, 3)
        %img_filtrada(:, :, i) = medfilt2(img(:,:,i), [3 3]);
        %img_filtrada(:, :, i) = wiener2(img(:,:,i), [3 3]); 
        img_filtrada(:, :, i) = Contraste_carneiro(img(:,:,i));
    end

    imagem_sintetica = max(img_filtrada, [], 3); % Aplicação da tecnica MIP. 
    %imagem_sintetica = wiener2(imagem_sintetica, [3 3]);
    %imagem_sintetica = Contraste_carneiro(imagem_sintetica);
end
