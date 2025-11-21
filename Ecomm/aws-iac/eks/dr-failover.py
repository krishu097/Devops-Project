#!/usr/bin/env python3
"""
RDS Failover Script for Disaster Recovery
Promotes read replica to primary when primary region fails
"""

import boto3
import time
import sys
import json

class RDSFailover:
    def __init__(self, primary_region, replica_region, db_identifier):
        self.primary_region = primary_region
        self.replica_region = replica_region
        self.db_identifier = db_identifier
        self.replica_identifier = f"{db_identifier}-replica"
        
        # Initialize RDS clients
        self.primary_rds = boto3.client('rds', region_name=primary_region)
        self.replica_rds = boto3.client('rds', region_name=replica_region)
    
    def check_primary_health(self):
        """Check if primary RDS is healthy"""
        try:
            response = self.primary_rds.describe_db_instances(
                DBInstanceIdentifier=self.db_identifier
            )
            status = response['DBInstances'][0]['DBInstanceStatus']
            return status == 'available'
        except Exception as e:
            print(f"Primary RDS check failed: {e}")
            return False
    
    def promote_replica(self):
        """Promote read replica to standalone primary"""
        try:
            print(f"Promoting replica {self.replica_identifier} to primary...")
            
            response = self.replica_rds.promote_read_replica(
                DBInstanceIdentifier=self.replica_identifier
            )
            
            print("Promotion initiated. Waiting for completion...")
            
            # Wait for promotion to complete
            waiter = self.replica_rds.get_waiter('db_instance_available')
            waiter.wait(
                DBInstanceIdentifier=self.replica_identifier,
                WaiterConfig={'Delay': 30, 'MaxAttempts': 40}
            )
            
            # Get new endpoint
            response = self.replica_rds.describe_db_instances(
                DBInstanceIdentifier=self.replica_identifier
            )
            new_endpoint = response['DBInstances'][0]['Endpoint']['Address']
            
            print(f"✅ Failover completed! New primary endpoint: {new_endpoint}")
            return new_endpoint
            
        except Exception as e:
            print(f"❌ Failover failed: {e}")
            return None
    
    def update_application_config(self, new_endpoint):
        """Update application configuration with new endpoint"""
        config = {
            "database": {
                "endpoint": new_endpoint,
                "region": self.replica_region,
                "status": "failover_active"
            }
        }
        
        with open('failover-config.json', 'w') as f:
            json.dump(config, f, indent=2)
        
        print(f"📝 Configuration updated: failover-config.json")
    
    def execute_failover(self):
        """Execute complete failover process"""
        print("🚨 Starting DR Failover Process...")
        
        # Check primary health
        if self.check_primary_health():
            print("⚠️  Primary RDS appears healthy. Are you sure you want to failover? (y/N)")
            if input().lower() != 'y':
                print("Failover cancelled.")
                return False
        
        # Promote replica
        new_endpoint = self.promote_replica()
        if not new_endpoint:
            return False
        
        # Update configuration
        self.update_application_config(new_endpoint)
        
        print("🎯 Next steps:")
        print("1. Update Kubernetes secrets with new endpoint")
        print("2. Deploy application to secondary region EKS")
        print("3. Update DNS/Load Balancer to point to new region")
        
        return True

if __name__ == "__main__":
    # Configuration
    PRIMARY_REGION = "us-east-2"
    REPLICA_REGION = "us-west-1" 
    DB_IDENTIFIER = "ecomm-uat-edfx-mysql"
    
    failover = RDSFailover(PRIMARY_REGION, REPLICA_REGION, DB_IDENTIFIER)
    
    if len(sys.argv) > 1 and sys.argv[1] == "--execute":
        failover.execute_failover()
    else:
        print("DR Failover Script")
        print("Usage: python dr-failover.py --execute")
        print(f"Primary: {PRIMARY_REGION}")
        print(f"Replica: {REPLICA_REGION}")
        print(f"DB: {DB_IDENTIFIER}")