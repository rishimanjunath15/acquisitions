# 🐳 Docker Setup Guide - Simple & Quick

Run your Acquisitions API anywhere with Docker! This guide gets you up and running in 5 minutes.

---

## 🚀 Quick Start (2 Steps)

### **Step 1: Install Docker**

Download [Docker Desktop](https://www.docker.com/products/docker-desktop/) and make sure it's running.

### **Step 2: Start Your App**

```bash
# Copy environment file
cp .env.development .env

# Start everything
docker-compose -f docker-compose.dev.yml up -d --build

# Open your app
# Visit: http://localhost:3000
```

**That's it!** 🎉 Your app is running with database included.

---

## ⚙️ Configuration (One-Time Setup)

**Edit your `.env` file with your credentials:**

```env
NEON_API_KEY=neon_api_xxxxxxxxxxxxx
NEON_PROJECT_ID=your-project-id
ARCJET_KEY=your_arcjet_key
```

**Get these from:**

- **Neon API Key**: [Neon Console → API Keys](https://console.neon.tech/app/settings/api-keys)
- **Project ID**: [Neon Console → Project Settings](https://console.neon.tech)
- **Arcjet Key**: [Arcjet Dashboard](https://app.arcjet.com)

---

## 🎯 What You Get

**✅ Complete Development Environment:**

- Your Node.js API (port 3000)
- Fresh PostgreSQL database (auto-created)
- Hot-reloading (code changes reload instantly)
- Professional frontend included

**✅ Two Docker Containers:**

- `app-dev` - Your Acquisitions API
- `neon-local-dev` - Database proxy

---

## 🌍 Run on Any Computer

**Transfer your app to another computer:**

### **Method 1: Copy Project Folder**

1. Copy entire project folder to new computer
2. Install Docker Desktop on new computer
3. Run: `docker-compose -f docker-compose.dev.yml up -d --build`
4. Done! Same app, same experience.

### **Method 2: Use Git**

```bash
git clone https://github.com/yourusername/acquisitions-api.git
cd acquisitions-api
docker-compose -f docker-compose.dev.yml up -d --build
```

**✅ No installation needed:** Node.js, PostgreSQL, or npm - Docker handles everything!

---

## 🧪 Test Your App

**Check if everything is working:**

```bash
# Test API
curl http://localhost:3000/api
# Expected: {"message":"Acquisitions API is running!"}

# Test health
curl http://localhost:3000/health
# Expected: {"status":"OK","uptime":123.45}

# Open frontend
# Visit: http://localhost:3000
```

**PowerShell version:**

```powershell
Invoke-RestMethod -Uri "http://localhost:3000/api" -Method Get
Start-Process "http://localhost:3000"
```

---

## 📋 Essential Commands

### **Daily Use**

```bash
# Start your app
docker-compose -f docker-compose.dev.yml up -d

# Stop your app
docker-compose -f docker-compose.dev.yml down

# View logs
docker-compose -f docker-compose.dev.yml logs -f

# Check container status
docker-compose -f docker-compose.dev.yml ps
```

### **Database Commands**

```bash
# Run database migrations
docker-compose -f docker-compose.dev.yml exec app npm run db:migrate

# Open database admin panel
docker-compose -f docker-compose.dev.yml exec app npm run db:studio
```

---

## 🆘 Common Issues & Fixes

### **"Docker not found" Error**

```bash
# Install Docker Desktop from: https://docker.com
# Make sure Docker Desktop is running
docker --version  # Test if working
```

### **"Port already in use" Error**

```bash
# Stop existing containers
docker-compose -f docker-compose.dev.yml down

# Or kill all Docker processes
docker system prune -f
```

### **"Container won't start" Error**

```bash
# Check what went wrong
docker-compose -f docker-compose.dev.yml logs

# Make sure .env file exists with your credentials
```

### **"Database connection failed" Error**

- Check your `.env` file has correct `NEON_API_KEY` and `NEON_PROJECT_ID`
- Wait 30 seconds for database to initialize
- Check logs: `docker-compose -f docker-compose.dev.yml logs neon-local-dev`

---

## 🎯 Production Setup (Optional)

**For production deployment:**

1. **Create production config:**

   ```bash
   cp .env.production .env.production.local
   ```

2. **Edit `.env.production.local`:**

   ```env
   NODE_ENV=production
   DATABASE_URL=postgresql://user:pass@your-neon-cloud.neon.tech/db
   ARCJET_KEY=your_arcjet_key
   ```

3. **Start production:**
   ```bash
   docker-compose -f docker-compose.prod.yml --env-file .env.production.local up -d
   ```

---

**🎉 That's it! Your Docker setup is complete and ready to use anywhere!**
