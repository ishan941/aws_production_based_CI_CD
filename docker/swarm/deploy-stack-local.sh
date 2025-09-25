#!/bin/bash

echo "🚀 Deploying AWS App to Docker Swarm (Local Development)..."

# Check if Docker Swarm is active
if ! docker info | grep -q "Swarm: active"; then
    echo "❌ Docker Swarm is not active. Please run init-swarm.sh first."
    exit 1
fi

# Check if we need to build local images
if [[ ! $(docker images -q aws-app-backend:local 2> /dev/null) ]] || [[ ! $(docker images -q aws-app-frontend:local 2> /dev/null) ]]; then
    echo "🔨 Building local images..."
    
    # Build backend image
    echo "Building backend image..."
    docker build -f ../apps/backend/Dockerfile -t aws-app-backend:local ../..
    
    # Build frontend image  
    echo "Building frontend image..."
    docker build -f ../apps/web/Dockerfile -t aws-app-frontend:local ../..
    
    echo "✅ Images built successfully"
fi

# Deploy the stack with local images
echo "📦 Deploying stack with local images..."

# Set environment variables for local deployment
export DOCKER_REGISTRY=""
export DOCKER_REPOSITORY="aws-app"
export IMAGE_TAG="local"

# Create a temporary stack file for local deployment
cat > docker-stack-local.yml << 'EOF'
version: '3.8'

services:
  web:
    image: aws-app-frontend:local
    ports:
      - '80:80'
    environment:
      - NODE_ENV=production
      - VITE_API_URL=http://localhost:3001
    networks:
      - aws-app-network
    deploy:
      replicas: 1
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.1'
          memory: 256M
    healthcheck:
      test: ['CMD', 'wget', '--no-verbose', '--tries=1', '--spider', 'http://localhost/']
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  backend:
    image: aws-app-backend:local
    ports:
      - '3001:3001'
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://postgres:password@db:5432/aws_app
      - REDIS_URL=redis://redis:6379
      - JWT_SECRET=your-jwt-secret-key
      - PORT=3001
    networks:
      - aws-app-network
    depends_on:
      - db
      - redis
    deploy:
      replicas: 1
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: '1.0'
          memory: 1G
        reservations:
          cpus: '0.2'
          memory: 512M
    healthcheck:
      test: ['CMD', 'curl', '-f', 'http://localhost:3001/api/health']
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  db:
    image: postgres:15-alpine
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
      - POSTGRES_DB=aws_app
    networks:
      - aws-app-network
    volumes:
      - postgres_data:/var/lib/postgresql/data
    deploy:
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.1'
          memory: 256M
    healthcheck:
      test: ['CMD-SHELL', 'pg_isready -U postgres']
      interval: 30s
      timeout: 10s
      retries: 5

  redis:
    image: redis:7-alpine
    command: redis-server --appendonly yes
    networks:
      - aws-app-network
    volumes:
      - redis_data:/data
    deploy:
      replicas: 1
      placement:
        constraints:
          - node.role == manager
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
      resources:
        limits:
          cpus: '0.2'
          memory: 256M
        reservations:
          cpus: '0.05'
          memory: 128M
    healthcheck:
      test: ['CMD', 'redis-cli', 'ping']
      interval: 30s
      timeout: 10s
      retries: 3

networks:
  aws-app-network:
    driver: overlay
    attachable: true

volumes:
  postgres_data:
    driver: local
  redis_data:
    driver: local
EOF

# Deploy the stack
docker stack deploy -c docker-stack-local.yml aws-app-stack

if [ $? -eq 0 ]; then
    echo "✅ Stack deployed successfully!"
    
    # Wait a moment for services to start
    echo "⏳ Waiting for services to initialize..."
    sleep 10
    
    echo ""
    echo "📊 Service Status:"
    docker stack services aws-app-stack
    
    echo ""
    echo "🔍 Service Details:"
    docker stack ps aws-app-stack --no-trunc
    
    echo ""
    echo "🌐 Application URLs:"
    echo "   Frontend: http://localhost"
    echo "   Backend API: http://localhost:3001"
    echo "   Health Check: http://localhost:3001/api/health"
    
    echo ""
    echo "📋 Useful Commands:"
    echo "   Monitor: ./monitor-swarm.sh"
    echo "   Logs: docker service logs aws-app-stack_backend"
    echo "   Scale: docker service scale aws-app-stack_backend=3"
    echo "   Remove: docker stack rm aws-app-stack"
    
else
    echo "❌ Failed to deploy stack"
    exit 1
fi

# Clean up temporary file
rm -f docker-stack-local.yml

echo ""
echo "✅ Deployment completed!"