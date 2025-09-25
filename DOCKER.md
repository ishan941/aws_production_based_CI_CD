# Docker Setup Guide

This document explains how to use Docker with your AWS App monorepo.

## Prerequisites

- Docker and Docker Compose installed
- Node.js 20+ (for local development)
- Git (for deployment scripts)

## Quick Start

### 1. Environment Setup

```bash
# Copy environment template
cp .env.example .env

# Edit environment variables
nano .env
```

```bash
chmod +x docker/scripts/health-check.sh

```

### 2. Development Environment

```bash
# Start development environment
npm run docker:deploy:dev

# Or manually
docker-compose -f docker-compose.dev.yml up -d --build
```

### 3. Production Environment

```bash
# Start production environment
npm run docker:deploy

# Or manually
docker-compose up -d --build
```

## Available Docker Scripts

### Build Commands

- `npm run docker:build` - Build production images
- `npm run docker:build:dev` - Build development images

### Deployment Commands

- `npm run docker:deploy` - Deploy production environment
- `npm run docker:deploy:dev` - Deploy development environment

### Container Management

- `npm run docker:up` - Start production containers
- `npm run docker:up:dev` - Start development containers
- `npm run docker:down` - Stop production containers
- `npm run docker:down:dev` - Stop development containers

### Monitoring Commands

- `npm run docker:logs` - View production logs
- `npm run docker:logs:dev` - View development logs
- `npm run docker:health` - Check production health
- `npm run docker:health:dev` - Check development health

### Maintenance Commands

- `npm run docker:cleanup` - Clean up Docker resources

## Services

### Production Environment

- **Frontend**: http://localhost (port 80)
- **Backend**: http://localhost:3001
- **Database**: PostgreSQL (internal)
- **Cache**: Redis (internal)

### Development Environment

- **Frontend**: http://localhost:3000
- **Backend**: http://localhost:3001
- **Database**: PostgreSQL (localhost:5432)
- **Cache**: Redis (localhost:6379)

## File Structure

```
├── .dockerignore              # Docker ignore patterns
├── .env.example              # Environment template
├── docker-compose.yml        # Production compose
├── docker-compose.dev.yml    # Development compose
├── docker/
│   └── scripts/
│       ├── build.sh          # Build script
│       ├── deploy.sh         # Deployment script
│       ├── cleanup.sh        # Cleanup script
│       └── health-check.sh   # Health check script
├── apps/
│   ├── web/
│   │   ├── Dockerfile        # Production frontend
│   │   ├── Dockerfile.dev    # Development frontend
│   │   └── nginx.conf        # Nginx configuration
│   └── backend/
│       ├── Dockerfile        # Production backend
│       └── Dockerfile.dev    # Development backend
```

## Environment Variables

Required environment variables in `.env`:

```bash
# Database
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your_secure_password
POSTGRES_DB=aws_app

# Security
JWT_SECRET=your_jwt_secret_32_chars_minimum
SESSION_SECRET=your_session_secret_32_chars_minimum

# Application
NODE_ENV=production
PORT=3001
```

## Docker Commands Reference

### Basic Operations

```bash
# View running containers
docker-compose ps

# View logs
docker-compose logs -f [service_name]

# Execute command in container
docker-compose exec [service_name] sh

# Restart service
docker-compose restart [service_name]

# Scale service
docker-compose up -d --scale backend=3
```

### Development Workflow

```bash
# Start development with live reload
npm run docker:deploy:dev

# View development logs
npm run docker:logs:dev

# Stop development environment
npm run docker:down:dev
```

### Production Deployment

```bash
# Deploy to production
npm run docker:deploy

# Check health status
npm run docker:health

# View production logs
npm run docker:logs
```

### Troubleshooting

```bash
# Check container health
docker-compose ps
docker inspect [container_name]

# View detailed logs
docker-compose logs --tail=100 -f [service_name]

# Rebuild specific service
docker-compose build --no-cache [service_name]

# Clean up everything and restart
npm run docker:cleanup
npm run docker:deploy
```

## Security Considerations

1. **Environment Variables**: Never commit `.env` files
2. **Database**: Use strong passwords in production
3. **Secrets**: Rotate JWT and session secrets regularly
4. **Network**: Use reverse proxy (nginx) in production
5. **Updates**: Keep base images updated

## Performance Optimization

1. **Multi-stage builds**: Reduces image size
2. **Layer caching**: Optimizes build time
3. **Volume mounts**: For development hot-reload
4. **Health checks**: Ensures service availability
5. **Resource limits**: Prevent resource exhaustion

## Deployment on EC2

### Install Docker on EC2

```bash
# Update system
sudo apt update

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker ubuntu

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Logout and login to refresh groups
```

### EC2 Security Groups

Add these inbound rules:

- HTTP (80): 0.0.0.0/0
- Custom TCP (3001): 0.0.0.0/0
- Custom TCP (3000): 0.0.0.0/0 (development only)

### Deploy on EC2

```bash
# Clone repository
git clone https://github.com/your-username/your-repo.git
cd your-repo

# Setup environment
cp .env.example .env
nano .env

# Deploy
npm run docker:deploy
```

## Monitoring and Logs

### Health Checks

```bash
# Check all services
npm run docker:health

# Check specific service
docker-compose exec backend curl http://localhost:3001/health
```

### Log Management

```bash
# Follow all logs
npm run docker:logs

# Follow specific service
docker-compose logs -f backend

# View last 100 lines
docker-compose logs --tail=100 backend
```

## Backup and Restore

### Database Backup

```bash
# Backup
docker-compose exec postgres pg_dump -U postgres aws_app > backup.sql

# Restore
docker-compose exec -T postgres psql -U postgres aws_app < backup.sql
```

### Volume Backup

```bash
# Create backup
docker run --rm -v aws_app_postgres_data:/data -v $(pwd):/backup alpine tar czf /backup/postgres_backup.tar.gz -C /data .

# Restore backup
docker run --rm -v aws_app_postgres_data:/data -v $(pwd):/backup alpine tar xzf /backup/postgres_backup.tar.gz -C /data
```

## Support

For issues or questions:

1. Check logs: `npm run docker:logs`
2. Check health: `npm run docker:health`
3. Try cleanup: `npm run docker:cleanup`
4. Review environment variables in `.env`
