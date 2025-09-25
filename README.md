# AWS App - Complete Docker & CI/CD Setup

A full-stack application with comprehensive Docker containerization, CI/CD pipeline, and Docker Swarm orchestration.

## 🏗️ Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   React/Vite    │    │   NestJS API    │    │   PostgreSQL    │
│   Frontend      │◄──►│   Backend       │◄──►│   Database      │
│   (Port 80)     │    │   (Port 3001)   │    │   (Port 5432)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │     Redis       │
                    │    Cache        │
                    │  (Port 6379)    │
                    └─────────────────┘
```

## 🚀 Quick Start

### Local Development

```bash
# Install dependencies
npm run install:all

# Start development environment
docker-compose -f docker-compose.dev.yml up -d

# View logs
docker-compose -f docker-compose.dev.yml logs -f
```

### Production Deployment

```bash
# Build and start production
docker-compose up -d

# Monitor services
docker-compose ps
```

### Docker Swarm (Production)

```bash
# Initialize swarm and deploy
cd docker/swarm
./init-swarm.sh
./deploy-stack.sh

# Monitor cluster
./monitor-swarm.sh
```

## 📁 Project Structure

```
aws_app/
├── apps/
│   ├── backend/                 # NestJS API
│   │   ├── src/
│   │   ├── Dockerfile
│   │   ├── Dockerfile.dev
│   │   └── package.json
│   └── web/                     # React Frontend
│       ├── src/
│       ├── Dockerfile
│       ├── Dockerfile.dev
│       └── package.json
├── packages/
│   └── shared/                  # Shared utilities
├── docker/
│   ├── nginx/
│   │   └── nginx.conf          # Reverse proxy config
│   └── swarm/                  # Swarm management scripts
│       ├── init-swarm.sh
│       ├── deploy-stack.sh
│       ├── monitor-swarm.sh
│       ├── update-stack.sh
│       ├── cleanup.sh
│       └── README.md
├── docker-compose.yml          # Production compose
├── docker-compose.dev.yml      # Development compose
├── docker-stack.yml            # Docker Swarm stack
├── Jenkinsfile                 # CI/CD pipeline
└── README.md
```

## 🐳 Docker Configuration

### Multi-Stage Builds

- **Production**: Optimized builds with minimal runtime images
- **Development**: Volume mounts for hot reloading
- **Health Checks**: Built-in service health monitoring

### Container Services

- **Frontend**: Nginx serving React app (Port 80)
- **Backend**: NestJS API server (Port 3001)
- **Database**: PostgreSQL with persistent volumes
- **Cache**: Redis for session/caching
- **Proxy**: Nginx reverse proxy

## 🔧 Development Environment

### Features

- **Hot Reloading**: Real-time code changes
- **Volume Mounts**: Source code synchronization
- **Debug Ports**: Exposed for debugging
- **Health Checks**: Service status monitoring

### Commands

```bash
# Start development stack
docker-compose -f docker-compose.dev.yml up -d

# View specific service logs
docker-compose -f docker-compose.dev.yml logs -f backend

# Rebuild specific service
docker-compose -f docker-compose.dev.yml up -d --build backend

# Stop services
docker-compose -f docker-compose.dev.yml down
```

## 🚀 Production Deployment

### Docker Compose (Single Host)

```bash
# Build and deploy
docker-compose up -d

# Scale services
docker-compose up -d --scale backend=3 --scale web=2

# Update service
docker-compose up -d --build backend
```

### Docker Swarm (Multi-Host)

```bash
# Initialize cluster
./docker/swarm/init-swarm.sh

# Deploy application stack
./docker/swarm/deploy-stack.sh

# Monitor cluster
./docker/swarm/monitor-swarm.sh

# Perform rolling updates
./docker/swarm/update-stack.sh

# Scale services
docker service scale aws-app-stack_backend=5
```

## 🔄 CI/CD Pipeline (Jenkins)

### Pipeline Stages

1. **Checkout**: Source code retrieval
2. **Install**: Dependencies installation
3. **Build**: Application compilation
4. **Test**: Unit and integration tests
5. **Security Scan**: Vulnerability assessment
6. **Docker Build**: Multi-arch image creation
7. **Deploy**: Docker Swarm deployment

### Jenkins Setup

```bash
# Required plugins
- Pipeline
- Docker Pipeline
- NodeJS
- OWASP Dependency Check

# Environment variables
DOCKER_REGISTRY=your-registry.com
DOCKER_REPO=aws-app
SWARM_MANAGER=your-swarm-manager
```

### Pipeline Configuration

The `Jenkinsfile` includes:

- Parallel builds for frontend/backend
- Automated testing and quality gates
- Security vulnerability scanning
- Multi-architecture Docker builds
- Zero-downtime deployment to Docker Swarm

## 📊 Monitoring & Management

### Health Checks

- **Frontend**: HTTP GET / (200 response)
- **Backend**: HTTP GET /api/health (JSON response)
- **Database**: PostgreSQL connection test
- **Redis**: Redis PING command

### Monitoring Tools

```bash
# Service status
docker-compose ps                    # Docker Compose
./docker/swarm/monitor-swarm.sh     # Docker Swarm

# Service logs
docker-compose logs -f backend      # Docker Compose
docker service logs aws-app-stack_backend  # Docker Swarm

