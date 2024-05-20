function [sintetica_ge_cropped, img_padded] = ajuste_resolucao(sintetica_ge, sintetica_mip)
    [m, n] = size(sintetica_ge);
    found = false;
    invertida = false;
    % Direita para esquerda
    for j = n:-1:1
        for i = 1:m
            if sintetica_ge(i, n) >= 1000 % Significa que a imagem esta invertida
                found = true;
                invertida = true;
                break;
            end
       
            if sintetica_ge(i, j) >= 1000
                % fprintf('O primeiro pixel diferente de zero, da direita para esquerda, foi encontrado na posição (%d, %d) com valor %f\n', i, j, sintetica_ge(i, j));
                rightToLeft = j;
                found = true;
                break;
            end
        end
        if found
            break;
        end
    end

    if ~found
        fprintf('Nenhum pixel diferente de zero foi encontrado na imagem.\n');
    end
    
    found = false;
    % Da esquerda para direita
    if invertida
        for j = 1:n
             for i = 1:m
                if sintetica_ge(i, j) >= 1000
                    % fprintf('O primeiro pixel diferente de zero, da direita para esquerda, foi encontrado na posição (%d, %d) com valor %f\n', i, j, sintetica_ge(i, j));
                    leftToright = j;
                    found = true;
                    break;
                end
            end
            if found
                break;
            end
        end
    end

    if ~found
        fprintf('Nenhum pixel diferente de zero foi encontrado na imagem.\n');
    end

    found = false;
    % De baixo para cima
    for i = m:-1:1
        for j = 1:n
            if sintetica_ge(i, j) >= 1000
                % fprintf('O primeiro pixel diferente de zero, de baixo para cima, foi encontrado na posição (%d, %d) com valor %f\n', i, j, sintetica_ge(i, j));
                bottomToTop = i;
                found = true;
                break;
            end
        end
        if found
            break;
        end
    end

    if ~found
        fprintf('Nenhum pixel diferente de zero foi encontrado na imagem.\n');
    end

    found = false;

    % De cima para baixo
    for i = 1:m
        for j = 1:n
            if sintetica_ge(i, j) >= 1000
                fprintf('O primeiro pixel diferente de zero, de cima para baixo, foi encontrado na posição (%d, %d) com valor %f\n', i, j, sintetica_ge(i, j));
                topToBottom = i;
                found = true;
                break;
            end
        end
        if found
            break;
        end
    end

    if ~found
        fprintf('Nenhum pixel diferente de zero foi encontrado na imagem.\n');
    end

    % Corta a imagem
    if invertida
        sintetica_ge_cropped = sintetica_ge(topToBottom:bottomToTop, leftToright:n);
    else
        sintetica_ge_cropped = sintetica_ge(topToBottom:bottomToTop, 1:rightToLeft);
    end
%     figure;
%     imshow(sintetica_ge_cropped, []);

    % As dimensões desejadas são da sintetica original cortada
    desired_size = size(sintetica_ge_cropped);

    % Calcule o tamanho do preenchimento necessário
    pad_size = desired_size - size(sintetica_mip);

    % Certifique-se de que o preenchimento é não-negativo
    if any(pad_size < 0)
        error('A imagem já é maior do que o tamanho desejado.')
    end

    % Divida o preenchimento igualmente entre a parte superior e inferior
    pad_size_top_bottom = floor(pad_size(1) / 2);
    pad_size_bottom = pad_size(1) - pad_size_top_bottom;

    % Adicione o preenchimento à imagem na parte superior e inferior
    img_padded = padarray(sintetica_mip, [pad_size_top_bottom, 0], 'pre');
    img_padded = padarray(img_padded, [pad_size_bottom, 0], 'post');

    % Adicione o preenchimento à imagem na lateral direita
    if pad_size(2) > 0
        img_padded = padarray(img_padded, [0, pad_size(2)], 'post');
    end

    % Agora, 'img_padded' é sua imagem original preenchida com pixels pretos até o tamanho desejado
%     figure;
%     imshow(img_padded, []);
%     title("Minha reconstrução aumentada");
end

% Esta função realiza várias operações em duas imagens DICOM.
% 
% [ssimval, ssimmap] = minha_funcao(sintetica_ge, sintetica_mip) recebe duas
% imagens DICOM como entrada, sintetica_ge e sintetica_mip, e retorna duas
% saídas, ssimval e ssimmap.
%
% A função realiza as seguintes operações:
% 1. Encontra o primeiro pixel diferente de zero em várias direções na imagem sintetica_ge.
% 2. Corta a imagem sintetica_ge com base nos pixels encontrados.
% 3. Redimensiona a imagem sintetica_mip para o mesmo tamanho da imagem cortada.
%
% As entradas para a função são:
% sintetica_ge - Uma imagem DICOM.
% sintetica_mip - Uma imagem DICOM.
%
% As saídas da função são:

