# Docker Containerization Test Script
# Simple version to test your containerized application

Write-Host "Docker Containerization Test" -ForegroundColor Cyan
Write-Host "==============================" -ForegroundColor Cyan

# Check Docker Status
Write-Host "`nStep 1: Checking Docker Status..." -ForegroundColor Yellow
try {
    docker info | Out-Null
    Write-Host "✅ Docker is running!" -ForegroundColor Green
    docker --version
}
catch {
    Write-Host "❌ Docker is not running!" -ForegroundColor Red
    Write-Host "Please start Docker Desktop and try again." -ForegroundColor Yellow
    exit 1
}

# Stop existing containers
Write-Host "`nStep 2: Stopping existing containers..." -ForegroundColor Yellow
docker-compose -f docker-compose.dev.yml down --remove-orphans

# Build containers
Write-Host "`nStep 3: Building Docker images..." -ForegroundColor Yellow
docker-compose -f docker-compose.dev.yml build

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Build failed!" -ForegroundColor Red
    exit 1
}

# Start containers
Write-Host "`nStep 4: Starting containers..." -ForegroundColor Yellow
docker-compose -f docker-compose.dev.yml up -d

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Container startup failed!" -ForegroundColor Red
    exit 1
}

# Wait for startup
Write-Host "`nStep 5: Waiting for services..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

# Check status
Write-Host "`nStep 6: Container Status..." -ForegroundColor Yellow
docker-compose -f docker-compose.dev.yml ps

# Test endpoints
Write-Host "`nStep 7: Testing API Endpoints..." -ForegroundColor Yellow

try {
    $apiResponse = Invoke-RestMethod -Uri "http://localhost:3000/api" -Method Get
    Write-Host "✅ API Status: $($apiResponse.message)" -ForegroundColor Green
}
catch {
    Write-Host "❌ API test failed: $($_.Exception.Message)" -ForegroundColor Red
}

try {
    $healthResponse = Invoke-RestMethod -Uri "http://localhost:3000/health" -Method Get
    Write-Host "✅ Health Check: $($healthResponse.status)" -ForegroundColor Green
}
catch {
    Write-Host "❌ Health test failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test frontend
Write-Host "`nStep 8: Testing Frontend..." -ForegroundColor Yellow
try {
    $frontendResponse = Invoke-WebRequest -Uri "http://localhost:3000" -Method Get
    if ($frontendResponse.StatusCode -eq 200) {
        Write-Host "✅ Frontend is accessible!" -ForegroundColor Green
    }
}
catch {
    Write-Host "❌ Frontend test failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Show logs
Write-Host "`nStep 9: Recent Application Logs..." -ForegroundColor Yellow
docker-compose -f docker-compose.dev.yml logs --tail=10 app

# Summary
Write-Host "`n==============================" -ForegroundColor Cyan
Write-Host "CONTAINERIZATION TEST COMPLETE!" -ForegroundColor Green
Write-Host "`nAccess your application at:" -ForegroundColor Yellow
Write-Host "  Frontend: http://localhost:3000" -ForegroundColor White
Write-Host "  API: http://localhost:3000/api" -ForegroundColor White
Write-Host "  Health: http://localhost:3000/health" -ForegroundColor White
Write-Host "`nTo stop containers:" -ForegroundColor Yellow
Write-Host "  docker-compose -f docker-compose.dev.yml down" -ForegroundColor White
Write-Host "`nYour app is now containerized!" -ForegroundColor Green