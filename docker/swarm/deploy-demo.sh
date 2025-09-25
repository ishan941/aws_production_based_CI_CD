#!/bin/bash

echo "🚀 Quick Docker Swarm Demo (No Build Required)..."

# Check if Docker Swarm is active
if ! docker info | grep -q "Swarm: active"; then
    echo "❌ Docker Swarm is not active. Please run init-swarm.sh first."
    exit 1
fi

# Deploy a simple stack to demonstrate swarm functionality
echo "📦 Deploying demo stack..."

cat > docker-stack-demo.yml << 'EOF'
version: '3.8'

services:
  nginx:
    image: nginx:alpine
    ports:
      - '8080:80'
    networks:
      - demo-network
    deploy:
      replicas: 2
      restart_policy:
        condition: on-failure
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: '0.2'
          memory: 128M
    healthcheck:
      test: ['CMD', 'wget', '--no-verbose', '--tries=1', '--spider', 'http://localhost/']
      interval: 30s
      timeout: 10s
      retries: 3

  hello-world:
    image: tutum/hello-world
    ports:
      - '8081:80'
    networks:
      - demo-network
    deploy:
      replicas: 1
      restart_policy:
        condition: on-failure
      placement:
        constraints:
          - node.role == manager
      resources:
        limits:
          cpus: '0.1'
          memory: 64M

networks:
  demo-network:
    driver: overlay
    attachable: true
EOF

# Deploy the demo stack
docker stack deploy -c docker-stack-demo.yml demo-stack

if [ $? -eq 0 ]; then
    echo "✅ Demo stack deployed successfully!"
    
    # Wait for services to start
    echo "⏳ Waiting for services to initialize..."
    sleep 15
    
    echo ""
    echo "📊 Service Status:"
    docker stack services demo-stack
    
    echo ""
    echo "🔍 Service Details:"
    docker stack ps demo-stack
    
    echo ""
    echo "🌐 Demo URLs:"
    echo "   Nginx: http://localhost:8080"
    echo "   Hello World: http://localhost:8081"
    
    echo ""
    echo "📋 Test Commands:"
    echo "   curl http://localhost:8080"
    echo "   curl http://localhost:8081"
    
    echo ""
    echo "🛠️  Management Commands:"
    echo "   Scale nginx: docker service scale demo-stack_nginx=4"
    echo "   View logs: docker service logs demo-stack_nginx"
    echo "   Remove stack: docker stack rm demo-stack"
    
else
    echo "❌ Failed to deploy demo stack"
    exit 1
fi

# Clean up temporary file
rm -f docker-stack-demo.yml

echo ""
echo "✅ Demo deployment completed!"
echo ""
echo "💡 Next steps:"
echo "1. Test the URLs above"
echo "2. Try scaling services"
echo "3. Use ./monitor-swarm.sh to monitor the cluster"
echo "4. When ready, remove with: docker stack rm demo-stack"