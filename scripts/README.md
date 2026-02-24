# 🔧 Development Tools & Scripts

This directory contains scripts and tools for development, testing, and deployment.

---

## 📁 **Scripts Overview**

### **🐳 dev.sh**
- **Purpose:** Start development environment with Docker
- **Usage:** `npm run dev:docker` or `./scripts/dev.sh`
- **Features:** Hot-reloading, development database

### **🚀 prod.sh** 
- **Purpose:** Start production environment with Docker
- **Usage:** `npm run prod:docker` or `./scripts/prod.sh`
- **Features:** Production-optimized, Neon Cloud database

### **🧪 smoke-tests.sh**
- **Purpose:** Post-deployment verification tests
- **Usage:** `./scripts/smoke-tests.sh`
- **Features:** 
  - Health check validation
  - API endpoint testing  
  - Frontend accessibility check
  - Performance monitoring
  - Static file verification

---

## 🧪 **Smoke Tests Details**

The smoke test script performs comprehensive checks:

### **✅ Health Verification**
- Tests `/health` endpoint for proper JSON response
- Validates uptime information
- Checks response time performance

### **🔌 API Testing**
- Tests main API endpoints
- Validates authentication endpoint structure
- Checks error handling

### **🌐 Frontend Testing**
- Verifies frontend page loads (HTTP 200)
- Tests static CSS file accessibility
- Optional API documentation check

### **📊 Performance Checks**
- Measures response time
- Alerts on slow responses (>2s)
- Reports application uptime

---

## 🚀 **Usage in CI/CD Pipeline**

These scripts integrate with your GitHub Actions pipeline:

```yaml
# In your pipeline deployment stage
- name: 🧪 Smoke tests
  run: |
    chmod +x ./scripts/smoke-tests.sh
    APP_URL=https://your-deployed-app.com ./scripts/smoke-tests.sh
```

### **Environment Variables**
- `APP_URL` - The URL of your deployed application (default: http://localhost:3000)
- `MAX_RETRIES` - Number of retry attempts (default: 30)
- `RETRY_INTERVAL` - Seconds between retries (default: 10)

---

## 🔧 **Local Development**

### **Run Smoke Tests Locally**
```bash
# Test local development server
./scripts/smoke-tests.sh

# Test specific environment
APP_URL=http://localhost:3000 ./scripts/smoke-tests.sh

# Test production deployment
APP_URL=https://your-app.herokuapp.com ./scripts/smoke-tests.sh
```

### **Make Scripts Executable**
```bash
chmod +x scripts/*.sh
```

---

## 📈 **Adding New Tests**

To add new smoke tests, edit `smoke-tests.sh`:

```bash
# Add new endpoint test
test_endpoint "/api/new-feature" "200" "New Feature Endpoint" || exit 1

# Add new JSON response test  
test_json_endpoint "/api/status" "version" "Version Information" || exit 1
```

---

**💡 These scripts ensure your deployments are always verified and working correctly!**