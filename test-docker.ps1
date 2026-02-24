#!/usr/bin/env pwsh
# Docker Containerization Test Script
# Run this script to build, start, and test your containerized application

Write-Host "🐳 Acquisitions API - Docker Containerization Test" -ForegroundColor Cyan
Write-Host "=" * 60 -ForegroundColor Cyan

# Function to test if Docker is running
function Test-DockerRunning {
    try {
        docker info | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

# Step 1: Check Docker Status
Write-Host "`n📋 Step 1: Checking Docker Status..." -ForegroundColor Yellow
if (Test-DockerRunning) {
    Write-Host "✅ Docker is running!" -ForegroundColor Green
    docker --version
} else {
    Write-Host "❌ Docker is not running!" -ForegroundColor Red
    Write-Host "Please start Docker Desktop and run this script again." -ForegroundColor Yellow
    exit 1
}

# Step 2: Stop any existing containers
Write-Host "`n🛑 Step 2: Stopping existing containers..." -ForegroundColor Yellow
docker-compose -f docker-compose.dev.yml down --remove-orphans

# Step 3: Build the containers
Write-Host "`n🔨 Step 3: Building Docker images..." -ForegroundColor Yellow
docker-compose -f docker-compose.dev.yml build --no-cache

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Build failed!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Images built successfully!" -ForegroundColor Green

# Step 4: Start containers
Write-Host "`n🚀 Step 4: Starting containers..." -ForegroundColor Yellow
docker-compose -f docker-compose.dev.yml up -d

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Container startup failed!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Containers started successfully!" -ForegroundColor Green

# Step 5: Wait for services to be ready
Write-Host "`n⏳ Step 5: Waiting for services to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

# Step 6: Check container status
Write-Host "`n📊 Step 6: Container Status..." -ForegroundColor Yellow
docker-compose -f docker-compose.dev.yml ps

# Step 7: Test API endpoints
Write-Host "`n🧪 Step 7: Testing API Endpoints..." -ForegroundColor Yellow

# Test root endpoint
Write-Host "Testing root endpoint..." -ForegroundColor Cyan
try {
    $rootResponse = Invoke-RestMethod -Uri "http://localhost:3000" -Method Get -Headers @{"Accept"="application/json"}
    Write-Host "✅ Root endpoint: $($rootResponse.message)" -ForegroundColor Green
} catch {
    Write-Host "❌ Root endpoint failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test API status
Write-Host "Testing API status endpoint..." -ForegroundColor Cyan
try {
    $apiResponse = Invoke-RestMethod -Uri "http://localhost:3000/api" -Method Get
    Write-Host "✅ API endpoint: $($apiResponse.message)" -ForegroundColor Green
} catch {
    Write-Host "❌ API endpoint failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test health endpoint
Write-Host "Testing health endpoint..." -ForegroundColor Cyan
try {
    $healthResponse = Invoke-RestMethod -Uri "http://localhost:3000/health" -Method Get
    Write-Host "✅ Health endpoint: Status = $($healthResponse.status)" -ForegroundColor Green
} catch {
    Write-Host "❌ Health endpoint failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 8: Test frontend
Write-Host "`n🌐 Step 8: Testing Frontend..." -ForegroundColor Yellow
try {
    $frontendResponse = Invoke-WebRequest -Uri "http://localhost:3000" -Method Get
    if ($frontendResponse.StatusCode -eq 200) {
        Write-Host "✅ Frontend is accessible!" -ForegroundColor Green
        Write-Host "   Content-Type: $($frontendResponse.Headers['Content-Type'])" -ForegroundColor Cyan
    }
} catch {
    Write-Host "❌ Frontend test failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Step 9: Show logs
Write-Host "`n📋 Step 9: Recent Application Logs..." -ForegroundColor Yellow
docker-compose -f docker-compose.dev.yml logs --tail=10 app

# Step 10: Database connectivity test
Write-Host "`n🗄️  Step 10: Database Connectivity..." -ForegroundColor Yellow
Write-Host "Checking database container..." -ForegroundColor Cyan
docker-compose -f docker-compose.dev.yml logs --tail=5 neon-local

# Final summary
Write-Host "`n" + "=" * 60 -ForegroundColor Cyan
Write-Host "🎉 CONTAINERIZATION TEST COMPLETE!" -ForegroundColor Green
Write-Host "`n🔗 Access your application at:" -ForegroundColor Yellow
Write-Host "   • Frontend: http://localhost:3000" -ForegroundColor White
Write-Host "   • API: http://localhost:3000/api" -ForegroundColor White
Write-Host "   • Health: http://localhost:3000/health" -ForegroundColor White
Write-Host "`n📊 Monitor containers:" -ForegroundColor Yellow
Write-Host "   docker-compose -f docker-compose.dev.yml ps" -ForegroundColor White
Write-Host "   docker-compose -f docker-compose.dev.yml logs -f app" -ForegroundColor White
Write-Host "`n🛑 Stop containers:" -ForegroundColor Yellow
Write-Host "   docker-compose -f docker-compose.dev.yml down" -ForegroundColor White

Write-Host "`n✨ Your Acquisitions API is now fully containerized!" -ForegroundColor Green