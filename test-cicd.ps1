#!/usr/bin/env pwsh

# ================================================================
# 🧪 ACQUISITIONS API - CI/CD PIPELINE TEST SCRIPT
# ================================================================
# Tests all components that the CI/CD pipeline will run
# Organized by: Dependencies → Code Quality → Docker → Config
# ================================================================

Write-Host "`n🚀 Acquisitions API - CI/CD Pipeline Tests" -ForegroundColor Cyan
Write-Host "=" * 50 -ForegroundColor Cyan

$ErrorCount = 0
$TestCount = 0

# ================================================================
# 🛠️  TEST FRAMEWORK FUNCTION
# ================================================================
function Test-Component {
    param(
        [string]$Name,
        [scriptblock]$TestScript,
        [string]$Description
    )
    
    $Global:TestCount++
    Write-Host "`n📋 [$Global:TestCount] Testing: $Name" -ForegroundColor Yellow
    Write-Host "    └── $Description" -ForegroundColor Gray
    
    try {
        $result = & $TestScript
        if ($LASTEXITCODE -eq 0) {
            Write-Host "    ✅ $Name - PASSED" -ForegroundColor Green
        } else {
            Write-Host "    ❌ $Name - FAILED (Exit Code: $LASTEXITCODE)" -ForegroundColor Red
            $Global:ErrorCount++
        }
    } catch {
        Write-Host "    ❌ $Name - ERROR: $($_.Exception.Message)" -ForegroundColor Red
        $Global:ErrorCount++
    }
}

# ================================================================
# 📦 SECTION 1: DEPENDENCIES & CODE QUALITY
# ================================================================
Write-Host "`n📦 SECTION 1: Dependencies & Code Quality" -ForegroundColor Magenta
Write-Host "-" * 40 -ForegroundColor Magenta

# Test 1.1: Node.js Dependencies
Test-Component "Dependencies" {
    Write-Host "    🔍 Checking if node_modules exists..."
    if (Test-Path "node_modules") {
        Write-Host "    ✅ node_modules found"
    } else {
        Write-Host "    📦 Installing dependencies..."
        npm ci
    }
} "Install and verify Node.js dependencies"

# Test 1.2: Code Linting
Test-Component "Code Linting" {
    Write-Host "    🔍 Running ESLint..."
    npm run lint
} "Check code quality and style"

# Test 1.3: Unit Tests
Test-Component "Unit Tests" {
    Write-Host "    🧪 Running Jest tests..."
    npm test
} "Execute application unit tests"

# ================================================================
# 🐳 SECTION 2: DOCKER CONTAINERIZATION
# ================================================================
Write-Host "`n🐳 SECTION 2: Docker Containerization" -ForegroundColor Magenta
Write-Host "-" * 40 -ForegroundColor Magenta

# Test 2.1: Docker Build
Test-Component "Docker Build" {
    Write-Host "    🏗️  Building Docker image..."
    docker build -t test-ci-acquisitions-api .
} "Build Docker container image"

# Test 2.2: Container Health Check
Test-Component "Container Health" {
    Write-Host "    🚀 Starting container..."
    $containerId = docker run -d -p 3001:3000 test-ci-acquisitions-api
    
    if ($containerId) {
        Write-Host "    📦 Container started: $($containerId.Substring(0,12))"
        Write-Host "    ⏳ Waiting for startup..."
        Start-Sleep -Seconds 10
        
        try {
            $response = Invoke-RestMethod -Uri "http://localhost:3001/health" -Method Get -TimeoutSec 10
            Write-Host "    ✅ Health endpoint response: $($response | ConvertTo-Json -Compress)"
            
            # Cleanup container
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
} "Test container startup and health endpoint"

# ================================================================
# ⚙️  SECTION 3: CONFIGURATION VALIDATION
# ================================================================
Write-Host "`n⚙️  SECTION 3: Configuration Validation" -ForegroundColor Magenta
Write-Host "-" * 40 -ForegroundColor Magenta

# Test 3.1: Pipeline Configuration
Test-Component "Pipeline Config" {
    Write-Host "    📋 Validating GitHub Actions workflow..."
    if (Test-Path "docker-build-and-push.yaml") {
        $yamlContent = Get-Content "docker-build-and-push.yaml" -Raw
        if ($yamlContent -match "name:.*CI/CD Pipeline" -and $yamlContent -match "docker/build-push-action") {
            Write-Host "    ✅ Pipeline file validation passed"
        } else {
            throw "Pipeline file missing required components"
        }
    } else {
        throw "Pipeline file not found: docker-build-and-push.yaml"
    }
} "Validate GitHub Actions workflow file"

# Test 3.2: Environment Configuration
Test-Component "Environment Config" {
    Write-Host "    📁 Checking configuration files..."
    
    $files = @(".env.development", "docker-compose.dev.yml", "Dockerfile")
    foreach ($file in $files) {
        if (Test-Path $file) {
            Write-Host "    ✅ $file exists"
        } else {
            Write-Host "    ⚠️  $file missing (optional)"
        }
    }
} "Verify required configuration files"

# ================================================================
# 🧹 CLEANUP & SUMMARY
# ================================================================
Write-Host "`n🧹 Cleanup & Summary" -ForegroundColor Magenta
Write-Host "-" * 40 -ForegroundColor Magenta

# Cleanup test resources
Write-Host "`n🗑️  Cleaning up test resources..." -ForegroundColor Yellow
try {
    docker rmi test-ci-acquisitions-api -f 2>$null | Out-Null
    Write-Host "    ✅ Test Docker image removed" -ForegroundColor Gray
} catch {
    Write-Host "    ⚠️  Test image cleanup skipped" -ForegroundColor Gray
}

# ================================================================
# 📊 FINAL TEST SUMMARY
# ================================================================
Write-Host "`n" + "=" * 60 -ForegroundColor Cyan
Write-Host "📊 ACQUISITIONS API - CI/CD PIPELINE TEST RESULTS" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan

if ($ErrorCount -eq 0) {
    Write-Host "`n🎉 SUCCESS: ALL $TestCount TESTS PASSED!" -ForegroundColor Green
    Write-Host "`n🚀 Your Acquisitions API is ready to deploy!" -ForegroundColor Green
    Write-Host "`n📋 Next Steps:" -ForegroundColor Yellow
    Write-Host "    1️⃣  Add GitHub secrets (DOCKER_USERNAME, DOCKER_PASSWORD)" -ForegroundColor White
    Write-Host "    2️⃣  Push to main branch: git push origin main" -ForegroundColor White
    Write-Host "    3️⃣  Monitor GitHub Actions tab for deployment" -ForegroundColor White
} else {
    Write-Host "`n💥 FAILURE: $ErrorCount/$TestCount TESTS FAILED" -ForegroundColor Red
    Write-Host "`n🔧 Please fix the failed components before deploying" -ForegroundColor Yellow
    exit 1
}

Write-Host "`n✨ CI/CD Pipeline validation complete!" -ForegroundColor Green
Write-Host "=" * 60 -ForegroundColor Cyan