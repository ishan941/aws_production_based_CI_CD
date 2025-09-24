#!/bin/bash

echo "🧹 Cleaning up Docker resources..."

# Stop all containers
echo "⏹️  Stopping all containers..."
docker-compose down 2>/dev/null
docker-compose -f docker-compose.dev.yml down 2>/dev/null

# Remove unused containers, networks, images and volumes
echo "🗑️  Removing unused Docker resources..."
docker system prune -af --volumes

# Remove specific project images
echo "🖼️  Removing project-specific images..."
docker images | grep aws-app | awk '{print $3}' | xargs docker rmi -f 2>/dev/null

# Remove specific volumes
echo "💾 Removing project volumes..."
docker volume ls | grep aws-app | awk '{print $2}' | xargs docker volume rm 2>/dev/null

echo "✅ Docker cleanup completed!"

echo ""
echo "📊 Remaining Docker resources:"
echo "Images:"
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
echo ""
echo "Volumes:"
docker volume ls
echo ""
echo "Networks:"
docker network ls