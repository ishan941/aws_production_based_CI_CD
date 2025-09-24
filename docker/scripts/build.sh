#!/bin/bash

echo "🐳 Building Docker images..."

# Check if we're building for development or production
if [ "$1" = "dev" ]; then
    echo "📦 Building development images..."
    docker-compose -f docker-compose.dev.yml build --no-cache
    if [ $? -eq 0 ]; then
        echo "✅ Development Docker images built successfully!"
    else
        echo "❌ Failed to build development Docker images"
        exit 1
    fi
else
    echo "📦 Building production images..."
    docker-compose build --no-cache
    if [ $? -eq 0 ]; then
        echo "✅ Production Docker images built successfully!"
    else
        echo "❌ Failed to build production Docker images"
        exit 1
    fi
fi

echo ""
echo "📊 Docker images:"
docker images | grep aws-app
