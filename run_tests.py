import os
import subprocess

# Diretórios
programs_dir = 'tests/programs'
expected_dir = 'tests/expected'

# Percorrer todos os arquivos na pasta "tests/programs"
for program_file in os.listdir(programs_dir):
    program_path = os.path.join(programs_dir, program_file)
    
    # Verificar se é um arquivo
    if os.path.isfile(program_path):
        # Executar o comando "./compilador tests/programs/{nome do arquivo}"
        result = subprocess.run(["./compilador", program_path], capture_output=True)
        
        # Checar se a execução foi bem-sucedida
        if result.returncode != 0:
            print(f"Erro ao compilar {program_file}: {result.stderr.decode()}")
            exit(1)

        # Caminho para o arquivo MEPA gerado
        mepa_path = 'MEPA'
        
        # Caminho para o arquivo esperado correspondente
        expected_file_path = os.path.join(expected_dir, program_file)
        
        # Comparar conteúdo do arquivo MEPA com o arquivo esperado
        with open(mepa_path, 'r') as mepa_file, open(expected_file_path, 'r') as expected_file:
            mepa_content = mepa_file.read()
            expected_content = expected_file.read()
            
            if mepa_content != expected_content:
                print(f"Erro: O conteúdo do arquivo MEPA não corresponde ao esperado para {program_file}.")
                exit(1)

print("Todos os arquivos foram processados com sucesso!")
