#!/bin/bash

echo "🚀 Deploying application..."

# Check if environment file exists
if [ ! -f .env ]; then
    echo "⚠️  .env file not found. Creating from template..."
    cp .env.example .env
    echo "📝 Please edit .env file with your actual values"
    echo "Then run this script again"
    exit 1
fi

# Check if we're deploying development or production
if [ "$1" = "dev" ]; then
    echo "🔧 Deploying development environment..."
    
    # Stop existing containers
    docker-compose -f docker-compose.dev.yml down
    
    # Build and start containers
    docker-compose -f docker-compose.dev.yml up -d --build
    
    if [ $? -eq 0 ]; then
        echo "✅ Development environment deployed successfully!"
        echo ""
        echo "🌐 Application URLs:"
        echo "  Frontend: http://localhost:3000"
        echo "  Backend:  http://localhost:3001"
        echo "  Database: localhost:5432"
        echo "  Redis:    localhost:6379"
        echo ""
        echo "📊 Container status:"
        docker-compose -f docker-compose.dev.yml ps
    else
        echo "❌ Failed to deploy development environment"
        exit 1
    fi
else
    echo "🏭 Deploying production environment..."
    
    # Stop existing containers
    docker-compose down
    
    # Pull latest changes (if in git repo)
    if [ -d .git ]; then
        echo "📥 Pulling latest changes..."
        git pull origin main
    fi
    
    # Build and start containers
    docker-compose up -d --build
    
    if [ $? -eq 0 ]; then
        echo "✅ Production environment deployed successfully!"
        echo ""
        echo "🌐 Application URLs:"
        if command -v curl &> /dev/null; then
            PUBLIC_IP=$(curl -s http://checkip.amazonaws.com 2>/dev/null || echo "localhost")
            echo "  Frontend: http://$PUBLIC_IP"
            echo "  Backend:  http://$PUBLIC_IP:3001"
        else
            echo "  Frontend: http://localhost"
            echo "  Backend:  http://localhost:3001"
        fi
        echo ""
        echo "📊 Container status:"
        docker-compose ps
    else
        echo "❌ Failed to deploy production environment"
        exit 1
    fi
fi

echo ""
echo "📋 Useful commands:"
echo "  docker-compose logs -f           # View logs"
echo "  docker-compose down              # Stop services"
echo "  docker-compose ps                # View running containers"
echo "  docker system prune -f           # Clean up unused resources"