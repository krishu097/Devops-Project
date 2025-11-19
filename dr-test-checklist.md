# DR Failover Test Checklist

## Prerequisites
- [ ] Primary RDS instance running in us-east-1
- [ ] RDS read replica exists in us-west-2
- [ ] GitHub secrets configured:
  - [ ] `AWS_DEPLOYMENT_ROLE_ARN`
- [ ] GitHub variables configured:
  - [ ] `AWS_REGION` = us-east-1
  - [ ] `AWS_REGION_REPLICA` = us-west-2
- [ ] Terraform state bucket exists
- [ ] DR environment configured in GitHub

## Test Steps
1. **Verify Current State**
   ```bash
   aws rds describe-db-instances --region us-east-1
   aws rds describe-db-instances --region us-west-2
   ```

2. **Trigger DR Test**
   - Go to GitHub Actions
   - Select "DR Failover Pipeline"
   - Click "Run workflow"
   - Enter test reason

3. **Monitor Progress**
   - Watch workflow execution
   - Check each job completion
   - Verify replica promotion
   - Confirm EKS cluster deployment

4. **Validate Results**
   ```bash
   # Check promoted replica
   aws rds describe-db-instances --region us-west-2
   
   # Check EKS cluster
   aws eks describe-cluster --name YOUR_CLUSTER --region us-west-2
   ```

## Rollback Steps
1. **Stop DR Resources**
   ```bash
   # Destroy DR infrastructure
   terraform destroy -var-file=tf_env/DR_Deployment.tfvars
   ```

2. **Restore Primary**
   ```bash
   # Start primary RDS if stopped
   aws rds start-db-instance --db-instance-identifier ecomm-rds-instance --region us-east-1
   ```

## Success Criteria
- [ ] Primary health check fails
- [ ] Replica count shows 0
- [ ] Replica promotion succeeds
- [ ] EKS cluster deploys in secondary region
- [ ] Applications can connect to promoted database
- [ ] Total failover time < 15 minutes