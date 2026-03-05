# AWS ECS Deployment Script with Fargate
# This script sets up a complete ECS deployment with load balancer

Write-Host "[DEPLOY] AWS ECS Fargate Deployment Helper" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green

# Check prerequisites
if (!(Get-Command "aws" -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] AWS CLI not found. Please install it first" -ForegroundColor Red
    exit 1
}

# Get AWS account info
$awsAccount = aws sts get-caller-identity --query "Account" --output text
$region = aws configure get region
if (!$region) { $region = "us-east-1" }

Write-Host "[OK] AWS Account: $awsAccount" -ForegroundColor Green
Write-Host "[OK] Region: $region" -ForegroundColor Green

# Get deployment info
Write-Host ""
Write-Host "[SETUP] ECS Deployment Configuration:" -ForegroundColor Blue
$clusterName = Read-Host "Cluster name (default: acquisitions-cluster)" 
if (!$clusterName) { $clusterName = "acquisitions-cluster" }

$serviceName = Read-Host "Service name (default: acquisitions-service)"
if (!$serviceName) { $serviceName = "acquisitions-service" }

$dockerImage = Read-Host "Docker image (e.g., yourusername/acquisitions:latest)"
$databaseUrl = Read-Host "DATABASE_URL" -AsSecureString
$arcjetKey = Read-Host "ARCJET_KEY" -AsSecureString

# Convert secure strings
$databaseUrlPlain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($databaseUrl))
$arcjetKeyPlain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($arcjetKey))

Write-Host ""
Write-Host "[SETUP] Setting up AWS resources..." -ForegroundColor Blue

