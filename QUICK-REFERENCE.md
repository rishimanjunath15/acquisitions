# Quick Reference Card

## 📁 Project Structure

### **🏠 Root Level - Configuration & Documentation**

```
📄 Configuration Files:
├── package.json              # Node.js dependencies & scripts
├── Dockerfile               # Container configuration
├── docker-compose.dev.yml   # Development environment
├── docker-compose.prod.yml  # Production environment
├── eslint.config.js         # Code linting rules
├── jest.config.mjs          # Testing configuration
├── drizzle.config.js        # Database ORM config
└── .env                     # Environment variables

📋 Documentation:
├── README.md                # Main project documentation
├── QUICK-REFERENCE.md       # This file - quick commands
├── CICD-SETUP.md           # CI/CD pipeline guide
├── DOCKER-SETUP.md         # Docker setup instructions
└── DISTRIBUTION-README.md   # Distribution guide

🚀 Scripts:
├── test-cicd.ps1           # CI/CD pipeline testing
├── quick-setup.ps1         # Quick project setup
├── start-dev.ps1           # Start development server
└── test-docker.ps1         # Docker testing
```

### **💻 Source Code - Main Application**

```
src/
├── 🎯 app.js              # Express app configuration
├── 🚀 index.js            # Application entry point
├── 🗄️ server.js           # Server startup
├── 🔄 migrate.js          # Database migrations
│
├── config/                # 🔧 Configuration modules
│   ├── arcjet.js         # Security configuration
│   ├── database.js       # Database connection
│   └── logger.js         # Logging setup
│
├── controllers/           # 🎮 Request handlers
│   ├── auth.controller.js    # Authentication logic
│   └── users.controller.js   # User management
│
├── middleware/            # ⚙️ Express middleware
│   ├── auth.middleware.js    # Authentication checks
│   └── security.middleware.js # Security headers
│
├── models/                # 📊 Data models
│   └── user.model.js     # User data structure
│
├── routes/                # 🛣️ API endpoints
│   ├── auth.routes.js    # Authentication routes
│   └── users.routes.js   # User routes (/api/users)
│
├── services/              # 💼 Business logic
│   ├── auth.service.js   # Authentication business logic
│   └── users.services.js # User business logic
│
├── utils/                 # 🔨 Helper functions
│   ├── cookies.js        # Cookie utilities
│   ├── format.js         # Formatting helpers
│   └── jwt.js           # JWT token handling
│
└── validations/           # ✅ Input validation
    ├── auth.validation.js    # Auth input validation
    └── users.validation.js   # User input validation
```

### **🌐 Frontend & Assets**

```
public/                    # Static web files
├── 🏠 index.html          # Landing page
├── 🔐 signin.html         # Sign-in page
├── 📝 signup.html         # Sign-up page
├── ✅ welcome.html        # Welcome page
├── 🎨 styles.css          # Styling
├── ⚡ common.js           # Shared JavaScript
├── 🔑 signin.js           # Sign-in logic
└── 📋 signup.js           # Sign-up logic
```

### **🧪 Testing & Quality**

```
tests/                     # Test files
└── 📊 app.test.js         # Application tests

coverage/                  # Test coverage reports
├── 📈 lcov.info          # Coverage data
├── 📋 coverage-final.json # Coverage summary
└── 📊 lcov-report/       # HTML coverage report
```

### **🗄️ Database & Storage**

```
drizzle/                   # Database migrations
├── 🔄 *.sql              # Migration files
└── meta/                 # Migration metadata

logs/                      # Application logs
└── 📝 error.lg           # Error logs

.neon_local/              # Neon database local proxy
└── 🌿 .branches          # Local branch data
```

### **🚀 DevOps & Automation**

```
.github/workflows/         # GitHub Actions CI/CD
├── 🐳 docker-build-and-push.yml # Docker deployment
├── ✨ lint-and-format.yml       # Code quality checks
└── 🧪 tests.yml                 # Automated testing

scripts/                   # Automation scripts
├── 🛠️ dev.sh             # Development setup
├── 🚀 prod.sh            # Production deployment
└── 🧪 smoke-tests.sh     # Post-deploy validation
```

---

## � Setup on a New Laptop/Computer

### Quick Setup (One Command)

```powershell
.\setup-new-laptop.ps1
```

### Manual Setup

**Prerequisites:**

- Node.js 20+ → https://nodejs.org/
- Git → https://git-scm.com/

**Steps:**

```powershell
# 1. Clone/copy the project
git clone https://github.com/yourusername/acquisitions.git
cd acquisitions

# 2. Copy environment template
Copy-Item .env.example .env

# 3. Edit .env with YOUR credentials
notepad .env
# Add your DATABASE_URL and ARCJET_KEY

# 4. Install dependencies
npm install

# 5. Start the server
npm run dev
```

**Required Credentials:**
| Variable | Get From |
|----------|----------|
| `DATABASE_URL` | https://console.neon.tech |
| `ARCJET_KEY` | https://app.arcjet.com |

**Then open:** http://localhost:3000

---

## 🌐 Access from Other Devices (Same Network)

