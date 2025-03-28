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

# Função para rodar um script e capturar os 3 valores de saída
run_script() {
    local script_name=$1
    local -n scores_array=$2  # Passagem de array por referência
    local seed=$3
    local delay=$4

    # Executa o script e captura a saída
    output=$(python3 "$script_name" --seed "$seed" --delay "$delay" | tail -n 1)

    # Extrair os três valores separados por espaço e formatar para ; (com 3 valores)
    score=$(echo "$output" | awk '{print $1 ";" $2 ";" $3}')

    # Adiciona ao array correspondente
    scores_array+=("$score")
}

if [ ! -d "./scores" ]; then
    mkdir "./scores"
fi

# Nome do arquivo CSV
CSV_FILE_MAIN="./scores/main_score.csv"
CSV_FILE_MODIFIED="./scores/modified_score.csv"

# Criar o arquivo CSV com cabeçalho
echo "score;steps;unfinished" > "$CSV_FILE_MAIN"
echo "score;steps;unfinished" > "$CSV_FILE_MODIFIED"

# Executar o loop n vezes
for i in $(seq 1 $N); do
    # Gerar uma seed aleatória para cada execução
    RANDOM_SEED=$RANDOM
    DELAY=$2  # Defina o delay desejado

    echo "Rodando execução $i com seed $RANDOM_SEED..."

    # Rodar os scripts e armazenar os scores
    run_script "main.py" scores_main $RANDOM_SEED $DELAY
    run_script "modified.py" scores_modified $RANDOM_SEED $DELAY

    # Adicionar os scores no arquivo CSV (uma linha por execução)
    echo "${scores_main[$i-1]}" >> "$CSV_FILE_MAIN"
    echo "${scores_modified[$i-1]}" >> "$CSV_FILE_MODIFIED"
done
