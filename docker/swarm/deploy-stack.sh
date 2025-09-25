#!/bin/bash

STACK_NAME="aws-app-stack"
COMPOSE_FILE="docker-stack.yml"

echo "🚀 Deploying AWS App to Docker Swarm..."

# Check if swarm is active
if ! docker info | grep -q "Swarm: active"; then
    echo "❌ Docker Swarm is not active. Please run init-swarm.sh first."
    exit 1
fi

# Check if compose file exists
if [ ! -f "$COMPOSE_FILE" ]; then
    echo "❌ Docker compose file not found: $COMPOSE_FILE"
    exit 1
fi

# Load environment variables
if [ -f ".env" ]; then
    echo "📝 Loading environment variables from .env"
    export $(cat .env | grep -v '^#' | xargs)
else
    echo "⚠️  No .env file found. Using default values."
fi

# Set default values if not provided
export DOCKER_REGISTRY=${DOCKER_REGISTRY:-"your-registry.com"}
export DOCKER_REPOSITORY=${DOCKER_REPOSITORY:-"aws-app"}
export IMAGE_TAG=${IMAGE_TAG:-"latest"}
export POSTGRES_USER=${POSTGRES_USER:-"postgres"}
export POSTGRES_DB=${POSTGRES_DB:-"aws_app"}

echo "🐳 Deployment Configuration:"
echo "Registry: $DOCKER_REGISTRY"
echo "Repository: $DOCKER_REPOSITORY"
echo "Image Tag: $IMAGE_TAG"
echo "Stack Name: $STACK_NAME"

# Deploy the stack
echo "📦 Deploying stack..."
docker stack deploy -c "$COMPOSE_FILE" "$STACK_NAME"

if [ $? -eq 0 ]; then
    echo "✅ Stack deployed successfully!"
else
    echo "❌ Failed to deploy stack"
    exit 1
fi

# Wait for services to start
echo "⏳ Waiting for services to start..."
sleep 30

# Check service status
echo "📊 Service Status:"
docker stack services "$STACK_NAME"

echo ""
echo "📋 Service Details:"
docker stack ps "$STACK_NAME"

# Check if services are running
RUNNING_SERVICES=$(docker stack services "$STACK_NAME" --format "{{.Replicas}}" | grep -c "^[1-9]")
TOTAL_SERVICES=$(docker stack services "$STACK_NAME" | wc -l)
TOTAL_SERVICES=$((TOTAL_SERVICES - 1)) # Subtract header line

echo ""
echo "📈 Status Summary:"
echo "Running Services: $RUNNING_SERVICES/$TOTAL_SERVICES"

if [ "$RUNNING_SERVICES" -eq "$TOTAL_SERVICES" ]; then
    echo "🎉 All services are running!"
    
    # Wait a bit more for health checks
    echo "⏳ Waiting for health checks..."
    sleep 60
    
    # Test endpoints
    echo "🧪 Testing endpoints..."
    
    # Get manager node IP
    MANAGER_IP=$(docker node ls --filter role=manager --format "{{.Hostname}}" | head -1)
    
    # Test frontend
    if curl -f -s http://localhost/ >/dev/null 2>&1; then
        echo "✅ Frontend is accessible"
    else
        echo "⚠️  Frontend might not be ready yet"
    fi
    
    # Test backend
    if curl -f -s http://localhost:3001/api/health >/dev/null 2>&1; then
        echo "✅ Backend API is healthy"
    else
        echo "⚠️  Backend API might not be ready yet"
    fi
    
else
    echo "⚠️  Some services are not running. Check logs with:"
    echo "docker service logs ${STACK_NAME}_backend"
    echo "docker service logs ${STACK_NAME}_web"
fi

echo ""
echo "🌐 Access URLs:"
echo "Frontend: http://$(curl -s http://checkip.amazonaws.com 2>/dev/null || echo 'localhost')"
echo "Backend API: http://$(curl -s http://checkip.amazonaws.com 2>/dev/null || echo 'localhost'):3001/api"

echo ""
echo "📋 Useful Commands:"
echo "View services: docker stack services $STACK_NAME"
echo "View service logs: docker service logs ${STACK_NAME}_backend"
echo "Scale backend: docker service scale ${STACK_NAME}_backend=5"
echo "Remove stack: docker stack rm $STACK_NAME"