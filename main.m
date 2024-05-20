%Limpeza
clc;
clear all;
close all;

%% Codigo principal

caminho = 'C:\Users\pedro\OneDrive - ufu.br\UFU\TCC\Imagens';

subpastas = dir(caminho);
subpastas = subpastas([subpastas.isdir]); % Filtra apenas as pastas

% Extrai os nomes das subpastas e remove '.' e '..'
nomes_subpastas = {subpastas(3:end).name};

% Extrai o número de cada nome de subpasta
numeros_subpastas = cellfun(@(x) str2double(regexp(x, '\d+', 'match')), nomes_subpastas);

% Ordena os números das subpastas e obtém os índices da ordenação
[~, idx] = sort(numeros_subpastas);

% Aplica a ordenação aos nomes das subpastas
nomes_subpastas = nomes_subpastas(idx);

% Cria listas para armazenar os valores
lista_nome_subpasta = {};
lista_ssimval = [];
lista_indice_contraste_ge = [];
lista_indice_contraste_minha = [];

% Percorre cada subpasta
for i = 1:length(nomes_subpastas)
    nome_subpasta = nomes_subpastas{i};
    fprintf('Nome da pasta: %s\n', nome_subpasta);
    % Lê a imagem DICOM na pasta 'Mama sintetica'
    caminho_imagem_sintetica = fullfile(caminho, nome_subpasta, 'mama_sintetica');
    arquivos_dicom = dir(fullfile(caminho_imagem_sintetica, '*.dcm'));
    if ~isempty(arquivos_dicom)
        imagem_sintetica = dicomread(fullfile(caminho_imagem_sintetica, arquivos_dicom(1).name));
    end
    
    % Lê a imagem DICOM na pasta 'Fatias'
    caminho_imagem_fatias = fullfile(caminho, nome_subpasta, 'fatias');
    arquivos_dicom = dir(fullfile(caminho_imagem_fatias, '*.dcm'));
    if ~isempty(arquivos_dicom)
        imagem_fatias = dicomread(fullfile(caminho_imagem_fatias, arquivos_dicom(1).name));
    end
    
    % Cria variáveis com o mesmo nome da subpasta
    assignin('base', [nome_subpasta '_sintetica'], imagem_sintetica);
    assignin('base', [nome_subpasta '_fatias'], imagem_fatias);
    sintetica_ge = imagem_sintetica;
    
    % Criação do caminho onde os resultados serão salvos
    caminho_resultados = 'C:\\Users\\pedro\\OneDrive - ufu.br\\UFU\\TCC\\Resultados';
    caminho_nova_subpasta = fullfile(caminho_resultados, nome_subpasta);
    if ~exist(caminho_nova_subpasta, 'dir')
        mkdir(caminho_nova_subpasta);
    end
    
    % Técnica de reconstrução
    sintetica_minha = MIP(imagem_fatias); % Utiliza a tecnia MIP para recontruir a mama sintetica a partir das fatias
%     sintetica_minha = SOMA(imagem_fatias, sintetica_ge); 
    figure;
    imshow(sintetica_minha, []);
    title("Sintetica minha");
   % figure;
%     imshow(sintetica_ge, []);
    
    % Reposicionamento de imagem e ajuste de resolução
    [sintetica_ge, sintetica_minha] = ajuste_resolucao(sintetica_ge, sintetica_minha); % Faz o ajuste de resolução da imagem para elas ficarem compativeis. 
%     figure
%     imshow(sintetica_ge, []);
%     title("sinte ge cortada");
    dicomwrite(sintetica_ge, fullfile(caminho_nova_subpasta, 'sintetica_ge.dcm'));  % Salva as imagens DICOM na nova subpasta
    dicomwrite(sintetica_minha, fullfile(caminho_nova_subpasta, 'sintetica_minha.dcm'));
%     figure;
%     imshow(sintetica_minha, []);
%     title("Imagem MIp cortada");
    
    %SSIM
    [ssimval, ssimmap] =  ssim(sintetica_ge, sintetica_minha);
