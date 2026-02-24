#!/usr/bin/env pwsh
# 🧪 CI/CD Pipeline Test Script
# Tests all components that the CI/CD pipeline will run

Write-Host "🚀 CI/CD Pipeline Component Test" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

$ErrorCount = 0
$TestCount = 0

function Test-Component {
    param(
        [string]$Name,
        [scriptblock]$TestScript,
        [string]$Description
    )
    
    $Global:TestCount++
    Write-Host "`n🔍 Testing: $Name" -ForegroundColor Yellow
    Write-Host "   $Description" -ForegroundColor Gray
    
    try {
        $result = & $TestScript
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ $Name - PASSED" -ForegroundColor Green
        } else {
            Write-Host "❌ $Name - FAILED (Exit Code: $LASTEXITCODE)" -ForegroundColor Red
            $Global:ErrorCount++
        }
    } catch {
        Write-Host "❌ $Name - ERROR: $($_.Exception.Message)" -ForegroundColor Red
        $Global:ErrorCount++
    }
}

# Test 1: Node.js Dependencies
Test-Component "📦 Dependencies" {
    Write-Host "   Checking if node_modules exists..."
    if (Test-Path "node_modules") {
        Write-Host "   ✅ node_modules found"
    } else {
        Write-Host "   Installing dependencies..."
        npm ci
    }
} "Install and verify Node.js dependencies"

# Test 2: Code Linting
Test-Component "🔍 Code Linting" {
    Write-Host "   Running ESLint..."
    npm run lint
} "Check code quality and style"

# Test 3: Unit Tests
Test-Component "🧪 Unit Tests" {
    Write-Host "   Running Jest tests..."
    npm test
} "Execute application unit tests"

# Test 4: Docker Build
Test-Component "🐳 Docker Build" {
    Write-Host "   Building Docker image..."
    docker build -t test-ci-acquisitions-api .
} "Build Docker container image"

# Test 5: Container Health
Test-Component "💉 Container Health" {
    Write-Host "   Starting container..."
    $containerId = docker run -d -p 3001:3000 test-ci-acquisitions-api
    
    if ($containerId) {
        Write-Host "   Container started: $($containerId.Substring(0,12))"
        
        # Wait for startup
        Start-Sleep -Seconds 10
        
        # Test health endpoint
        try {
            $response = Invoke-RestMethod -Uri "http://localhost:3001/health" -Method Get -TimeoutSec 10
            Write-Host "   Health check response: $($response | ConvertTo-Json -Compress)"
            
            # Cleanup
            docker stop $containerId | Out-Null
            docker rm $containerId | Out-Null
        } catch {
            docker stop $containerId | Out-Null
            docker rm $containerId | Out-Null
            throw "Health check failed: $($_.Exception.Message)"
        }
    } else {
        throw "Failed to start container"
    }
} "Test container startup and health"

# Test 6: Pipeline File Validation
Test-Component "⚙️ Pipeline Config" {
    Write-Host "   Validating GitHub Actions workflow..."
    if (Test-Path "docker-build-and-push.yaml") {
        $yamlContent = Get-Content "docker-build-and-push.yaml" -Raw
        if ($yamlContent -match "name:.*CI/CD Pipeline" -and $yamlContent -match "docker/build-push-action") {
            Write-Host "   ✅ Pipeline file looks valid"
        } else {
            throw "Pipeline file missing required components"
        }
    } else {
        throw "Pipeline file not found: docker-build-and-push.yaml"
    }
} "Validate GitHub Actions workflow file"

# Test 7: Environment Configuration
Test-Component "🔧 Environment Config" {
    Write-Host "   Checking environment files..."
    
    $files = @(".env.development", "docker-compose.dev.yml", "Dockerfile")
    foreach ($file in $files) {
        if (Test-Path $file) {
            Write-Host "   ✅ $file exists"
        } else {
            throw "Required file missing: $file"
        }
    }
} "Verify required configuration files"

# Cleanup
Write-Host "`n🧹 Cleaning up test resources..." -ForegroundColor Yellow
try {
    docker rmi test-ci-acquisitions-api -f 2>$null | Out-Null
    Write-Host "   ✅ Test image removed" -ForegroundColor Gray
} catch {
    Write-Host "   ⚠️  Test image cleanup skipped" -ForegroundColor Gray
}

# Summary
Write-Host "`n" + "="*50 -ForegroundColor Cyan
Write-Host "🎯 CI/CD PIPELINE TEST SUMMARY" -ForegroundColor Cyan
Write-Host "="*50 -ForegroundColor Cyan

if ($ErrorCount -eq 0) {
    Write-Host "✅ ALL $TestCount TESTS PASSED!" -ForegroundColor Green
    Write-Host "`n🚀 Your CI/CD pipeline is ready to deploy!" -ForegroundColor Green
    Write-Host "`n📋 Next steps:" -ForegroundColor Yellow
    Write-Host "   1. Add GitHub secrets (DOCKER_USERNAME, DOCKER_PASSWORD)" -ForegroundColor White
    Write-Host "   2. Push to main branch: git push origin main" -ForegroundColor White
    Write-Host "   3. Check GitHub Actions tab for pipeline execution" -ForegroundColor White
} else {
    Write-Host "❌ $ErrorCount/$TestCount TESTS FAILED" -ForegroundColor Red
    Write-Host "`n🔧 Please fix the failed components before deploying" -ForegroundColor Yellow
    exit 1
}

Write-Host "`n🎉 CI/CD Pipeline test complete!" -ForegroundColor Green