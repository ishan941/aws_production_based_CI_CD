# Development Environment Setup Guide

This guide will walk you through setting up and running the AWS App development environment using Docker.

## 📋 Prerequisites

Before starting, ensure you have the following installed:

- ✅ **Docker Desktop** (macOS/Windows) or **Docker Engine** (Linux)
- ✅ **Docker Compose** (usually included with Docker Desktop)
- ✅ **Node.js 20+** (for local development - optional)
- ✅ **Git** (for version control)

### Check Prerequisites

```bash
# Check Docker installation
docker --version
# Expected: Docker version 20.0.0 or higher

# Check Docker Compose
docker-compose --version
# Expected: Docker Compose version 2.0.0 or higher

# Verify Docker is running
docker ps
# Should show empty list or running containers (no errors)
```

## 🚀 Step-by-Step Development Setup

### Step 1: Clone and Navigate to Project

```bash
# Clone the repository (if not already done)
git clone https://github.com/ishan941/aws_production_based_CI_CD.git
cd aws_production_based_CI_CD

# Switch to development branch (if needed)
git checkout A-2
```

### Step 2: Setup Environment Variables

```bash
# Copy environment template
cp .env.example .env

# Edit environment file with your preferred editor
nano .env
# Or use VS Code
code .env
```

**Required Environment Variables:**

```bash
# Database Configuration
POSTGRES_USER=postgres
POSTGRES_PASSWORD=devpassword123
POSTGRES_DB=aws_app_dev

# Application Configuration
NODE_ENV=development
PORT=3001
FRONTEND_URL=http://localhost:3000
BACKEND_URL=http://localhost:3001

# Security (Development only - change for production)
JWT_SECRET=development_jwt_secret_32_characters_minimum_length
SESSION_SECRET=development_session_secret_32_characters_minimum_length

# Redis Configuration
REDIS_URL=redis://localhost:6379
```

### Step 3: Build Development Images

```bash
# Build all development Docker images
npm run docker:build:dev

# OR manually build with Docker Compose
docker-compose -f docker-compose.dev.yml build
```

**Expected Output:**

```
✅ Development Docker images built successfully!
```

### Step 4: Start Development Environment

```bash
# Deploy development environment (recommended)
npm run docker:deploy:dev

# OR start services manually
npm run docker:up:dev

# OR use Docker Compose directly
docker-compose -f docker-compose.dev.yml up -d
```

**Expected Output:**

```
🚀 Deploying application...
🔧 Deploying development environment...
✅ Development environment deployed successfully!

🌐 Application URLs:
  Frontend: http://localhost:3000
  Backend:  http://localhost:3001
  Database: localhost:5432
  Redis:    localhost:6379
```

### Step 5: Verify All Services Are Running

```bash
# Check health status
npm run docker:health:dev

# Check container status
docker-compose -f docker-compose.dev.yml ps
```

**Expected Health Check Output:**

```
✅ web-dev: healthy
✅ backend-dev: healthy
✅ postgres-dev: healthy
✅ redis-dev: healthy

🌐 Network connectivity test:
✅ Frontend dev (port 3000): accessible
✅ Backend (port 3001): accessible
```

### Step 6: Access Your Applications

Open your browser and navigate to:

- **Frontend Application**: http://localhost:3000
- **Backend API**: http://localhost:3001/api
- **API Health Check**: http://localhost:3001/api/health
- **Users Endpoint**: http://localhost:3001/api/users

## 🔧 Development Workflow Commands

### Starting Services

```bash
# Start all services
npm run docker:up:dev

# Start with logs visible
docker-compose -f docker-compose.dev.yml up
```

### Stopping Services

```bash
# Stop all services
npm run docker:down:dev

# Stop specific service
docker-compose -f docker-compose.dev.yml stop web-dev
```

### Viewing Logs

```bash
# View all logs
npm run docker:logs:dev

# View logs for specific service
docker-compose -f docker-compose.dev.yml logs -f backend-dev
docker-compose -f docker-compose.dev.yml logs -f web-dev
docker-compose -f docker-compose.dev.yml logs -f postgres-dev
docker-compose -f docker-compose.dev.yml logs -f redis-dev

# View last 50 lines
docker-compose -f docker-compose.dev.yml logs --tail=50 backend-dev
```

### Rebuilding Services

```bash
# Rebuild all services
npm run docker:build:dev

# Rebuild specific service
docker-compose -f docker-compose.dev.yml build backend-dev

# Rebuild and restart
docker-compose -f docker-compose.dev.yml up -d --build
```

### Accessing Service Shells