%     figure
%     imshow(ssimmap, [])
%     title("Mapa do ssim");
%     % disp(['O valor de SSIM entre as duas imagens é: ', num2str(ssimval)]);
    dicomwrite(ssimmap, fullfile(caminho_nova_subpasta, 'mapa_ssim.dcm'));  % Salva as imagens DICOM na nova subpasta
    
    % Indice de contraste carneiro (ICC)
    %Ge
    im_norm = double(sintetica_ge)./4095; 
    matriz_std = stdfilt(im_norm); 
    indice_contraste_ge = mean(matriz_std(matriz_std>0))*1000;
%     figure
%     imshow((matriz_std.*10000), []); 
%     title("mapa do icc da sintetica ge");
    dicomwrite(matriz_std, fullfile(caminho_nova_subpasta, 'ICC_ge.dcm'));  % Salva as imagens DICOM na nova subpasta
    %Minha reconstrução
    im_norm = double(sintetica_minha)./4095; 
    matriz_std = stdfilt(im_norm); 
    indice_contraste_minha = mean(matriz_std(matriz_std>0))*1000;
%     figure
%     imshow((matriz_std.*10000), []); 
%     title("mapa do icc da sintetica mip");
    dicomwrite(matriz_std*1.15, fullfile(caminho_nova_subpasta, 'ICC_minha.dcm'));  % Salva as imagens DICOM na nova subpasta
    
    % Adiciona os valores às listas para depois eles seram adicionados ao
    % excel
    lista_nome_subpasta{end+1} = nome_subpasta;
    lista_ssimval(end+1) = ssimval;
    lista_indice_contraste_ge(end+1) = indice_contraste_ge;
    lista_indice_contraste_minha(end+1) = indice_contraste_minha;
        
end

% % Caminho para o arquivo Excel
% caminho_excel = 'C:\\Users\\pedro\\OneDrive - ufu.br\\UFU\\TCC\\Resultados\\Resultados.xlsx';
% 
% % Abre o arquivo Excel
% excelObj = actxserver('Excel.Application');
% workbook = excelObj.Workbooks.Open(caminho_excel);
% sheets = excelObj.ActiveWorkbook.Sheets;
% 
% % Percorre as listas
% for i = 1:length(lista_nome_subpasta)
%     % Verifica se a planilha já existe
%     sheetExists = false;
%     for j = 1:sheets.Count
%         if strcmp(sheets.Item(j).Name, lista_nome_subpasta{i})
%             sheet = sheets.Item(j);
%             sheetExists = true;
%             break;
%         end
%     end
% 
%     % Se a planilha não existir, cria uma nova
%     if ~sheetExists
%         if i == 1
%             % No primeiro loop, renomeia a única planilha existente
%             sheet = sheets.Item(1);
%             sheet.Name = lista_nome_subpasta{i};
%         else
%             % Nos outros loops, duplica a planilha anterior e renomeia
%             sheet = sheets.Item(i-1);
%             sheet.Copy([], sheet);
%             newSheet = excelObj.ActiveSheet; % A nova planilha é a planilha ativa
%             newSheet.Name = lista_nome_subpasta{i};
%             sheet = newSheet;
%         end
%     end
% 
%     % Escreve os valores nas células especificadas
%     sheet.Range('E8').Value = lista_ssimval(i);
%     %sheet.Range('F4').Value = lista_indice_contraste_ge(i);
%     sheet.Range('F8').Value = lista_indice_contraste_minha(i);
% end
% 
% % Salva e fecha o arquivo Excel
% excelObj.ActiveWorkbook.Save;
% excelObj.ActiveWorkbook.Close;
% excelObj.Quit;


%% Teste
caminho1 = "C:\Users\pedro\OneDrive - ufu.br\UFU\TCC\Resultados\MIP_CD\Paciente24\sintetica_minha.dcm";
imagem_sintetica = dicomread(caminho1);
imagem_sintetica = Contraste_carneiro(imagem_sintetica);
figure
imshow(imagem_sintetica, [])

%% 
% Gerando duas matrizes 4x3 com valores aleatórios entre 0 e 255
A = randi([0 255], 4, 3);
B = randi([0 255], 4, 3);

% Somando as matrizes
C = A + B;

% Encontrando o valor máximo na matriz resultante
Imax = max(C(:));

% Normalizando a matriz resultante
Inorm = round(C / Imax * (2^8 - 1));


