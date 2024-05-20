import os
import pydicom
from collections import defaultdict
from time import time as t
import shutil

def adicionar_extensao_dcm(caminho_raiz):
    for raiz, dirs, arquivos in os.walk(caminho_raiz):
        for arquivo in arquivos:
            caminho_completo = os.path.join(raiz, arquivo)
            novo_nome = caminho_completo + '.dcm'
            os.rename(caminho_completo, novo_nome)

def procurar_tempo_aquisicao(caminho_raiz, tag_date, tag_time, valor_date, valor_time):
    for raiz, dirs, arquivos in os.walk(caminho_raiz):
        for arquivo in arquivos:
            caminho_completo = os.path.join(raiz, arquivo)
            try:
                # Ler apenas as informações necessárias do arquivo DICOM
                dados_dicom = pydicom.dcmread(caminho_completo, stop_before_pixels=True, specific_tags=[tag_date, tag_time])
                # Procurar as tags DICOM especificadas
                if tag_date in dados_dicom and tag_time in dados_dicom:
                    if str(dados_dicom[tag_date].value) == valor_date and str(dados_dicom[tag_time].value).startswith(valor_time):
                        print(f"Arquivo DICOM com a tag {tag_date} = {valor_date} e {tag_time} começando com {valor_time} encontrado: {caminho_completo}")
            except Exception as e:
                print(f"Erro ao ler o arquivo {caminho_completo}: {str(e)}")

def procurar_tipo_imagem(caminho_raiz, tag_type, valor_type):
    for raiz, dirs, arquivos in os.walk(caminho_raiz):
        for arquivo in arquivos:
            caminho_completo = os.path.join(raiz, arquivo)
            try:
                # Ler apenas as informações necessárias do arquivo DICOM
                dados_dicom = pydicom.dcmread(caminho_completo, stop_before_pixels=True, specific_tags=[tag_type])
                # Procurar as tags DICOM especificadas
                if dados_dicom and tag_type in dados_dicom:
                    if valor_type in dados_dicom[tag_type].value:
                        print(f"Arquivo DICOM encontrado: {caminho_completo}")
            except Exception as e:
                print(f"Erro ao ler o arquivo {caminho_completo}: {str(e)}")

def move_imagem_HD(caminho_raiz, tag_type, valor_type, diretorio_destino): # Função para mover as imagens para um diretório de destino
    for raiz, dirs, arquivos in os.walk(caminho_raiz):
        for arquivo in arquivos:
            caminho_completo = os.path.join(raiz, arquivo)
            try:
                # Ler apenas as informações necessárias do arquivo DICOM
                dados_dicom = pydicom.dcmread(caminho_completo, stop_before_pixels=True, specific_tags=[tag_type])
                # Procurar as tags DICOM especificadas
                if dados_dicom and tag_type in dados_dicom:
                    if valor_type in dados_dicom[tag_type].value:
                        print(f"Arquivo DICOM encontrado: {caminho_completo}")
                        # Obter o nome do subdiretório após o diretório raiz
                        subdiretorio = os.path.relpath(raiz, caminho_raiz).split(os.path.sep)[0]
                        print(f"Subdiretório: {subdiretorio}")
                        # Criar o subdiretório no diretório de destino, se ainda não existir
                        diretorio_destino_final = os.path.join(diretorio_destino, subdiretorio)
                        os.makedirs(diretorio_destino_final, exist_ok=True)
                        # Mover o arquivo DICOM para o diretório de destino
                        shutil.move(caminho_completo, diretorio_destino_final)
            except Exception as e:
                print(f"Erro ao ler o arquivo {caminho_completo}: {str(e)}")

