#!/usr/bin/env python3
import boto3
import json
import requests
import os

def lambda_handler(event, context):
    """
    Lambda function to monitor primary region health and trigger DR failover
    """
    
    # Initialize AWS clients
    primary_region = os.environ.get('PRIMARY_REGION', 'us-east-1')
    replica_region = os.environ.get('REPLICA_REGION', 'us-west-2')
    
    rds_primary = boto3.client('rds', region_name=primary_region)
    rds_replica = boto3.client('rds', region_name=replica_region)
    
    try:
        # Check primary RDS instance health
        primary_response = rds_primary.describe_db_instances(
            DBInstanceIdentifier='ecomm-rds-instance'
        )
        
        primary_status = primary_response['DBInstances'][0]['DBInstanceStatus']
        
        # Check replica count
        replica_response = rds_replica.describe_db_instances()
        replica_count = len([db for db in replica_response['DBInstances'] 
                           if 'replica' in db['DBInstanceIdentifier']])
        
        print(f"Primary status: {primary_status}, Replica count: {replica_count}")
        
        # Trigger DR if primary is down and replica count is 0
        if primary_status != 'available' and replica_count == 0:
            trigger_dr_failover()
            return {
                'statusCode': 200,
                'body': json.dumps('DR failover triggered successfully')
            }
        
        return {
            'statusCode': 200,
            'body': json.dumps('Primary region healthy, no action needed')
        }
        
    except Exception as e:
        print(f"Error monitoring health: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps(f'Error: {str(e)}')
        }

def trigger_dr_failover():
    """
    Trigger GitHub Actions DR failover workflow
    """
    github_token = os.environ.get('GITHUB_TOKEN')
    repo_owner = os.environ.get('GITHUB_OWNER')
    repo_name = os.environ.get('GITHUB_REPO')
    
    if not all([github_token, repo_owner, repo_name]):
        raise ValueError("Missing GitHub configuration")
    
    url = f"https://api.github.com/repos/{repo_owner}/{repo_name}/dispatches"
    
    headers = {
        'Authorization': f'token {github_token}',
        'Accept': 'application/vnd.github.v3+json'
    }
    
    data = {
        'event_type': 'dr-failover',
        'client_payload': {
            'reason': 'Primary region failure detected by monitoring'
        }
    }
    
    response = requests.post(url, headers=headers, json=data)
    
    if response.status_code != 204:
        raise Exception(f"Failed to trigger DR workflow: {response.text}")
    
    print("DR failover workflow triggered successfully")

if __name__ == "__main__":
    # For local testing
    lambda_handler({}, {})