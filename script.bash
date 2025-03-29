#!/bin/bash

# Verificar se foi passado o primeiro argumento (número de execuções)
if [ -z "$1" ]; then
    echo "Por favor, passe o número de execuções como argumento."
    exit 1
fi

# Definir o número de execuções com o primeiro argumento
N=$1

# Arrays para armazenar os scores
scores_main=()
scores_modified=()

# Tempo máximo de execução para cada script (em segundos)
TIMEOUT=1

# Função para rodar um script e capturar os 3 valores de saída
run_script() {
    local script_name=$1
    local -n scores_array=$2  # Passagem de array por referência
    local seed=$3
    local delay=$4

    # Executa o script com timeout
    output=$(timeout $TIMEOUT python3 "$script_name" --seed "$seed" --delay "$delay" | tail -n 1)
    
    # Verifica se o comando falhou devido ao timeout
    if [ -z "$output" ]; then
        echo "Execução de $script_name falhou (timeout). Tentando novamente..."
        return 1
    fi

    # Extrair os valores e formatar
    score=$(echo "$output" | awk '{print $1 ";" $2 ";" $3 ";" $4}')
    scores_array+=("$score")
    return 0
}

if [ ! -d "./scores" ]; then
    mkdir "./scores"
fi

# Nome do arquivo CSV
CSV_FILE_MAIN="./scores/main_score.csv"
CSV_FILE_MODIFIED="./scores/modified_score.csv"

# Criar o arquivo CSV com cabeçalho
echo "score;steps;seed;unfinished" > "$CSV_FILE_MAIN"
echo "score;steps;seed;unfinished" > "$CSV_FILE_MODIFIED"

# Executar o loop até atingir N execuções bem-sucedidas
count=0
while [ $count -lt $N ]; do
    RANDOM_SEED=$RANDOM
    DELAY=$2  # Defina o delay desejado

    echo "Rodando execução $((count + 1)) com seed $RANDOM_SEED..."

    # Executa os scripts até ter sucesso
    if run_script "main.py" scores_main $RANDOM_SEED $DELAY && run_script "modified.py" scores_modified $RANDOM_SEED $DELAY; then
        echo "${scores_main[$count]}" >> "$CSV_FILE_MAIN"
        echo "${scores_modified[$count]}" >> "$CSV_FILE_MODIFIED"
        count=$((count + 1))
    else
        echo "Failed"
    fi
done

python3 "./score_plot.py"