To access your **local dev server** from phone/tablet on same WiFi:

```powershell
# Find your computer's IP address
ipconfig | Select-String "IPv4"
# Example: 192.168.1.100

# Start server (it binds to all interfaces by default)
npm run dev
```

Then on your phone: `http://192.168.1.100:3000`

---

## 🎯 First Time Setup

### 1. Get Neon Credentials

```
Visit: https://console.neon.tech
- Create/select project
- Get API Key: Account Settings → API Keys
- Get Project ID: Project Settings → General
```

### 2. Configure Development

```powershell
Copy-Item .env.development .env
# Edit .env with your credentials
```

### 3. Start Development

```powershell
.\start-dev.ps1
# or
docker-compose -f docker-compose.dev.yml up --build
```

---

## 🔄 Daily Development Workflow

```powershell
# Start
docker-compose -f docker-compose.dev.yml up

# View logs
docker-compose -f docker-compose.dev.yml logs -f app

# Run migrations
docker-compose -f docker-compose.dev.yml exec app npm run db:migrate

# Stop (cleans up ephemeral branch)
docker-compose -f docker-compose.dev.yml down
```

---

## 🚀 Production Deployment

```powershell
# Setup
Copy-Item .env.production .env.production.local
# Add your Neon Cloud connection string to .env.production.local

# Deploy
docker-compose -f docker-compose.prod.yml --env-file .env.production.local up -d --build

# Check status
docker-compose -f docker-compose.prod.yml ps

# View logs
docker-compose -f docker-compose.prod.yml logs -f app

# Stop
docker-compose -f docker-compose.prod.yml down
```

---

## 🗄️ Database Operations

### Generate Migration

```powershell
# Development
docker-compose -f docker-compose.dev.yml exec app npm run db:generate

# Production
docker-compose -f docker-compose.prod.yml exec app npm run db:generate
```

### Run Migration

```powershell
# Development
docker-compose -f docker-compose.dev.yml exec app npm run db:migrate

# Production
docker-compose -f docker-compose.prod.yml exec app npm run db:migrate
```

### Open Drizzle Studio

```powershell
docker-compose -f docker-compose.dev.yml exec app npm run db:studio
```

---

## 🔍 Debugging

### Access Container Shell

```powershell
# Development
docker-compose -f docker-compose.dev.yml exec app sh

# Production
docker-compose -f docker-compose.prod.yml exec app sh
```

### Check Container Status

```powershell
docker-compose -f docker-compose.dev.yml ps
```

### View All Logs

```powershell
docker-compose -f docker-compose.dev.yml logs
```

### Rebuild from Scratch

```powershell
docker-compose -f docker-compose.dev.yml down -v
docker-compose -f docker-compose.dev.yml up --build
```

---

## 🌐 Connection Strings

### Development (Inside Docker)

```
postgres://neon:npg@neon-local:5432/neondb?sslmode=require
```

### Development (From Host)

```
postgres://neon:npg@localhost:5432/neondb?sslmode=require
```

### Production

```
Your Neon Cloud connection string from console.neon.tech
```

---

## 📋 Environment Variables

### Required for Development (.env)

- `NEON_API_KEY` - Your Neon API key
- `NEON_PROJECT_ID` - Your project ID
- `PARENT_BRANCH_ID` - Usually "main"
- `ARCJET_KEY` - Your Arcjet key

### Required for Production (.env.production.local)

- `DATABASE_URL` - Neon Cloud connection string
- `ARCJET_KEY` - Your Arcjet key

---

## ⚡ Key Differences: Dev vs Prod

| Feature          | Development            | Production     |
| ---------------- | ---------------------- | -------------- |
| Database         | Neon Local (Ephemeral) | Neon Cloud     |
| Connection       | Via proxy              | Direct         |
| Branch Lifecycle | Auto-create/delete     | Persistent     |
| Hot Reload       | ✅ Yes                 | ❌ No          |
| Volume Mounts    | Source code            | Logs only      |
| Restart Policy   | No                     | unless-stopped |

---

## 🐛 Common Issues

### "Connection refused"

- Wait 5-10 seconds for Neon Local to start
- Check: `docker-compose -f docker-compose.dev.yml ps`

### "Branch not found"

- Verify `NEON_API_KEY` and `NEON_PROJECT_ID` in `.env`
- Check Neon console for parent branch name

### "Port already in use"

- Stop conflicting services on port 3000 or 5432
- Or change ports in docker-compose file

### Changes not reflected

- Check volume mounts in docker-compose.dev.yml
- Restart: `docker-compose -f docker-compose.dev.yml restart app`

---

## ☁️ Cloud Platform Deployments

Your Docker container is ready for deployment on any cloud platform! Here are the most popular options:

### 🚀 **Railway (Easiest - Recommended)**

```bash
# 1. Install Railway CLI
npm install -g @railway/cli

# 2. Login and deploy
railway login
railway link
railway up --detach
```

**Environment Variables to Set:**

- `DATABASE_URL` - Your Neon Cloud connection string
- `ARCJET_KEY` - Your Arcjet security key
- `PORT` - `3000` (Railway auto-detects)

