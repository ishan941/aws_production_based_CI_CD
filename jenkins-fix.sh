#!/bin/bash

echo "🔧 Quick Fix for Jenkins NodeJS Plugin Error"
echo "=============================================="

# Check if we're in the right directory
if [ ! -f "Jenkinsfile" ]; then
    echo "❌ No Jenkinsfile found in current directory"
    echo "Please run this script from the project root directory"
    exit 1
fi

echo "📋 Current situation:"
echo "   - Your Jenkins doesn't have the NodeJS plugin installed"
echo "   - The current Jenkinsfile requires this plugin"
echo "   - This script will switch to a compatible version"

echo ""
echo "🔄 Making changes..."

# Backup the current Jenkinsfile
if [ -f "Jenkinsfile" ]; then
    cp Jenkinsfile Jenkinsfile.advanced
    echo "✅ Backed up current Jenkinsfile to Jenkinsfile.advanced"
fi

# Replace with simple version
if [ -f "Jenkinsfile.simple" ]; then
    cp Jenkinsfile.simple Jenkinsfile
    echo "✅ Replaced Jenkinsfile with compatible version"
else
    echo "❌ Jenkinsfile.simple not found"
    exit 1
fi

# Check if git is available and commit changes
if command -v git &> /dev/null; then
    echo ""
    echo "📝 Git changes:"
    git status
    
    echo ""
    read -p "Do you want to commit these changes? (y/N): " commit_changes
    
    if [[ $commit_changes =~ ^[Yy]$ ]]; then
        git add Jenkinsfile Jenkinsfile.advanced Jenkinsfile.simple
        git commit -m "Fix: Switch to NodeJS plugin-free Jenkinsfile

- Backup original Jenkinsfile as Jenkinsfile.advanced
- Use Jenkinsfile.simple that doesn't require NodeJS plugin
- Pipeline now uses Docker for Node.js consistency
- Resolves: Invalid tool type 'nodejs' error"
        
        echo "✅ Changes committed"
        
        echo ""
        read -p "Do you want to push to origin? (y/N): " push_changes
        
        if [[ $push_changes =~ ^[Yy]$ ]]; then
            git push
            echo "✅ Changes pushed to repository"
        fi
    else
        echo "ℹ️  Changes not committed. You can manually commit later."
    fi
else
    echo "⚠️  Git not found. Please manually commit the changes."
fi

echo ""
echo "🎉 Quick fix completed!"
echo ""
echo "📋 What was done:"
echo "   ✅ Original Jenkinsfile backed up as Jenkinsfile.advanced"
echo "   ✅ Replaced with plugin-free version"
echo "   ✅ New pipeline uses Docker for Node.js (no plugin required)"
echo ""
echo "🚀 Next steps:"
echo "   1. Go to your Jenkins instance"
echo "   2. Trigger a new build"
echo "   3. The pipeline should now work without NodeJS plugin"
echo ""
echo "📚 For full Jenkins setup guide, see: JENKINS-SETUP.md"
echo ""
echo "🔄 To revert back later (after installing NodeJS plugin):"
echo "   cp Jenkinsfile.advanced Jenkinsfile"
echo "   git add Jenkinsfile && git commit -m 'Revert to advanced Jenkinsfile'"