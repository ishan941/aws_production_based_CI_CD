#!/bin/bash

echo "🚁 Initializing Docker Swarm..."

# Check if Docker is running
if ! docker info >/dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker first."
    exit 1
fi

# Initialize Docker Swarm if not already initialized
if ! docker info | grep -q "Swarm: active"; then
    echo "🔧 Initializing Docker Swarm..."
    
    # Get the main IP address (cross-platform method)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        MAIN_IP=$(route get default | grep 'interface:' | awk '{print $2}' | head -1 | xargs ifconfig | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | head -1)
        if [ -z "$MAIN_IP" ]; then
            MAIN_IP=$(ifconfig en0 | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | head -1)
        fi
        if [ -z "$MAIN_IP" ]; then
            MAIN_IP="127.0.0.1"
        fi
    else
        # Linux
        MAIN_IP=$(hostname -I | awk '{print $1}')
    fi
    
    echo "🔍 Using IP address: $MAIN_IP"
    
    # Initialize swarm
    docker swarm init --advertise-addr $MAIN_IP
    
    if [ $? -eq 0 ]; then
        echo "✅ Docker Swarm initialized successfully"
        echo "📋 Manager IP: $MAIN_IP"
    else
        echo "❌ Failed to initialize Docker Swarm"
        exit 1
    fi
else
    echo "✅ Docker Swarm is already active"
fi

# Create overlay network if it doesn't exist
if ! docker network ls | grep -q "aws-app-network"; then
    echo "🌐 Creating overlay network..."
    docker network create --driver overlay --attachable aws-app-network
    echo "✅ Network created: aws-app-network"
else
    echo "✅ Network already exists: aws-app-network"
fi

# Create required directories for volumes (skip on macOS for local development)
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "📁 Creating volume directories..."
    sudo mkdir -p /opt/aws-app/postgres
    sudo mkdir -p /opt/aws-app/redis
    sudo chown -R $USER:$USER /opt/aws-app/
    echo "✅ Volume directories created"
else
    echo "📁 Skipping volume directories creation on macOS (using Docker volumes)"
fi

# Create Docker secrets if they don't exist
echo "🔐 Setting up Docker secrets..."

# Function to create secret if it doesn't exist
create_secret() {
    local secret_name=$1
    local secret_value=$2
    
    if ! docker secret ls | grep -q "$secret_name"; then
        echo "$secret_value" | docker secret create "$secret_name" -
        echo "✅ Created secret: $secret_name"
    else
        echo "✅ Secret already exists: $secret_name"
    fi
}

# Generate random secrets if not provided via environment variables
JWT_SECRET=${JWT_SECRET:-$(openssl rand -base64 32)}
SESSION_SECRET=${SESSION_SECRET:-$(openssl rand -base64 32)}
DB_PASSWORD=${POSTGRES_PASSWORD:-$(openssl rand -base64 16)}
REDIS_PASSWORD=${REDIS_PASSWORD:-$(openssl rand -base64 16)}

# Create secrets
create_secret "jwt_secret" "$JWT_SECRET"
create_secret "session_secret" "$SESSION_SECRET"
create_secret "db_password" "$DB_PASSWORD"
create_secret "redis_password" "$REDIS_PASSWORD"

# Display join tokens
echo ""
echo "🔗 Docker Swarm Join Tokens:"
echo "============================================"
echo "Manager Token:"
docker swarm join-token manager | grep "docker swarm join"

echo ""
echo "Worker Token:"
docker swarm join-token worker | grep "docker swarm join"

echo ""
echo "📊 Swarm Status:"
docker node ls

echo ""
echo "✅ Docker Swarm setup completed!"
echo ""
echo "📋 Next steps:"
echo "1. Add worker nodes using the worker join token above"
echo "2. Deploy your stack using: docker stack deploy -c docker-stack.yml aws-app-stack"
echo "3. Monitor services with: docker stack services aws-app-stack"