```bash
# Access backend container
docker-compose -f docker-compose.dev.yml exec backend-dev sh

# Access frontend container
docker-compose -f docker-compose.dev.yml exec web-dev sh

# Access database
docker-compose -f docker-compose.dev.yml exec postgres-dev psql -U postgres -d aws_app_dev

# Access Redis CLI
docker-compose -f docker-compose.dev.yml exec redis-dev redis-cli
```

## 🐛 Troubleshooting

### Problem: Services Won't Start

**Solution 1: Check Docker is Running**

```bash
# Check Docker status
docker ps

# If Docker isn't running, start Docker Desktop
# Or start Docker service on Linux:
sudo systemctl start docker
```

**Solution 2: Clean and Rebuild**

```bash
# Stop all services
npm run docker:down:dev

# Clean Docker resources
npm run docker:cleanup

# Rebuild and start
npm run docker:build:dev
npm run docker:deploy:dev
```

### Problem: Port Already in Use

**Check what's using the ports:**

```bash
# Check port 3000
lsof -i :3000

# Check port 3001
lsof -i :3001

# Kill processes using ports (if needed)
sudo kill -9 $(lsof -t -i:3000)
sudo kill -9 $(lsof -t -i:3001)
```

### Problem: Database Connection Issues

**Reset Database:**

```bash
# Stop services
npm run docker:down:dev

# Remove database volume
docker volume rm aws-app_postgres_dev_data

# Restart services
npm run docker:deploy:dev
```

### Problem: Hot Reload Not Working

**Check volume mounts:**

```bash
# Ensure you're in the project root directory
pwd
# Should show: /path/to/aws_production_based_CI_CD

# Restart with fresh build
docker-compose -f docker-compose.dev.yml down
docker-compose -f docker-compose.dev.yml up -d --build
```

### Problem: Cannot Access Frontend/Backend

**Check network connectivity:**

```bash
# Test frontend
curl http://localhost:3000

# Test backend
curl http://localhost:3001/api

# Check if containers are running
docker-compose -f docker-compose.dev.yml ps
```

## 📊 Monitoring and Debugging

### Health Monitoring

```bash
# Comprehensive health check
npm run docker:health:dev

# Quick status check
docker-compose -f docker-compose.dev.yml ps

# Resource usage
docker system df
```

### Log Analysis

```bash
# Follow all logs in real-time
docker-compose -f docker-compose.dev.yml logs -f

# Search logs for errors
docker-compose -f docker-compose.dev.yml logs | grep -i error

# Export logs to file
docker-compose -f docker-compose.dev.yml logs > dev-logs.txt
```

### Performance Monitoring

```bash
# Check container resource usage
docker stats

# Check specific container
docker stats aws-app-backend-dev-1
```

## 🔄 Making Code Changes

### Frontend Changes (React/Vite)

1. Edit files in `apps/web/src/`
2. Changes automatically reflected at http://localhost:3000
3. Check browser console for any errors

### Backend Changes (NestJS)

1. Edit files in `apps/backend/src/`
2. TypeScript compilation happens automatically
3. Server restarts automatically
4. Check logs with: `docker-compose -f docker-compose.dev.yml logs -f backend-dev`

### Shared Package Changes

1. Edit files in `packages/shared/src/`
2. Rebuild shared package: `docker-compose -f docker-compose.dev.yml exec backend-dev npm run build:shared`
3. Restart services: `docker-compose -f docker-compose.dev.yml restart`

## 🧹 Cleanup

### Daily Cleanup

```bash
# Stop development services
npm run docker:down:dev
```

### Deep Cleanup

```bash
# Full cleanup (removes images, volumes, networks)
npm run docker:cleanup

# Manual cleanup
docker system prune -af --volumes
```

## 📝 Quick Reference

### Most Used Commands

```bash
# Start development
npm run docker:deploy:dev

# Check status
npm run docker:health:dev

# View logs
npm run docker:logs:dev

# Stop services
npm run docker:down:dev

# Clean up
npm run docker:cleanup
```

### Service URLs

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:3001/api
- **Database**: localhost:5432 (user: postgres, db: aws_app_dev)
- **Redis**: localhost:6379

### File Structure

```
├── .env                        # Environment variables
├── docker-compose.dev.yml      # Development configuration
├── apps/web/Dockerfile.dev     # Frontend development image
├── apps/backend/Dockerfile.dev # Backend development image
└── docker/scripts/             # Utility scripts
```

## 🆘 Getting Help

If you encounter issues:

1. **Check logs**: `npm run docker:logs:dev`
2. **Check health**: `npm run docker:health:dev`
3. **Try cleanup**: `npm run docker:cleanup`
4. **Rebuild**: `npm run docker:build:dev`
5. **Check this guide**: Review troubleshooting section

---

**Happy Coding! 🚀**
