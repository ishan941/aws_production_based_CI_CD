# Jenkins Setup Guide for AWS App CI/CD

## 🚨 Quick Fix for Jenkins Errors

### Current Error: "Required context class hudson.FilePath is missing"

This error occurs when `sh` commands in the `post` section don't have proper context. **Solution: Use the basic Jenkinsfile**

### Quick Fix Options (Choose one):

#### Option 1: Use Basic Jenkinsfile (Recommended for beginners)
```bash
# Switch to the most compatible version
cp Jenkinsfile.basic Jenkinsfile
git add Jenkinsfile
git commit -m "Use basic Jenkinsfile - no credentials required"
git push
```

#### Option 2: Use Fixed Jenkinsfile (Updated version)
The current Jenkinsfile has been fixed but requires credential setup (see below).

#### Option 3: Use Simple Jenkinsfile (Docker-based)
```bash
cp Jenkinsfile.simple Jenkinsfile
git add Jenkinsfile  
git commit -m "Use simple Jenkinsfile without NodeJS plugin dependency"
git push
```

### Solution 2: Install NodeJS Plugin in Jenkins

1. Go to **Manage Jenkins** → **Manage Plugins**
2. Go to **Available** tab
3. Search for "NodeJS"
4. Install **NodeJS Plugin**
5. Restart Jenkins
6. Configure Node.js in **Manage Jenkins** → **Global Tool Configuration**

## 📋 Complete Jenkins Setup

### Required Jenkins Plugins

#### Essential Plugins (Install these first):

```
1. Pipeline
2. Git
3. Docker Pipeline
4. Credentials Binding
5. Workspace Cleanup
```

#### Optional Plugins (for enhanced features):

```
6. NodeJS Plugin (for the advanced Jenkinsfile)
7. OWASP Dependency Check
8. Blue Ocean (for better UI)
9. Pipeline Stage View
10. Timestamper
```

### Installing Plugins

1. **Navigate to Plugin Manager:**
   - Jenkins Dashboard → **Manage Jenkins** → **Manage Plugins**

2. **Install Essential Plugins:**
   - Go to **Available** tab
   - Search for each plugin name
   - Check the box next to each plugin
   - Click **Install without restart** or **Download now and install after restart**

3. **Restart Jenkins:**
   - Go to **Manage Jenkins** → **Restart Safely**

### Configure Global Tools (If using advanced Jenkinsfile)

#### Node.js Configuration:

1. **Manage Jenkins** → **Global Tool Configuration**
2. **NodeJS** section → **Add NodeJS**
3. **Name:** `20` (must match the name in Jenkinsfile)
4. **Version:** Choose Node.js 20.x
5. **Install automatically:** Check this box
6. **Save**

#### Docker Configuration:

1. In **Global Tool Configuration**
2. **Docker** section → **Add Docker**
3. **Name:** `docker`
4. **Install automatically:** Check this box
5. **Save**

### Configure Credentials

#### Docker Registry Credentials:

1. **Manage Jenkins** → **Manage Credentials**
2. **Global** → **Add Credentials**
3. **Kind:** Username with password
4. **ID:** `docker-registry-credentials`
5. **Username:** Your Docker registry username
6. **Password:** Your Docker registry password/token
7. **Save**

#### Docker Registry URL:

1. **Add Credentials** → **Secret text**
2. **ID:** `docker-registry-url`
3. **Secret:** Your registry URL (e.g., `docker.io`, `your-registry.com`)
4. **Save**

#### Swarm Manager Host (Optional):

1. **Add Credentials** → **Secret text**
2. **ID:** `swarm-manager-host`
3. **Secret:** Your swarm manager hostname/IP
4. **Save**

### Create Jenkins Pipeline Job

1. **New Item** → **Pipeline**
2. **Name:** `aws-app-pipeline`
3. **Pipeline** section:
   - **Definition:** Pipeline script from SCM
   - **SCM:** Git
   - **Repository URL:** `https://github.com/ishan941/aws_production_based_CI_CD.git`
   - **Branch:** `*/A-3` (or your branch)
   - **Script Path:** `Jenkinsfile`
4. **Save**

## 🔧 Jenkins System Configuration

### Java and Docker Requirements

Ensure your Jenkins server has:

- **Java 11 or later**
- **Docker installed and accessible**
- **Docker Compose installed**

```bash
# Check on Jenkins server
java -version
docker --version
docker-compose --version
```

### Docker Permissions

Make sure Jenkins user can run Docker:

```bash
# Add jenkins user to docker group
sudo usermod -aG docker jenkins

# Restart Jenkins service
sudo systemctl restart jenkins
```

### System Resources

Recommended minimum for Jenkins server:

- **RAM:** 4GB+
- **CPU:** 2+ cores
- **Disk:** 50GB+ free space
- **Network:** Outbound internet access

## 🚀 Pipeline Comparison

### Simple Jenkinsfile (Jenkinsfile.simple)

**Pros:**

- ✅ No plugin dependencies
- ✅ Uses Docker for Node.js (consistent environment)
- ✅ Works with minimal Jenkins setup
- ✅ Easier to debug

**Cons:**

- Slightly slower (downloads Node.js image each time)
- Less Jenkins-native tool integration

### Advanced Jenkinsfile (Original)

**Pros:**

- ✅ Faster execution (uses installed Node.js)
- ✅ Better Jenkins tool integration
- ✅ More advanced features

**Cons:**

- ❌ Requires NodeJS plugin
- ❌ More complex setup
- ❌ More dependencies

## 🛠️ Troubleshooting

### Common Issues:

#### 1. "Required context class hudson.FilePath is missing"
**Solution:** 
- Use `Jenkinsfile.basic` (no credentials required)
- Or wrap `sh` commands in `post` section with `node { }`

#### 2. "ERROR: docker-registry-url" (Credential not found)
**Solution:**
- Use `Jenkinsfile.basic` (no credentials required)
- Or configure credentials in Jenkins (see setup guide below)

#### 3. "Invalid tool type 'nodejs'"
**Solution:** Use `Jenkinsfile.simple` or install NodeJS plugin

#### 4. "docker: command not found"

**Solution:**

```bash
# Install Docker on Jenkins server
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

#### 3. "Permission denied" for Docker

**Solution:**

```bash
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

#### 4. Build fails on "npm ci"

**Solution:** Check if package.json files exist in correct locations

#### 5. "No space left on device"

**Solution:**

```bash
# Clean up Docker
docker system prune -a
docker volume prune
```

### Debug Commands:

Run these in Jenkins console (**Manage Jenkins** → **Script Console**):

```groovy
// Check available tools
def tools = Jenkins.instance.getDescriptor("hudson.tasks.Maven\$MavenInstallation")
println tools.getInstallations()

// Check Docker
"docker --version".execute().text

// Check disk space
"df -h".execute().text
```

## 📊 Pipeline Monitoring

### View Pipeline Status:

1. **Blue Ocean** (if installed): Better visual interface
2. **Classic UI**: Jenkins Dashboard → Your Pipeline
3. **Stage View**: Shows pipeline stages and timing
4. **Console Output**: Detailed logs for debugging

### Pipeline Metrics:

- **Build Duration**
- **Success Rate**
- **Stage Performance**
- **Resource Usage**

## 🔄 Best Practices

### Security:

- ✅ Use credentials for sensitive data
- ✅ Limit plugin installations
- ✅ Regular Jenkins updates
- ✅ Secure Jenkins access (HTTPS, authentication)

### Performance:

- ✅ Clean workspace after builds
- ✅ Use Docker image caching
- ✅ Parallel stage execution
- ✅ Regular cleanup of old builds

### Maintenance:

- ✅ Regular backups
- ✅ Monitor disk space
- ✅ Update plugins regularly
- ✅ Monitor build performance

## 🎯 Next Steps

1. **Quick Fix:** Use `Jenkinsfile.simple` to resolve immediate error
2. **Setup:** Install required plugins and configure credentials
3. **Test:** Run a build to verify everything works
4. **Optimize:** Switch to advanced Jenkinsfile when ready
5. **Monitor:** Set up monitoring and alerting

## 📞 Support

If you continue having issues:

1. Check Jenkins logs: `/var/log/jenkins/jenkins.log`
2. Review console output in Jenkins UI
3. Test Docker commands manually on Jenkins server
4. Verify network connectivity and permissions

The simple Jenkinsfile should resolve your immediate error and get your pipeline running!