def mover_imagens_dicom(caminho_raiz, diretorio_destino):
    i = 1
    for raiz, dirs, arquivos in os.walk(caminho_raiz):
        # Agrupar arquivos por data e hora do estudo
        grupos = {}
        for arquivo in arquivos:
            caminho_completo = os.path.join(raiz, arquivo)
            try:
                # Ler apenas as informações necessárias do arquivo DICOM
                dados_dicom = pydicom.dcmread(caminho_completo, stop_before_pixels=True, specific_tags=[(0x0008, 0x0020), (0x0008, 0x0030)])
                # Obter os valores das tags
                data = dados_dicom[(0x0008, 0x0020)].value.split('.')[0]
                hora = dados_dicom[(0x0008, 0x0030)].value.split('.')[0]
                # Adicionar arquivo ao grupo correspondente
                chave_grupo = (data, hora)
                if chave_grupo not in grupos:
                    grupos[chave_grupo] = []
                grupos[chave_grupo].append(caminho_completo)
            except Exception as e:
                print(f"Erro ao ler o arquivo {caminho_completo}: {str(e)}")

        # Processar cada grupo de arquivos
        for (data, hora), arquivos_grupo in grupos.items():
            # Criar o diretório de destino, se ainda não existir
            diretorio_paciente = os.path.join(diretorio_destino, f'Paciente{i}')
            os.makedirs(diretorio_paciente, exist_ok=True)
            i += 1

            # Mover cada arquivo para o diretório de destino
            for caminho_completo in arquivos_grupo:
                try:
                    # Ler apenas as informações necessárias do arquivo DICOM
                    dados_dicom = pydicom.dcmread(caminho_completo, stop_before_pixels=True, specific_tags=[(0x0008, 0x0008)])
                    # Determinar o subdiretório com base no tipo de imagem
                    tipo = dados_dicom[(0x0008, 0x0008)].value
                    if tipo == ['ORIGINAL', 'PRIMARY', 'TOMOSYNTHESIS', 'NONE']:
                        subdiretorio = 'fatias'
                    elif tipo == ['DERIVED', 'PRIMARY', 'TOMOSYNTHESIS', 'GENERATED_2D']:
                        subdiretorio = 'mama_sintetica'
                    elif tipo == ['ORIGINAL', 'PRIMARY', 'TOMO_PROJ', 'PROJECTION']:
                        subdiretorio = 'projeções'
                    else:
                        subdiretorio = ''
                    
                    # Criar o subdiretório, se necessário
                    if subdiretorio:
                        diretorio_final = os.path.join(diretorio_paciente, subdiretorio)
                        os.makedirs(diretorio_final, exist_ok=True)
                    else:
                        diretorio_final = diretorio_paciente
                    
                    # Mover o arquivo DICOM para o diretório de destino
                    shutil.move(caminho_completo, diretorio_final)
                except Exception as e:
                    print(f"Erro ao mover o arquivo {caminho_completo}: {str(e)}")

# Substitua 'D:\\IMAGENS STORE CAROL' pelo caminho da pasta que você deseja ler
# ler_arquivos_dicom('D:\\IMAGENS STORE CAROL\\SMCDBT\\05899120')
i = t()
# procurar_tempo_aquisicao('C:\\Users\\pedro\\OneDrive - ufu.br\\UFU\\TCC\\Imagens', (0x0008, 0x0020), (0x0008, 0x0030), '20190305', '113842')
# procurar_tipo_imagem('D:\\IMAGENS STORE CAROL',(0x0008, 0x0008),'TOMOSYNTHESIS')
# move_imagem_HD('D:\\IMAGENS STORE CAROL', (0x0008, 0x0008), 'TOMOSYNTHESIS',
#            'C:\\Users\\pedro\\OneDrive - ufu.br\\UFU\\TCC\\Imagens')
mover_imagens_dicom('C:\\Users\\pedro\\OneDrive - ufu.br\\UFU\\TCC\\Imagens', 'C:\\Users\\pedro\\OneDrive - ufu.br\\UFU\\TCC\\Banco de imagens')

# adicionar_extensao_dcm('C:\\Users\\pedro\\OneDrive - ufu.br\\UFU\\TCC\\Imagens')
f = t()
print(f"Tempo de execução do curta: {f - i} segundos")

