import os

# Caminho para a pasta que contém as subpastas
path = r"C:\Users\pedro\OneDrive - ufu.br\UFU\TCC\Banco de imagens\Pacientes"

# Lista todas as subpastas
folders = [f for f in os.listdir(path) if os.path.isdir(os.path.join(path, f))]

# Renomeia cada subpasta
for i, folder in enumerate(folders, start=1):
    old_path = os.path.join(path, folder)
    new_path = os.path.join(path, f"Paciente_{i}")
    os.rename(old_path, new_path)
