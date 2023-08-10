#!/bin/bash

parameter_name="mediacms"
max_attempts=15  # Número máximo de tentativas

for ((attempt=1; attempt<=$max_attempts; attempt++)); do
    json_value=$(aws ssm get-parameter --name "$parameter_name" --query 'Parameter.Value' --output text)
    
    if [ -n "$json_value" ]; then
        echo "##########################################################"
        echo ">>> Valor obtido na tentativa $attempt"
        echo "##########################################################"
        break  # Sai do loop se um valor válido for obtido
    else
        echo "##########################################################"
        echo "# Tentativa $attempt: Valor vazio, tentando novamente... # "
        echo "##########################################################"
        sleep 5  # Pausa entre tentativas, se desejar
    fi
done

sns_topic_arn=$(echo "$json_value" | jq -r '.sns_topic_arn')

while true; do
    
    sleep 120  # Aguardar 2 minutos antes da próxima verificação

    # Obter o uso percentual da CPU
    cpu_usage=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')

    # Verificar se o uso percentual da CPU é maior que 80
    if (( $(echo "$cpu_usage < 10" | bc -l) )); then
        echo "Uso da CPU menor que 10%. Desligando a máquina..."
        
        echo '############### Publicando SNS ################'

        echo Publicando SNS
        topic_arn="$sns_topic_arn"
        aws sns publish --topic-arn $topic_arn --message ""

        echo "################# FIM ###################"

        sudo shutdown -h now
    fi

done
