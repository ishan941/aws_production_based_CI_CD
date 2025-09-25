#!/bin/bash

STACK_NAME="aws-app-stack"

echo "📊 Docker Swarm Monitoring Dashboard"
echo "===================================="

# Check if swarm is active
if ! docker info | grep -q "Swarm: active"; then
    echo "❌ Docker Swarm is not active"
    exit 1
fi

# Function to display section headers
print_header() {
    echo ""
    echo "🔹 $1"
    echo "----------------------------------------"
}

# Swarm Overview
print_header "Swarm Nodes"
docker node ls

# Stack Services
if docker stack ls | grep -q "$STACK_NAME"; then
    print_header "Stack Services"
    docker stack services "$STACK_NAME"
    
    print_header "Service Details"
    docker stack ps "$STACK_NAME" --no-trunc
    
    # Service Health Check
    print_header "Service Health Status"
    for service in $(docker stack services "$STACK_NAME" --format "{{.Name}}"); do
        replicas=$(docker service ls --filter name="$service" --format "{{.Replicas}}")
        echo "🔸 $service: $replicas"
    done
    
    # Resource Usage
    print_header "Resource Usage"
    docker system df
    
    # Recent Service Logs (last 10 lines)
    print_header "Recent Logs (Backend)"
    docker service logs --tail 10 "${STACK_NAME}_backend"
    
    print_header "Recent Logs (Frontend)"
    docker service logs --tail 10 "${STACK_NAME}_web"
    
    # Network Information
    print_header "Networks"
    docker network ls --filter driver=overlay
    
    # Volume Information
    print_header "Volumes"
    docker volume ls --filter driver=local
    
    # Health Check
    print_header "Health Check"
    echo "Testing application endpoints..."
    
    # Test frontend
    if curl -f -s http://localhost/ >/dev/null 2>&1; then
        echo "✅ Frontend: Healthy"
    else
        echo "❌ Frontend: Unhealthy"
    fi
    
    # Test backend
    if curl -f -s http://localhost:3001/api/health >/dev/null 2>&1; then
        echo "✅ Backend API: Healthy"
        # Get health details
        curl -s http://localhost:3001/api/health | jq . 2>/dev/null || curl -s http://localhost:3001/api/health
    else
        echo "❌ Backend API: Unhealthy"
    fi
    
else
    echo "⚠️  Stack '$STACK_NAME' is not deployed"
    echo "Available stacks:"
    docker stack ls
fi

print_header "System Information"
echo "Docker Version: $(docker --version)"
echo "System Uptime: $(uptime)"

# macOS compatible memory and disk usage
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    MEMORY_INFO=$(vm_stat | perl -ne '/page size of (\d+)/ and $size=$1; /Pages\s+free:\s+(\d+)/ and printf("Free: %.1fGB\n", $1 * $size / 1024 / 1024 / 1024); /Pages active:\s+(\d+)/ and printf("Active: %.1fGB\n", $1 * $size / 1024 / 1024 / 1024);')
    echo "Memory Usage: $MEMORY_INFO"
else
    # Linux
    echo "Memory Usage: $(free -h | grep Mem | awk '{print $3 "/" $2}')"
fi

echo "Disk Usage: $(df -h / | tail -1 | awk '{print $3 "/" $2 " (" $5 " used)"}')"

print_header "Quick Commands"
echo "🔸 View service logs: docker service logs ${STACK_NAME}_backend"
echo "🔸 Scale service: docker service scale ${STACK_NAME}_backend=5"
echo "🔸 Update service: docker service update ${STACK_NAME}_backend"
echo "🔸 Remove stack: docker stack rm $STACK_NAME"
echo "🔸 Leave swarm: docker swarm leave --force"

echo ""
echo "✅ Monitoring complete"