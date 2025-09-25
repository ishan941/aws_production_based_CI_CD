#!/bin/bash

STACK_NAME="aws-app-stack"

echo "🗑️  Cleanup Script for AWS App Docker Swarm"
echo "============================================="

# Function to confirm action
confirm_action() {
    local action=$1
    read -p "Are you sure you want to $action? (y/N): " confirm
    [[ $confirm =~ ^[Yy]$ ]]
}

# Show current status
echo "📊 Current Docker Swarm Status:"
echo ""
echo "Stacks:"
docker stack ls
echo ""
echo "Services:"
docker service ls
echo ""
echo "Networks:"
docker network ls --filter driver=overlay
echo ""
echo "Volumes:"
docker volume ls

echo ""
echo "🎯 Cleanup Options:"
echo "1. Remove stack only (keep images and volumes)"
echo "2. Remove stack + unused images"
echo "3. Remove stack + unused images + volumes"
echo "4. Full cleanup (everything including swarm)"
echo "5. Cancel"
echo ""

read -p "Choose option (1-5): " choice

case $choice in
    1)
        echo ""
        echo "🗑️  Option 1: Removing stack only"
        if confirm_action "remove the stack '$STACK_NAME'"; then
            docker stack rm "$STACK_NAME"
            echo "✅ Stack removed"
            
            echo "⏳ Waiting for services to be removed..."
            while docker service ls | grep -q "$STACK_NAME"; do
                sleep 2
                echo -n "."
            done
            echo ""
            echo "✅ All services removed"
        fi
        ;;
        
    2)
        echo ""
        echo "🗑️  Option 2: Removing stack + unused images"
        if confirm_action "remove the stack and prune unused images"; then
            docker stack rm "$STACK_NAME"
            echo "✅ Stack removed"
            
            echo "⏳ Waiting for services to be removed..."
            while docker service ls | grep -q "$STACK_NAME"; do
                sleep 2
                echo -n "."
            done
            echo ""
            
            echo "🧹 Pruning unused images..."
            docker image prune -f
            echo "✅ Unused images removed"
        fi
        ;;
        
    3)
        echo ""
        echo "🗑️  Option 3: Removing stack + unused images + volumes"
        if confirm_action "remove the stack, unused images, and unused volumes"; then
            docker stack rm "$STACK_NAME"
            echo "✅ Stack removed"
            
            echo "⏳ Waiting for services to be removed..."
            while docker service ls | grep -q "$STACK_NAME"; do
                sleep 2
                echo -n "."
            done
            echo ""
            
            echo "🧹 Pruning unused images..."
            docker image prune -f
            echo "✅ Unused images removed"
            
            echo "🧹 Pruning unused volumes..."
            docker volume prune -f
            echo "✅ Unused volumes removed"
            
            echo "🧹 Pruning unused networks..."
            docker network prune -f
            echo "✅ Unused networks removed"
        fi
        ;;
        
    4)
        echo ""
        echo "🗑️  Option 4: Full cleanup (WARNING: This will remove everything!)"
        echo "⚠️  This will:"
        echo "   - Remove the stack"
        echo "   - Remove all unused images, volumes, networks"
        echo "   - Leave the swarm cluster"
        echo "   - Remove all stopped containers"
        echo ""
        if confirm_action "perform FULL cleanup (this cannot be undone)"; then
            # Remove stack
            if docker stack ls | grep -q "$STACK_NAME"; then
                docker stack rm "$STACK_NAME"
                echo "✅ Stack removed"
                
                echo "⏳ Waiting for services to be removed..."
                while docker service ls | grep -q "$STACK_NAME"; do
                    sleep 2
                    echo -n "."
                done
                echo ""
            fi
            
            # System cleanup
            echo "🧹 Full system cleanup..."
            docker system prune -a -f --volumes
            echo "✅ System cleanup completed"
            
            # Leave swarm
            if docker info | grep -q "Swarm: active"; then
                echo "🚪 Leaving swarm..."
                docker swarm leave --force
                echo "✅ Left swarm cluster"
            fi
        fi
        ;;
        
    5)
        echo "❌ Cleanup cancelled"
        exit 0
        ;;
        
    *)
        echo "❌ Invalid option"
        exit 1
        ;;
esac

echo ""
echo "📊 Cleanup Summary:"
echo "Current Docker status:"
echo ""
echo "Images:"
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
echo ""
echo "Volumes:"
docker volume ls
echo ""
echo "Networks:"
docker network ls
echo ""

if docker info | grep -q "Swarm: active"; then
    echo "Swarm Status: Active"
    docker node ls
else
    echo "Swarm Status: Inactive"
fi

echo ""
echo "✅ Cleanup completed!"
echo ""
echo "💡 To restart the application:"
echo "   1. Initialize swarm: ./init-swarm.sh"
echo "   2. Deploy stack: ./deploy-stack.sh"