# Resource usage
docker stats                        # Container resources
docker system df                    # Disk usage
```

### Management Scripts

- `monitor-swarm.sh`: Comprehensive cluster monitoring
- `update-stack.sh`: Rolling updates with health checks
- `cleanup.sh`: Interactive cleanup with multiple options
- `init-swarm.sh`: Swarm initialization and setup
- `deploy-stack.sh`: Application deployment

## 🔒 Security Features

### Container Security

- Non-root user execution
- Multi-stage builds (minimal attack surface)
- Health checks and restart policies
- Resource limits and constraints

### Network Security

- Isolated overlay networks
- Internal service communication
- Reverse proxy for external access
- Database not exposed externally

### Secrets Management

- Docker secrets for sensitive data
- Environment-specific configurations
- Encrypted swarm communication
- Registry authentication

## 🌍 Environment Configuration

### Development

- Hot reloading enabled
- Debug ports exposed
- Verbose logging
- Development dependencies included

### Production

- Optimized builds
- Health monitoring
- Resource constraints
- Security hardening
- Horizontal scaling

### Variables

```bash
# Database
POSTGRES_USER=postgres
POSTGRES_PASSWORD=password
POSTGRES_DB=aws_app

# Redis
REDIS_URL=redis://redis:6379

# API
API_URL=http://backend:3001
```

## 🔧 Troubleshooting

### Common Issues

#### API Connection Failed

```bash
# Check network connectivity
docker network ls
docker network inspect aws_app_backend-network

# Verify service names in code match docker-compose services
# Use service names (backend, redis, db) not localhost
```

#### Database Connection Issues

```bash
# Check database status
docker-compose logs db

# Verify connection string
# Should use service name: postgresql://postgres:password@db:5432/aws_app
```

#### Service Won't Start

```bash
# Check resource limits
docker stats

# Review service logs
docker-compose logs service-name

# Inspect service configuration
docker-compose config
```

### Debug Commands

```bash
# Shell into container
docker-compose exec backend sh
docker-compose exec web sh

# Test internal connectivity
docker-compose exec backend ping db
docker-compose exec web curl http://backend:3001/api/health

# Check port bindings
docker-compose ps
netstat -tulpn | grep LISTEN
```

│ ## 📈 Performance Optimization

### Resource Management

```yaml
# docker-compose.yml
services:
  backend:
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 1G
        reservations:
          cpus: '0.5'
          memory: 512M
```

### Scaling Strategies

```bash
# Horizontal scaling
docker-compose up -d --scale backend=3

# Docker Swarm auto-scaling
docker service scale aws-app-stack_backend=5
```

### Caching

- Redis for session storage
- Application-level caching
- CDN for static assets
- Database query optimization

## 🚀 Deployment Strategies

### Blue-Green Deployment

```bash
# Deploy new version alongside current
docker service create --name aws-app-stack_backend-green ...

# Switch traffic
docker service update --label-add version=active aws-app-stack_backend-green
```

### Rolling Updates

```bash
# Automated rolling update
./docker/swarm/update-stack.sh

# Manual rolling update
docker service update --image new-image:tag aws-app-stack_backend
```

### Canary Deployment

```bash
# Deploy canary version
docker service create --replicas 1 --name backend-canary ...

# Gradually increase traffic
docker service scale backend-canary=2
docker service scale backend=2
```

## 📋 Maintenance

### Regular Tasks

- [ ] Monitor resource usage
- [ ] Review application logs
- [ ] Update dependencies
- [ ] Security vulnerability scans
- [ ] Database maintenance
- [ ] Backup verification

### Updates

```bash
# Update application
./docker/swarm/update-stack.sh

# Update system packages
docker system prune -f
docker image prune -f
```

### Backup

```bash
# Database backup
docker exec postgres-container pg_dump -U postgres aws_app > backup.sql

# Configuration backup
tar -czf config-backup.tar.gz docker-compose.yml docker-stack.yml
```

## 🆘 Support

For issues and questions:

1. **Check logs**: Use monitoring scripts or docker logs
2. **Review documentation**: Service-specific READMEs
3. **Test locally**: Reproduce issues in development
4. **Monitor resources**: Check system performance
5. **Verify configuration**: Validate compose/stack files

### Useful Resources

- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Docker Swarm Documentation](https://docs.docker.com/engine/swarm/)
- [NestJS Documentation](https://nestjs.com/)
- [React Documentation](https://reactjs.org/)

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

````

## Getting Started

### Prerequisites

- Node.js >= 18.0.0
- npm >= 9.0.0

### Quick Setup

Run the setup script to install dependencies and build the shared package:

```bash
./setup.sh
````

Or manually:

```bash
npm install
npm run build:shared
```

### Development

Start all applications in development mode:

```bash
npm run dev
```

This will start:

- React frontend on http://localhost:3000
- NestJS backend on http://localhost:3001/api
- TypeScript compilation in watch mode for shared package

Or run them individually:

```bash
# Frontend only
npm run dev:web

# Backend only
npm run dev:backend

# Shared package compilation in watch mode
npm run dev:shared
```

### Building

Build all applications:

```bash
npm run build
```

Or build individually:

```bash
npm run build:shared  # Build first (required by other apps)
npm run build:web
npm run build:backend
```

### Testing

Run tests across all workspaces:

```bash
npm test
```

Run tests for specific apps:

```bash
npm run test:web
npm run test:backend
```

### Linting

Lint all code:

```bash
npm run lint
```

Auto-fix linting issues:

```bash
npm run lint:fix
```

## Applications

- **Frontend (apps/web)**: React application built with Vite and TypeScript
- **Backend (apps/backend)**: NestJS application with TypeScript
- **Shared (packages/shared)**: Common utilities and type definitions

## Scripts

- `dev` - Start both applications in development mode
- `build` - Build both applications
- `test` - Run tests across all workspaces
- `lint` - Lint all workspaces
- `clean` - Clean build artifacts

To run in fresh

```bash
# Update package index
sudo apt update

# Install curl if not already installed
sudo apt install -y curl

# Add NodeSource repository for Node.js 20.x (LTS)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -

# Install Node.js
sudo apt install -y nodejs

# Verify installation
node --version
npm --version
```

```bash
./setup.sh
```
