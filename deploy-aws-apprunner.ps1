# AWS App Runner Deployment Script
# Run this script to deploy to AWS App Runner quickly

Write-Host "[DEPLOY] AWS App Runner Deployment Helper" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green

# Check if AWS CLI is installed
if (!(Get-Command "aws" -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] AWS CLI not found. Please install it first:" -ForegroundColor Red
    Write-Host "   Download from: https://aws.amazon.com/cli/" -ForegroundColor Yellow
    exit 1
}

# Check AWS credentials
Write-Host "[INFO] Checking AWS credentials..." -ForegroundColor Blue
$awsId = aws sts get-caller-identity --query "Account" --output text 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] AWS credentials not configured. Run:" -ForegroundColor Red
    Write-Host "   aws configure" -ForegroundColor Yellow
    exit 1
}
Write-Host "[OK] AWS Account: $awsId" -ForegroundColor Green

# Get required information
Write-Host ""
Write-Host "[SETUP] Information Needed:" -ForegroundColor Blue
$dockerImage = Read-Host "Docker image name (e.g., yourusername/acquisitions:latest)"
$serviceName = Read-Host "Service name (e.g., acquisitions-api)"
$databaseUrl = Read-Host "DATABASE_URL (your Neon connection string)" -AsSecureString
$arcjetKey = Read-Host "ARCJET_KEY (your Arcjet key)" -AsSecureString

# Convert secure strings
$databaseUrlPlain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($databaseUrl))
$arcjetKeyPlain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($arcjetKey))

# Create App Runner configuration
$appRunnerConfig = @{
    ServiceName = $serviceName
    SourceConfiguration = @{
        ImageRepository = @{
            ImageIdentifier = $dockerImage
            ImageConfiguration = @{
                Port = "3000"
                RuntimeEnvironmentVariables = @{
                    PORT = "3000"
                    DATABASE_URL = $databaseUrlPlain
                    ARCJET_KEY = $arcjetKeyPlain
                    NODE_ENV = "production"
                }
            }
            ImageRepositoryType = "ECR_PUBLIC"
        }
        AutoDeploymentsEnabled = $true
    }
    InstanceConfiguration = @{
        Cpu = "0.25 vCpu"
        Memory = "0.5 GB"
    }
} | ConvertTo-Json -Depth 10

# Save configuration to file
$configFile = "apprunner-config.json"
$appRunnerConfig | Out-File -FilePath $configFile -Encoding UTF8

Write-Host ""
Write-Host "[DEPLOY] Creating App Runner service..." -ForegroundColor Blue
Write-Host "Configuration saved to: $configFile" -ForegroundColor Gray

# Create the service
try {
    $result = aws apprunner create-service --cli-input-json "file://$configFile" | ConvertFrom-Json
    $serviceArn = $result.Service.ServiceArn
    $serviceUrl = $result.Service.ServiceUrl
    
    Write-Host ""
    Write-Host "[SUCCESS] App Runner service created:" -ForegroundColor Green
    Write-Host "   Service ARN: $serviceArn" -ForegroundColor Cyan
    Write-Host "   Service URL: https://$serviceUrl" -ForegroundColor Cyan
    
    Write-Host ""
    Write-Host "[WAIT] Service is starting up (this may take 2-3 minutes)..." -ForegroundColor Yellow
    Write-Host "   Check status at: https://console.aws.amazon.com/apprunner/" -ForegroundColor Gray
    
    # Save service info for future use
    @{
        ServiceArn = $serviceArn
        ServiceUrl = $serviceUrl
        DockerImage = $dockerImage
        CreatedAt = Get-Date
    } | ConvertTo-Json | Out-File "aws-deployment-info.json"
    
    Write-Host ""
    Write-Host "[INFO] Deployment info saved to: aws-deployment-info.json" -ForegroundColor Gray
    Write-Host "[DONE] Your API will be available at: https://$serviceUrl/api" -ForegroundColor Green
    
} catch {
    Write-Host ""
    Write-Host "[ERROR] Failed to create App Runner service:" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "Check the AWS console for more details: https://console.aws.amazon.com/apprunner/" -ForegroundColor Gray
}

# Cleanup
Remove-Item $configFile -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "[COMPLETE] Deployment script finished!" -ForegroundColor Green