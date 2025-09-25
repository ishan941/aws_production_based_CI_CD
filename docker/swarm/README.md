# Docker Swarm Management Scripts

This directory contains management scripts for the AWS App Docker Swarm deployment.

## Scripts Overview

### 🚀 `init-swarm.sh`

Initializes Docker Swarm mode and sets up the cluster.

```bash
./init-swarm.sh
```

### 📦 `deploy-stack.sh`

Deploys the AWS App stack to the Docker Swarm cluster.

```bash
./deploy-stack.sh
```

### 🔄 `update-stack.sh`

Performs rolling updates of services with zero downtime.

```bash
./update-stack.sh
```

### 📊 `monitor-swarm.sh`

Comprehensive monitoring dashboard for the Docker Swarm cluster.

```bash
./monitor-swarm.sh
```

### 🗑️ `cleanup.sh`

Interactive cleanup script with multiple cleanup options.

```bash
./cleanup.sh
```

## Quick Start

1. **Initialize Swarm:**

   ```bash
   ./init-swarm.sh
   ```

2. **Deploy Application:**

   ```bash
   ./deploy-stack.sh
   ```

3. **Monitor Services:**
   ```bash
   ./monitor-swarm.sh
   ```

## Production Deployment

### Prerequisites

- Docker Swarm cluster setup
- Docker registry access
- Images built and pushed to registry

### Deployment Process

1. **Build and push images:**

   ```bash
   # Build images
   docker build -t your-registry/aws-app-backend:v1.0.0 -f apps/backend/Dockerfile .
   docker build -t your-registry/aws-app-frontend:v1.0.0 -f apps/web/Dockerfile .

   # Push to registry
   docker push your-registry/aws-app-backend:v1.0.0
   docker push your-registry/aws-app-frontend:v1.0.0
   ```

2. **Update docker-stack.yml with your registry:**

   ```yaml
   services:
     backend:
       image: your-registry/aws-app-backend:v1.0.0
     web:
       image: your-registry/aws-app-frontend:v1.0.0
   ```

3. **Deploy:**
   ```bash
   ./deploy-stack.sh
   ```

## Service Management

### Scaling Services

```bash
# Scale backend service
docker service scale aws-app-stack_backend=5

# Scale frontend service
docker service scale aws-app-stack_web=3
```

### View Logs

```bash
# Backend logs
docker service logs aws-app-stack_backend

# Frontend logs
docker service logs aws-app-stack_web

# Follow logs
docker service logs -f aws-app-stack_backend
```

### Service Updates

```bash
# Update service image
docker service update --image your-registry/aws-app-backend:v1.0.1 aws-app-stack_backend

# Or use the update script
./update-stack.sh
```

## Monitoring

### Health Checks

The stack includes health checks for all services:

- **Backend:** `GET /api/health`
- **Frontend:** HTTP 200 response
- **Database:** PostgreSQL connection check
- **Redis:** Redis ping command

### Monitoring Commands

```bash
# Service status
docker stack services aws-app-stack

# Service processes
docker stack ps aws-app-stack

# Node status
docker node ls

# System resources
docker system df
```

## Troubleshooting

### Service Not Starting

1. Check service logs:

   ```bash
   docker service logs aws-app-stack_backend
   ```

2. Check service constraints:

   ```bash
   docker service inspect aws-app-stack_backend
   ```

3. Verify node availability:
   ```bash
   docker node ls
   ```

### Network Issues

1. Check networks:

   ```bash
   docker network ls
   ```

2. Inspect overlay network:
   ```bash
   docker network inspect aws-app-stack_backend-network
   ```

### Image Pull Issues

1. Verify image exists:

   ```bash
   docker pull your-registry/aws-app-backend:v1.0.0
   ```

2. Check registry authentication:
   ```bash
   docker login your-registry
   ```

## Multi-Node Setup

### Adding Worker Nodes

1. Get join token from manager:

   ```bash
   docker swarm join-token worker
   ```

2. Run the command on worker nodes:
   ```bash
   docker swarm join --token SWMTKN-... manager-ip:2377
   ```

### Adding Manager Nodes

1. Get manager join token:

   ```bash
   docker swarm join-token manager
   ```

2. Run the command on new manager nodes:
   ```bash
   docker swarm join --token SWMTKN-... manager-ip:2377
   ```

## Security Considerations

### Secrets Management

The stack uses Docker secrets for sensitive data:

- Database passwords
- API keys
- SSL certificates

### Network Security

- Services communicate over encrypted overlay networks
- External access is controlled via ingress network
- Database and Redis are not exposed externally

### Node Security

- Use TLS for swarm communication
- Rotate join tokens regularly
- Monitor node access and activity

## Backup and Recovery

### Database Backup

```bash
# Create database backup
docker exec $(docker ps -q -f name=aws-app-stack_db) pg_dump -U postgres aws_app > backup.sql

# Restore database
docker exec -i $(docker ps -q -f name=aws-app-stack_db) psql -U postgres aws_app < backup.sql
```

### Configuration Backup

- Back up `docker-stack.yml`
- Back up environment files
- Document service configurations

## Performance Tuning

### Resource Limits

Adjust resource limits in `docker-stack.yml`:

```yaml
deploy:
  resources:
    limits:
      cpus: '1.0'
      memory: 1G
    reservations:
      cpus: '0.5'
      memory: 512M
```

### Placement Constraints

Use placement constraints for optimal performance:

```yaml
deploy:
  placement:
    constraints:
      - node.role == worker
      - node.labels.type == compute
```

## Maintenance

### Regular Tasks

1. Monitor resource usage
2. Check service health
3. Review logs for errors
4. Update images regularly
5. Backup data

### Updates

1. Test updates in staging
2. Use rolling updates for zero downtime
3. Have rollback plan ready
4. Monitor after updates

## Support

For issues or questions:

1. Check service logs
2. Use monitoring script
3. Consult Docker Swarm documentation
4. Review application-specific logs
