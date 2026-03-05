# AWS Deployment Status Checker
# Check the status of your deployed applications on AWS

Write-Host "[STATUS] AWS Deployment Status Checker" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green

# Check if AWS CLI is available
if (!(Get-Command "aws" -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] AWS CLI not found" -ForegroundColor Red
    exit 1
}

$region = aws configure get region
if (!$region) { $region = "us-east-1" }

Write-Host "[INFO] Region: $region" -ForegroundColor Blue

# Check for existing deployment info files
$appRunnerInfo = $null
$ecsInfo = $null

if (Test-Path "aws-deployment-info.json") {
    $appRunnerInfo = Get-Content "aws-deployment-info.json" | ConvertFrom-Json
}

if (Test-Path "ecs-deployment-info.json") {
    $ecsInfo = Get-Content "ecs-deployment-info.json" | ConvertFrom-Json
}

# Function to check App Runner status
function Check-AppRunnerStatus {
    param($serviceArn)
    
    Write-Host ""
    Write-Host "[APP RUNNER] Service Status:" -ForegroundColor Blue
    Write-Host "=============================" -ForegroundColor Blue
    
    try {
        $service = aws apprunner describe-service --service-arn $serviceArn | ConvertFrom-Json
        $status = $service.Service.Status
        $url = $service.Service.ServiceUrl
        
        $statusColor = switch ($status) {
            "RUNNING" { "Green" }
            "CREATE_FAILED" { "Red" }
            "DELETE_FAILED" { "Red" }
            default { "Yellow" }
        }
        
        Write-Host "Status: $status" -ForegroundColor $statusColor
        Write-Host "URL: https://$url" -ForegroundColor Cyan
        Write-Host "Created: $($service.Service.CreatedAt)" -ForegroundColor Gray
        
        if ($status -eq "RUNNING") {
            Write-Host ""
            Write-Host "[TEST] Testing API endpoint..."
            try {
                $response = Invoke-RestMethod -Uri "https://$url/api" -Method Get -TimeoutSec 10
                Write-Host "[OK] API Response: $($response.message)" -ForegroundColor Green
            } catch {
                Write-Host "[ERROR] API test failed: $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    } catch {
        Write-Host "[ERROR] Failed to get App Runner status: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Function to check ECS status
function Check-ECSStatus {
    param($cluster, $serviceName)
    
    Write-Host ""
    Write-Host "[ECS] Service Status:" -ForegroundColor Blue
    Write-Host "======================" -ForegroundColor Blue
    
    try {
        $service = aws ecs describe-services --cluster $cluster --services $serviceName | ConvertFrom-Json
        $serviceInfo = $service.services[0]
        
        Write-Host "Service: $($serviceInfo.serviceName)" -ForegroundColor Cyan
        Write-Host "Status: $($serviceInfo.status)" -ForegroundColor Green
        Write-Host "Running Tasks: $($serviceInfo.runningCount)" -ForegroundColor Cyan
        Write-Host "Desired Tasks: $($serviceInfo.desiredCount)" -ForegroundColor Cyan
        
        # Get task details
        $tasks = aws ecs list-tasks --cluster $cluster --service-name $serviceName | ConvertFrom-Json
        if ($tasks.taskArns.Count -gt 0) {
            $taskDetails = aws ecs describe-tasks --cluster $cluster --tasks $tasks.taskArns[0] | ConvertFrom-Json
            $task = $taskDetails.tasks[0]
            
            Write-Host ""
            Write-Host "Task Status:" -ForegroundColor Blue
            Write-Host "Last Status: $($task.lastStatus)" -ForegroundColor Green
            Write-Host "Health Status: $($task.healthStatus)" -ForegroundColor Green
            Write-Host "CPU/Memory: $($task.cpu)/$($task.memory)" -ForegroundColor Gray
            
            # Try to get public IP
            if ($task.attachments -and $task.attachments[0].details) {
                $eniId = ($task.attachments[0].details | Where-Object { $_.name -eq "networkInterfaceId" }).value
                if ($eniId) {
                    $publicIp = aws ec2 describe-network-interfaces --network-interface-ids $eniId --query "NetworkInterfaces[0].Association.PublicIp" --output text
                    if ($publicIp -and $publicIp -ne "None") {
                        Write-Host "Public IP: $publicIp" -ForegroundColor Cyan
                        
                        Write-Host ""
                        Write-Host "[TEST] Testing API endpoint..."
                        try {
                            $response = Invoke-RestMethod -Uri "http://${publicIp}:3000/api" -Method Get -TimeoutSec 10
                            Write-Host "[OK] API Response: $($response.message)" -ForegroundColor Green
                        } catch {
                            Write-Host "[ERROR] API test failed: $($_.Exception.Message)" -ForegroundColor Red
                        }
                    }
                }
            }
        }
    } catch {
        Write-Host "[ERROR] Failed to get ECS status: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Check deployments
if ($appRunnerInfo) {
    Check-AppRunnerStatus -serviceArn $appRunnerInfo.ServiceArn
}

if ($ecsInfo) {
    Check-ECSStatus -cluster $ecsInfo.ClusterName -serviceName $ecsInfo.ServiceName
}

# If no deployment info found, try to discover services
if (!$appRunnerInfo -and !$ecsInfo) {
    Write-Host "[SEARCH] No deployment info found. Searching for services..." -ForegroundColor Yellow
    
    # Search for App Runner services
    try {
        $appRunnerServices = aws apprunner list-services | ConvertFrom-Json
        if ($appRunnerServices.ServiceSummaryList.Count -gt 0) {
            Write-Host ""
            Write-Host "Found App Runner services:" -ForegroundColor Blue
            foreach ($service in $appRunnerServices.ServiceSummaryList) {
                if ($service.ServiceName -like "*acquisitions*") {
                    Write-Host "- $($service.ServiceName) ($($service.Status))" -ForegroundColor Cyan
                    Check-AppRunnerStatus -serviceArn $service.ServiceArn
                }
            }
        }
    } catch {
        Write-Host "No App Runner services found" -ForegroundColor Gray
    }
    
    # Search for ECS services
    try {
        $clusters = aws ecs list-clusters | ConvertFrom-Json
        foreach ($clusterArn in $clusters.clusterArns) {
            $services = aws ecs list-services --cluster $clusterArn | ConvertFrom-Json
            foreach ($serviceArn in $services.serviceArns) {
                $serviceName = $serviceArn.Split("/")[-1]
                if ($serviceName -like "*acquisitions*") {
                    Write-Host "Found ECS service: $serviceName" -ForegroundColor Cyan
                    Check-ECSStatus -cluster $clusterArn -serviceName $serviceName
                }
            }
        }
    } catch {
        Write-Host "No ECS services found" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "[LINKS] AWS Console Links:" -ForegroundColor Blue
Write-Host "- App Runner Console: https://console.aws.amazon.com/apprunner/" -ForegroundColor Gray
Write-Host "- ECS Console: https://console.aws.amazon.com/ecs/" -ForegroundColor Gray
Write-Host "- CloudWatch Logs: https://console.aws.amazon.com/cloudwatch/home?region=$region#logsV2:log-groups" -ForegroundColor Gray

Write-Host ""
Write-Host "[COMPLETE] Status check finished!" -ForegroundColor Green
