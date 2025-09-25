# Docker Swarm Troubleshooting Guide

## Common Issues and Solutions

### 1. Docker Swarm Initialization Issues

#### Issue: `hostname: illegal option -- I`

**Cause**: The `hostname -I` command is Linux-specific and doesn't work on macOS.

**Solution**: The `init-swarm.sh` script has been updated to detect the OS and use appropriate commands:

- Linux: `hostname -I`
- macOS: Uses `ifconfig` and `route` commands

#### Issue: `flag needs an argument: --advertise-addr`

**Cause**: The IP address detection failed or returned empty.

**Solution**:

1. Check your network connection
2. The script now falls back to `127.0.0.1` if IP detection fails
3. For production, manually specify the IP: `docker swarm init --advertise-addr YOUR_IP`

### 2. Docker Stack Deployment Issues

#### Issue: Environment variables not set in docker-stack.yml

**Cause**: The original `docker-stack.yml` requires registry environment variables.

**Solutions**:

1. **For local development**: Use `./deploy-demo.sh` for a simple test
2. **For local app deployment**: Use `./deploy-stack-local.sh` (builds local images)
3. **For production**: Set these environment variables:
   ```bash
   export DOCKER_REGISTRY=your-registry.com
   export DOCKER_REPOSITORY=aws-app
   export IMAGE_TAG=v1.0.0
   ```

#### Issue: Images not found

**Cause**: Referenced Docker images don't exist locally or in registry.

**Solutions**:

1. Build images locally:
   ```bash
   docker build -f apps/backend/Dockerfile -t aws-app-backend:local .
   docker build -f apps/web/Dockerfile -t aws-app-frontend:local .
   ```
2. Pull from registry: `docker pull your-registry/image:tag`
3. Use the demo deployment: `./deploy-demo.sh`

### 3. macOS-Specific Issues

#### Issue: Volume mounting issues on macOS

**Cause**: Different file system permissions and paths.

**Solution**: The scripts now skip `/opt/` directory creation on macOS and use Docker volumes instead.

#### Issue: `free` command not found

**Cause**: macOS doesn't have the `free` command for memory information.

**Solution**: The monitoring script now uses `vm_stat` on macOS.

### 4. Service Health Check Failures

#### Issue: Services not starting or failing health checks

**Common causes and solutions**:

1. **Port conflicts**:

   ```bash
   # Check what's using the port
   lsof -i :8080
   netstat -an | grep 8080
   ```

2. **Resource constraints**:

   ```bash
   # Check Docker resources
   docker system df
   docker stats
   ```

3. **Image compatibility**:
   ```bash
   # Check if image works standalone
   docker run --rm -p 8080:80 nginx:alpine
   ```

### 5. Network Issues

#### Issue: Services can't communicate

**Solutions**:

1. Check if overlay network exists:
   ```bash
   docker network ls | grep overlay
   ```
2. Verify network attachment:
   ```bash
   docker network inspect network-name
   ```
3. Test connectivity between services:
   ```bash
   docker exec -it container-name ping other-service-name
   ```

### 6. Debugging Commands

#### Service Status

```bash
# List all services
docker service ls

# Detailed service info
docker service inspect service-name

# Service logs
docker service logs service-name

# Service processes
docker service ps service-name
```

#### Stack Management

```bash
# List stacks
docker stack ls

# Stack services
docker stack services stack-name

# Stack processes
docker stack ps stack-name

# Remove stack
docker stack rm stack-name
```

#### Node Management

```bash
# List nodes
docker node ls

# Node details
docker node inspect node-name

# Node availability
docker node update --availability drain node-name
```

### 7. Cleanup and Reset

#### Clean Docker System

```bash
# Remove unused containers, networks, images
docker system prune -a

# Remove all volumes (⚠️ destroys data)
docker system prune -a --volumes
```

#### Leave Swarm

```bash
# Leave swarm (loses all stacks and services)
docker swarm leave --force
```

#### Complete Reset

```bash
# Stop and remove everything
docker stack rm $(docker stack ls --format {{.Name}})
docker service rm $(docker service ls -q)
docker swarm leave --force
docker system prune -a --volumes
```

### 8. Development vs Production

#### Development (Local)

- Use `./deploy-demo.sh` for testing Docker Swarm
- Use `./deploy-stack-local.sh` for local app deployment
- Services run on manager node (single node)
- Data stored in Docker volumes

#### Production

- Use `./deploy-stack.sh` with proper registry images
- Multi-node cluster with worker nodes
- External data volumes or storage
- Load balancing and high availability

### 9. Performance Tips

#### Resource Optimization

```yaml
# In docker-stack.yml
deploy:
  resources:
    limits:
      cpus: '0.5'
      memory: 512M
    reservations:
      cpus: '0.1'
      memory: 256M
```

#### Scaling

```bash
# Scale services based on load
docker service scale service-name=5

# Auto-scaling (requires external tools)
# Use Docker Swarm with Prometheus/Grafana
```

### 10. Monitoring and Logs

#### Built-in Monitoring

```bash
# Use the monitoring script
./monitor-swarm.sh

# Watch service status
watch docker service ls

# Follow logs
docker service logs -f service-name
```

#### External Monitoring

- Prometheus + Grafana
- ELK Stack (Elasticsearch, Logstash, Kibana)
- Docker Swarm Visualizer

### Quick Reference

#### Essential Commands

```bash
# Initialize swarm
./init-swarm.sh

# Deploy demo
./deploy-demo.sh

# Monitor cluster
./monitor-swarm.sh

# Scale service
docker service scale service-name=3

# Update service
docker service update --image new-image service-name

# View logs
docker service logs service-name

# Remove stack
docker stack rm stack-name
```

#### File Locations

- Swarm scripts: `docker/swarm/`
- Stack definitions: `docker-stack*.yml`
- Application Dockerfiles: `apps/*/Dockerfile`
- Nginx config: `docker/nginx/nginx.conf`

For more help, check the individual script outputs or run `./monitor-swarm.sh` for current status.
