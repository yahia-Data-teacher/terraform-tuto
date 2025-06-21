import json
import os

def handler(event, context):
    print('Event:', json.dumps(event, indent=2))
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'Hello from Python Lambda!',
            'environment': os.environ.get('ENVIRONMENT')
        })
    }
