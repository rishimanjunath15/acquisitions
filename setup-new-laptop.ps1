# Quick Setup Script for New Computers
# Run this on any new laptop to set up the project

Write-Host "==========================================" -ForegroundColor Green
Write-Host "  Acquisitions API - Quick Setup Script  " -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""

# Check if Node.js is installed
Write-Host "[CHECK] Node.js..." -ForegroundColor Blue
if (Get-Command node -ErrorAction SilentlyContinue) {
    $nodeVersion = node --version
    Write-Host "[OK] Node.js $nodeVersion installed" -ForegroundColor Green
} else {
    Write-Host "[MISSING] Node.js not found!" -ForegroundColor Red
    Write-Host "Download from: https://nodejs.org/" -ForegroundColor Yellow
    Write-Host "Or run: winget install OpenJS.NodeJS.LTS" -ForegroundColor Cyan
    exit 1
}

# Check if Docker is installed (optional)
Write-Host "[CHECK] Docker..." -ForegroundColor Blue
if (Get-Command docker -ErrorAction SilentlyContinue) {
    Write-Host "[OK] Docker installed" -ForegroundColor Green
} else {
    Write-Host "[INFO] Docker not found (optional for development)" -ForegroundColor Yellow
    Write-Host "Download from: https://www.docker.com/products/docker-desktop/" -ForegroundColor Cyan
}

# Check if .env file exists
Write-Host "[CHECK] Environment file..." -ForegroundColor Blue
if (Test-Path ".env") {
    Write-Host "[OK] .env file exists" -ForegroundColor Green
} else {
    Write-Host "[MISSING] Creating .env file..." -ForegroundColor Yellow
    
    # Create .env from template
    @"
# Database Connection (Get from https://console.neon.tech)
DATABASE_URL=postgresql://user:password@host/database?sslmode=require

# Arcjet Security Key (Get from https://app.arcjet.com)
ARCJET_KEY=your-arcjet-key-here

# Server Configuration
PORT=3000
NODE_ENV=development

# JWT Secret (generate a random string)
JWT_SECRET=your-super-secret-jwt-key-change-this
"@ | Out-File -FilePath ".env" -Encoding UTF8
    
    Write-Host "[CREATED] .env file - EDIT IT with your credentials!" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Required credentials:" -ForegroundColor Cyan
    Write-Host "1. DATABASE_URL - Get from https://console.neon.tech" -ForegroundColor White
    Write-Host "2. ARCJET_KEY   - Get from https://app.arcjet.com" -ForegroundColor White
    Write-Host ""
}

# Install dependencies
Write-Host "[SETUP] Installing dependencies..." -ForegroundColor Blue
npm install

if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] Dependencies installed" -ForegroundColor Green
} else {
    Write-Host "[ERROR] Failed to install dependencies" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "           SETUP COMPLETE!               " -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Edit .env file with your credentials" -ForegroundColor White
Write-Host "   - DATABASE_URL (from Neon)" -ForegroundColor Gray
Write-Host "   - ARCJET_KEY (from Arcjet)" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Start the development server:" -ForegroundColor White
Write-Host "   npm run dev" -ForegroundColor Cyan
Write-Host ""
Write-Host "3. Open in browser:" -ForegroundColor White
Write-Host "   http://localhost:3000" -ForegroundColor Cyan
Write-Host ""
Write-Host "OR use Docker (if installed):" -ForegroundColor White
Write-Host "   docker-compose -f docker-compose.dev.yml up" -ForegroundColor Cyan
Write-Host ""
