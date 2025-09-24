#!/bin/bash

echo "🔍 Docker Health Check Status"
echo "============================="

# Function to check service health
check_service_health() {
    local service=$1
    local compose_file=$2
    
    if [ -n "$compose_file" ]; then
        status=$(docker-compose -f "$compose_file" ps -q "$service" 2>/dev/null)
    else
        status=$(docker-compose ps -q "$service" 2>/dev/null)
    fi
    
    if [ -n "$status" ]; then
        health=$(docker inspect --format='{{.State.Health.Status}}' "$status" 2>/dev/null)
        state=$(docker inspect --format='{{.State.Status}}' "$status" 2>/dev/null)
        
        if [ "$health" = "healthy" ] || [ "$state" = "running" ]; then
            echo "✅ $service: healthy"
        elif [ "$health" = "unhealthy" ]; then
            echo "❌ $service: unhealthy"
        elif [ "$state" = "running" ]; then
            echo "🟡 $service: running (no health check)"
        else
            echo "🔴 $service: $state"
        fi
    else
        echo "⚪ $service: not running"
    fi
}

# Check if development or production
if [ "$1" = "dev" ]; then
    echo "Development Environment:"
    echo ""
    check_service_health "web-dev" "docker-compose.dev.yml"
    check_service_health "backend-dev" "docker-compose.dev.yml"
    check_service_health "postgres-dev" "docker-compose.dev.yml"
    check_service_health "redis-dev" "docker-compose.dev.yml"
    
    echo ""
    echo "📊 Development containers:"
    docker-compose -f docker-compose.dev.yml ps
else
    echo "Production Environment:"
    echo ""
    check_service_health "web"
    check_service_health "backend"
    check_service_health "postgres"
    check_service_health "redis"
    
    echo ""
    echo "📊 Production containers:"
    docker-compose ps
fi

echo ""
echo "💾 Docker resource usage:"
docker system df

echo ""
echo "🌐 Network connectivity test:"
if command -v nc &> /dev/null; then
    if nc -z localhost 80 2>/dev/null; then
        echo "✅ Frontend (port 80): accessible"
    else
        echo "❌ Frontend (port 80): not accessible"
    fi
    
    if nc -z localhost 3000 2>/dev/null; then
        echo "✅ Frontend dev (port 3000): accessible"
    else
        echo "⚪ Frontend dev (port 3000): not accessible"
    fi
    
    if nc -z localhost 3001 2>/dev/null; then
        echo "✅ Backend (port 3001): accessible"
    else
        echo "❌ Backend (port 3001): not accessible"
    fi
else
    echo "⚠️  nc command not available, skipping network test"
fi