function imagem_sintetica = SOMA(img, img_ge)
    img = squeeze(img);
    pixel_max = double(max(img_ge(:)));  % Encontra o valor máximo na imagem de referência e converte para double
    for i = 1:size(img, 3)
        img_filtrada(:, :, i) = Contraste_carneiro(img(:,:,i));
        %img_filtrada(:, :, i) = medfilt2(img(:,:,i), [3 3]);
        %img_filtrada(:, :, i) = wiener2(img(:,:,i), [3 3]); 
    end

    imagem_sintetica = sum(img_filtrada, 3); % Aplicação da tecnica MIP. 

    % Normaliza a imagem para o intervalo [0, 1]
    imagem_sintetica = imagem_sintetica / max(imagem_sintetica(:));

    % Converte a imagem para uint16
    imagem_sintetica = uint16(imagem_sintetica * pixel_max);
    imagem_sintetica = Contraste_carneiro(imagem_sintetica);
    imagem_sintetica = wiener2(imagem_sintetica, [3 3]);
end
% Define a função SOMA, que recebe duas entradas: img (a imagem 3D) e img_ge (uma imagem de referência)