try {
    # 1. Create ECS cluster
    Write-Host "Creating ECS cluster: $clusterName"
    aws ecs create-cluster --cluster-name $clusterName --capacity-providers FARGATE --default-capacity-provider-strategy capacityProvider=FARGATE,weight=1

    # 2. Create CloudWatch log group
    Write-Host "Creating CloudWatch log group"
    aws logs create-log-group --log-group-name "/ecs/$serviceName" --region $region

    # 3. Store secrets in AWS Secrets Manager
    Write-Host "Storing secrets in AWS Secrets Manager"
    $secretDbArn = aws secretsmanager create-secret --name "$serviceName/DATABASE_URL" --secret-string $databaseUrlPlain --query "ARN" --output text
    $secretArcjetArn = aws secretsmanager create-secret --name "$serviceName/ARCJET_KEY" --secret-string $arcjetKeyPlain --query "ARN" --output text

    # 4. Create IAM role for task execution (if doesn't exist)
    Write-Host "Setting up IAM roles"
    $executionRoleArn = "arn:aws:iam::${awsAccount}:role/ecsTaskExecutionRole"
    
    # Create trust policy
    $trustPolicy = @{
        Version = "2012-10-17"
        Statement = @(
            @{
                Effect = "Allow"
                Principal = @{ Service = "ecs-tasks.amazonaws.com" }
                Action = "sts:AssumeRole"
            }
        )
    } | ConvertTo-Json -Depth 10

    aws iam create-role --role-name ecsTaskExecutionRole --assume-role-policy-document $trustPolicy 2>$null
    aws iam attach-role-policy --role-name ecsTaskExecutionRole --policy-arn "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"

    # Additional policy for Secrets Manager
    $secretsPolicy = @{
        Version = "2012-10-17"
        Statement = @(
            @{
                Effect = "Allow"
                Action = @("secretsmanager:GetSecretValue")
                Resource = @($secretDbArn, $secretArcjetArn)
            }
        )
    } | ConvertTo-Json -Depth 10

    aws iam put-role-policy --role-name ecsTaskExecutionRole --policy-name SecretsManagerAccess --policy-document $secretsPolicy

    # 5. Create task definition
    Write-Host "Creating ECS task definition"
    $taskDefinition = @{
        family = $serviceName
        networkMode = "awsvpc"
        requiresCompatibilities = @("FARGATE")
        cpu = "256"
        memory = "512"
        executionRoleArn = $executionRoleArn
        containerDefinitions = @(
            @{
                name = "$serviceName-container"
                image = $dockerImage
                portMappings = @(
                    @{
                        containerPort = 3000
                        protocol = "tcp"
                    }
                )
                environment = @(
                    @{ name = "PORT"; value = "3000" }
                    @{ name = "NODE_ENV"; value = "production" }
                )
                secrets = @(
                    @{ name = "DATABASE_URL"; valueFrom = $secretDbArn }
                    @{ name = "ARCJET_KEY"; valueFrom = $secretArcjetArn }
                )
                logConfiguration = @{
                    logDriver = "awslogs"
                    options = @{
                        "awslogs-group" = "/ecs/$serviceName"
                        "awslogs-region" = $region
                        "awslogs-stream-prefix" = "ecs"
                    }
                }
                essential = $true
            }
        )
    } | ConvertTo-Json -Depth 10

    $taskDefinition | Out-File "ecs-task-definition.json" -Encoding UTF8
    $taskDefArn = aws ecs register-task-definition --cli-input-json "file://ecs-task-definition.json" --query "taskDefinition.taskDefinitionArn" --output text

    # 6. Get default VPC and subnets
    Write-Host "Getting VPC information"
    $vpcId = aws ec2 describe-vpcs --filters "Name=isDefault,Values=true" --query "Vpcs[0].VpcId" --output text
    $subnets = aws ec2 describe-subnets --filters "Name=vpc-id,Values=$vpcId" --query "Subnets[*].SubnetId" --output text
    $subnetList = $subnets -split '\s+'

    # 7. Create security group
    Write-Host "Creating security group"
    $sgId = aws ec2 create-security-group --group-name "$serviceName-sg" --description "Security group for $serviceName" --vpc-id $vpcId --query "GroupId" --output text
    aws ec2 authorize-security-group-ingress --group-id $sgId --protocol tcp --port 3000 --cidr 0.0.0.0/0

    # 8. Create ECS service
    Write-Host "Creating ECS service"
    $serviceArn = aws ecs create-service `
        --cluster $clusterName `
        --service-name $serviceName `
        --task-definition $serviceName `
        --desired-count 1 `
        --launch-type FARGATE `
        --network-configuration "awsvpcConfiguration={subnets=[$($subnetList -join ',')],securityGroups=[$sgId],assignPublicIp=ENABLED}" `
        --query "service.serviceArn" --output text

    Write-Host ""
    Write-Host "[SUCCESS] ECS service deployed:" -ForegroundColor Green
    Write-Host "   Cluster: $clusterName" -ForegroundColor Cyan
    Write-Host "   Service: $serviceName" -ForegroundColor Cyan
    Write-Host "   Task Definition: $taskDefArn" -ForegroundColor Cyan
    Write-Host "   Security Group: $sgId" -ForegroundColor Cyan

    # Get public IP (after service starts)
    Write-Host ""
    Write-Host "[WAIT] Waiting for service to start..." -ForegroundColor Yellow
    Start-Sleep 30
    
    $taskArn = aws ecs list-tasks --cluster $clusterName --service-name $serviceName --query "taskArns[0]" --output text
    if ($taskArn -and $taskArn -ne "None") {
        $networkDetails = aws ecs describe-tasks --cluster $clusterName --tasks $taskArn --query "tasks[0].attachments[0].details" --output json | ConvertFrom-Json
        $eniId = ($networkDetails | Where-Object { $_.name -eq "networkInterfaceId" }).value
        if ($eniId) {
            $publicIp = aws ec2 describe-network-interfaces --network-interface-ids $eniId --query "NetworkInterfaces[0].Association.PublicIp" --output text
            if ($publicIp -and $publicIp -ne "None") {
                Write-Host ""
                Write-Host "[DONE] Your API is available at: http://${publicIp}:3000/api" -ForegroundColor Green
            }
        }
    }

    # Save deployment info
    @{
        ClusterName = $clusterName
        ServiceName = $serviceName
        ServiceArn = $serviceArn
        TaskDefinitionArn = $taskDefArn
        SecurityGroupId = $sgId
        DatabaseSecretArn = $secretDbArn
        ArcjetSecretArn = $secretArcjetArn
        Region = $region
        DeployedAt = Get-Date
    } | ConvertTo-Json | Out-File "ecs-deployment-info.json"

    Write-Host ""
    Write-Host "[INFO] Deployment info saved to: ecs-deployment-info.json" -ForegroundColor Gray
    Write-Host "[TIP] Monitor your deployment: https://console.aws.amazon.com/ecs/home?region=$region#/clusters/$clusterName/services" -ForegroundColor Gray

} catch {
    Write-Host ""
    Write-Host "[ERROR] Deployment failed:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
} finally {
    # Cleanup temporary files
    Remove-Item "ecs-task-definition.json" -ErrorAction SilentlyContinue
}

Write-Host ""
Write-Host "[COMPLETE] ECS deployment script finished!" -ForegroundColor Green
