#!/bin/bash

STACK_NAME="aws-app-stack"

echo "🔄 Rolling Update Script for AWS App"
echo "===================================="

# Check if stack exists
if ! docker stack ls | grep -q "$STACK_NAME"; then
    echo "❌ Stack '$STACK_NAME' not found"
    echo "Available stacks:"
    docker stack ls
    exit 1
fi

# Function to wait for service to be ready
wait_for_service() {
    local service_name=$1
    local timeout=${2:-300}  # 5 minutes default
    local count=0
    
    echo "⏳ Waiting for $service_name to be ready..."
    
    while [ $count -lt $timeout ]; do
        replicas=$(docker service ls --filter name="$service_name" --format "{{.Replicas}}")
        if [[ $replicas =~ ^([0-9]+)/\1$ ]]; then
            echo "✅ $service_name is ready ($replicas)"
            return 0
        fi
        
        sleep 2
        count=$((count + 2))
        
        # Show progress every 30 seconds
        if [ $((count % 30)) -eq 0 ]; then
            echo "   Still waiting... ($replicas) - ${count}s elapsed"
        fi
    done
    
    echo "❌ Timeout waiting for $service_name"
    return 1
}

# Function to update a service
update_service() {
    local service=$1
    local image=$2
    
    echo "🔄 Updating $service with image $image"
    
    docker service update \
        --image "$image" \
        --update-parallelism 1 \
        --update-delay 10s \
        --update-failure-action rollback \
        --update-monitor 60s \
        "$service"
    
    if wait_for_service "$service"; then
        echo "✅ $service updated successfully"
        return 0
    else
        echo "❌ $service update failed"
        return 1
    fi
}

# Main update process
echo "📋 Current stack status:"
docker stack services "$STACK_NAME"

echo ""
read -p "Enter the Docker Registry URL (e.g., your-registry.com): " REGISTRY
read -p "Enter the image tag/version (e.g., v1.0.1): " VERSION

if [ -z "$REGISTRY" ] || [ -z "$VERSION" ]; then
    echo "❌ Registry and version are required"
    exit 1
fi

FRONTEND_IMAGE="$REGISTRY/aws-app-frontend:$VERSION"
BACKEND_IMAGE="$REGISTRY/aws-app-backend:$VERSION"

echo ""
echo "🎯 Planning to update:"
echo "   Frontend: $FRONTEND_IMAGE"
echo "   Backend: $BACKEND_IMAGE"
echo ""

read -p "Continue with update? (y/N): " confirm
if [[ ! $confirm =~ ^[Yy]$ ]]; then
    echo "❌ Update cancelled"
    exit 0
fi

echo ""
echo "🚀 Starting rolling update..."

# Update backend first
echo ""
echo "Step 1: Updating backend service..."
if update_service "${STACK_NAME}_backend" "$BACKEND_IMAGE"; then
    echo "✅ Backend update completed"
else
    echo "❌ Backend update failed - stopping"
    exit 1
fi

# Update frontend
echo ""
echo "Step 2: Updating frontend service..."
if update_service "${STACK_NAME}_web" "$FRONTEND_IMAGE"; then
    echo "✅ Frontend update completed"
else
    echo "❌ Frontend update failed"
    exit 1
fi

# Health check after update
echo ""
echo "🔍 Performing post-update health check..."

sleep 10  # Wait a bit for services to stabilize

# Test endpoints
echo "Testing application health..."

if curl -f -s http://localhost:3001/api/health >/dev/null 2>&1; then
    echo "✅ Backend health check passed"
else
    echo "❌ Backend health check failed"
fi

if curl -f -s http://localhost/ >/dev/null 2>&1; then
    echo "✅ Frontend health check passed"
else
    echo "❌ Frontend health check failed"
fi

echo ""
echo "📊 Final stack status:"
docker stack services "$STACK_NAME"

echo ""
echo "🔄 Update history:"
docker service logs --tail 5 "${STACK_NAME}_backend" | grep -i update || echo "No update logs found"

echo ""
echo "✅ Rolling update completed!"
echo ""
echo "💡 Useful commands:"
echo "   View logs: docker service logs ${STACK_NAME}_backend"
echo "   Rollback: docker service rollback ${STACK_NAME}_backend"
echo "   Monitor: ./monitor-swarm.sh"