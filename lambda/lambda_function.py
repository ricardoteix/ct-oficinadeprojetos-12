import json
import boto3
from botocore.exceptions import ClientError


session = boto3.Session()
ec2_client = session.client('ec2')

def lambda_handler(event, context):

    print(event)

    resposta_instancias = ec2_client.describe_instances(
        Filters=[
            {
                'Name': 'instance-state-name',
                'Values': [
                    'stopped'
                ]
            },
            {
                'Name': 'tag:ProcessUpload',
                'Values': [
                    'only'
                ]
            },
        ],
    )    

    if 'Reservations' in resposta_instancias and \
        len(resposta_instancias['Reservations']) > 0 and \
        len(resposta_instancias['Reservations'][0]['Instances']) > 0:

        instances_to_start = []
        for instance in resposta_instancias['Reservations'][0]['Instances']:
            instances_to_start.append(instance['InstanceId'])

        resposta = ec2_client.start_instances(InstanceIds=instances_to_start)
        msg = f'######## Instancia inicializada: {resposta}' 

    else:
        msg = f'######## Instancia não encontrada' 
    
    print(msg)

    return {
        'statusCode': 200,
        'body': {
            'message': msg
        }
    }

