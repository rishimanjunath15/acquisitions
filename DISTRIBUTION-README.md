# 🚀 Acquisitions API - Quick Start

**Run this professional authentication system on ANY computer with just Docker!**

---

## ⚡ **Super Quick Setup** (2 minutes)

### **Step 1: Install Docker**
Download and install [Docker Desktop](https://www.docker.com/products/docker-desktop/) for your operating system.

### **Step 2: Get Project Files**
```bash
# Option A: Clone repository
git clone https://github.com/yourusername/acquisitions-api.git
cd acquisitions-api

# Option B: Copy project folder to your computer
# (If you received this as a zip file or folder)
```

### **Step 3: Run Everything**
```bash
# Windows PowerShell
.\quick-setup.ps1

# Mac/Linux Terminal  
docker-compose -f docker-compose.dev.yml up -d --build
```

### **Step 4: Open Your App**
🌐 **Visit:** http://localhost:3000

---

## 🎯 **What You Get**

✅ **Professional Authentication System**
- Sign up and sign in pages
- JWT token-based authentication  
- Secure password handling
- Session management

✅ **Production-Ready API**
- RESTful endpoints
- Security middleware (Arcjet, Helmet)
- Health monitoring
- Error handling

✅ **Modern Frontend**
- Responsive design
- Professional styling
- Form validation
- User dashboard

✅ **Database Included**
- PostgreSQL with Neon Cloud
- Automatic migrations
- User management
- Data persistence

---

## 🧪 **Test It Works**

```bash
# Test API (PowerShell)
Invoke-RestMethod -Uri "http://localhost:3000/api" -Method Get
Invoke-RestMethod -Uri "http://localhost:3000/health" -Method Get

# Test API (Mac/Linux)
curl http://localhost:3000/api
curl http://localhost:3000/health
```

**Expected Response:**
```json
{"message":"Acquisitions API is running!"}
{"status":"OK","uptime":123.45}
```

---

## 🛠 **Useful Commands**

```bash
# Start application
docker-compose -f docker-compose.dev.yml up -d

# Stop application  
docker-compose -f docker-compose.dev.yml down

# View logs
docker-compose -f docker-compose.dev.yml logs -f

# Check status
docker-compose -f docker-compose.dev.yml ps
```

---

## 🆘 **Need Help?**

**Common Issues:**

🔧 **"Docker not found"**
- Install Docker Desktop and ensure it's running
- Run `docker --version` to verify installation

🔧 **"Port already in use"**
- Stop existing containers: `docker-compose -f docker-compose.dev.yml down`
- Or change port in `docker-compose.dev.yml`

🔧 **"Container won't start"**  
- Check logs: `docker-compose -f docker-compose.dev.yml logs`
- Ensure `.env` file exists with proper credentials

---

## 📁 **Project Structure**

```
acquisitions-api/
├── 🐳 Dockerfile              # Container configuration
├── 🐳 docker-compose.dev.yml  # Development environment
├── ⚙️ .env                    # Environment variables
├── 📱 public/                 # Frontend files
├── 🔧 src/                    # API source code
└── 📖 README.md               # This file
```

---

## ✨ **The Magic of Docker**

**Why this works everywhere:**
- 🔒 **Isolated**: Runs in its own container
- 📦 **Portable**: Same environment on every computer
- 🚀 **Fast**: No manual setup of dependencies
- 🛡️ **Secure**: Isolated from host system
- 🔧 **Consistent**: No "works on my machine" issues

**No need to install:** Node.js, PostgreSQL, npm packages, or configure environments!

---

**🎉 Your professional authentication API is ready to use!**