**🔗 Railway Dashboard:** https://railway.app

---

### 🐳 **Digital Ocean App Platform**

```bash
# 1. Push your Docker image (already done by GitHub Actions)
# 2. Create app.yaml in your repo root:
```

```yaml
name: acquisitions-api
services:
  - name: api
    source_dir: /
    github:
      repo: yourusername/acquisitions-api
      branch: main
    run_command: node src/index.js
    environment_slug: node-js
    instance_count: 1
    instance_size_slug: professional-xs
    envs:
      - key: DATABASE_URL
        scope: RUN_TIME
        type: SECRET
      - key: ARCJET_KEY
        scope: RUN_TIME
        type: SECRET
      - key: PORT
        scope: RUN_TIME
        value: '3000'
    http_port: 3000
```

**Deploy:** Connect GitHub repo at https://cloud.digitalocean.com/apps

---

### ⚡ **Fly.io (Global Edge)**

```bash
# 1. Install Fly CLI
curl -L https://fly.io/install.sh | sh

# 2. Login and launch
fly auth login
fly launch --no-deploy

# 3. Set secrets
fly secrets set DATABASE_URL="your-neon-connection-string"
fly secrets set ARCJET_KEY="your-arcjet-key"

# 4. Deploy
fly deploy
```

**Auto-generated `fly.toml`:**

```toml
app = "acquisitions-api"
primary_region = "dfw"

[build]
  dockerfile = "Dockerfile"

[[services]]
  internal_port = 3000
  protocol = "tcp"

  [[services.ports]]
    handlers = ["http"]
    port = 80

  [[services.ports]]
    handlers = ["tls", "http"]
    port = 443
```

---

### 🔷 **Azure Container Instances**

```bash
# Using Azure CLI
az login

# Create resource group
az group create --name acquisitions-rg --location eastus

# Deploy container
az container create \
  --resource-group acquisitions-rg \
  --name acquisitions-api \
  --image yourusername/acquisitions:latest \
  --dns-name-label acquisitions-api-unique \
  --ports 3000 \
  --environment-variables \
    PORT=3000 \
  --secure-environment-variables \
    DATABASE_URL="your-neon-connection" \
    ARCJET_KEY="your-arcjet-key"
```

---

### 🟢 **Google Cloud Run**

```bash
# Using Google Cloud CLI
gcloud auth login

# Deploy container
gcloud run deploy acquisitions-api \
  --image yourusername/acquisitions:latest \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated \
  --set-env-vars PORT=3000 \
  --set-env-vars DATABASE_URL="your-neon-connection" \
  --set-env-vars ARCJET_KEY="your-arcjet-key"
```

---

### 🔧 **Environment Variables for All Platforms**

**Required:**

- `DATABASE_URL` - Get from [Neon Console](https://console.neon.tech)
- `ARCJET_KEY` - Get from [Arcjet Dashboard](https://app.arcjet.com)
- `PORT` - Usually `3000` or auto-detected

**Optional:**

- `NODE_ENV=production`
- `COOKIE_SECRET` - Random string for session security

---

### 🎯 **Quick Platform Comparison**

| Platform             | Cost | Ease       | Scale      | Global     |
| -------------------- | ---- | ---------- | ---------- | ---------- |
| **Railway**          | $    | ⭐⭐⭐⭐⭐ | ⭐⭐⭐     | ⭐⭐⭐     |
| **Fly.io**           | $    | ⭐⭐⭐⭐   | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Digital Ocean**    | $$   | ⭐⭐⭐⭐   | ⭐⭐⭐⭐   | ⭐⭐⭐     |
| **Azure Container**  | $$$  | ⭐⭐       | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Google Cloud Run** | $$   | ⭐⭐⭐     | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |

**💡 Recommendation:** Start with **Railway** for simplicity, move to **Fly.io** for global performance.

---

### 🔄 **Automated Deployment Updates**

Your GitHub Actions already build and push Docker images! To enable auto-deployment:

1. **Add deployment step** to `.github/workflows/docker-build-and-push.yml`
2. **Set platform secrets** in GitHub repo settings
3. **Push to main branch** → Auto-deploys! 🚀

**Example Railway auto-deploy step:**

```yaml
- name: Deploy to Railway
  run: |
    npm install -g @railway/cli
    railway login --token ${{ secrets.RAILWAY_TOKEN }}
    railway up --service ${{ secrets.RAILWAY_SERVICE_ID }}
```

---

## 📚 Full Documentation

- **[README.md](./README.md)** - Overview and quick start
- **[DOCKER-SETUP.md](./DOCKER-SETUP.md)** - Complete Docker & Neon guide
- **[CICD-SETUP.md](./CICD-SETUP.md)** - CI/CD pipeline guide
- **[Neon Local Docs](https://neon.com/docs/local/neon-local)** - Official documentation

---

## 🆘 Need Help?

1. Check [DOCKER-SETUP.md](./DOCKER-SETUP.md#troubleshooting)
2. Review container logs: `docker-compose -f docker-compose.dev.yml logs`
3. Visit [Neon Discord](https://discord.gg/neon) or [Documentation](https://neon.com/docs)
