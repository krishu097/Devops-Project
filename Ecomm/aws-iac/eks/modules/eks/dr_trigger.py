import json
import urllib3
import os

def handler(event, context):
    github_token = os.environ['GITHUB_TOKEN']
    github_repo = os.environ['GITHUB_REPO']
    
    http = urllib3.PoolManager()
    
    url = f"https://api.github.com/repos/{github_repo}/dispatches"
    
    headers = {
        'Authorization': f'token {github_token}',
        'Accept': 'application/vnd.github.v3+json',
        'Content-Type': 'application/json'
    }
    
    data = {
        'event_type': 'cloudwatch-alarm',
        'client_payload': {
            'alarm': event['Records'][0]['Sns']['Subject'],
            'message': event['Records'][0]['Sns']['Message']
        }
    }
    
    response = http.request('POST', url, 
                          body=json.dumps(data).encode('utf-8'),
                          headers=headers)
    
    return {
        'statusCode': 200,
        'body': json.dumps('DR pipeline triggered successfully')
    }