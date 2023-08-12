#!/bin/bash

upload=`curl http://169.254.169.254/latest/meta-data/tags/instance | grep -c "ProcessUpload"`
if [[ $upload -eq 0 ]];
then
    echo "Não é instância de Encoding."
    echo "Parando celery_long e cpu_check."
    systemctl stop celery_long
    systemctl stop cpu_check
else
    parameter_name="mediacms"
    max_attempts=15  # Número máximo de tentativas

    for ((attempt=1; attempt<=$max_attempts; attempt++)); do
        json_value=$(aws ssm get-parameter --name "$parameter_name" --query 'Parameter.Value' --output text)
        
        if [ -n "$json_value" ]; then
            echo "##########################################################"
            echo ">>> Valor obtido na tentativa $attempt"
            break  # Sai do loop se um valor válido for obtido
        else
            echo "##########################################################"
            echo "# Tentativa $attempt: Valor vazio, tentando novamente... # "
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
fi

