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

## 📚 Full Documentation

- **[README.md](./README.md)** - Overview and quick start
- **[DOCKER-SETUP.md](./DOCKER-SETUP.md)** - Complete Docker & Neon guide
- **[Neon Local Docs](https://neon.com/docs/local/neon-local)** - Official documentation

---

## 🆘 Need Help?

1. Check [DOCKER-SETUP.md](./DOCKER-SETUP.md#troubleshooting)
2. Review container logs: `docker-compose -f docker-compose.dev.yml logs`
3. Visit [Neon Discord](https://discord.gg/neon) or [Documentation](https://neon.com/docs)
