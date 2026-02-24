#!/usr/bin/env pwsh
# Quick setup script for running Acquisitions API on any computer

Write-Host "🚀 Acquisitions API - Quick Setup" -ForegroundColor Cyan
Write-Host "=================================" -ForegroundColor Cyan

# Check if Docker is running
Write-Host "`n📋 Checking Docker..." -ForegroundColor Yellow
try {
    docker info | Out-Null
    Write-Host "✅ Docker is running!" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker is not running!" -ForegroundColor Red
    Write-Host "Please start Docker Desktop and run this script again." -ForegroundColor Yellow
    exit 1
}

# Check if project files exist
if (-Not (Test-Path "docker-compose.dev.yml")) {
    Write-Host "❌ Project files not found!" -ForegroundColor Red
    Write-Host "Please ensure you're in the correct project directory." -ForegroundColor Yellow
    exit 1
}

# Stop any existing containers
Write-Host "`n🛑 Stopping existing containers..." -ForegroundColor Yellow
docker-compose -f docker-compose.dev.yml down --remove-orphans

# Build and start containers
Write-Host "`n🔨 Building and starting containers..." -ForegroundColor Yellow
docker-compose -f docker-compose.dev.yml up -d --build

# Wait for services to be ready
Write-Host "`n⏳ Waiting for services to start..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

# Test endpoints
Write-Host "`n🧪 Testing application..." -ForegroundColor Yellow
try {
    $apiResponse = Invoke-RestMethod -Uri "http://localhost:3000/api" -Method Get
    Write-Host "✅ API Status: $($apiResponse.message)" -ForegroundColor Green
    
    $healthResponse = Invoke-RestMethod -Uri "http://localhost:3000/health" -Method Get
    Write-Host "✅ Health Check: $($healthResponse.status)" -ForegroundColor Green
    
    Write-Host "`n🎉 SUCCESS! Your application is running!" -ForegroundColor Green
    Write-Host "`n🌐 Access your app at:" -ForegroundColor Cyan
    Write-Host "   Frontend: http://localhost:3000" -ForegroundColor White
    Write-Host "   API: http://localhost:3000/api" -ForegroundColor White
    Write-Host "   Health: http://localhost:3000/health" -ForegroundColor White
    
} catch {
    Write-Host "❌ Application test failed: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Check logs with: docker-compose -f docker-compose.dev.yml logs" -ForegroundColor Yellow
}

Write-Host "`n✨ Setup complete!" -ForegroundColor Green