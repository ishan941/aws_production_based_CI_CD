#!/bin/bash

echo "🔧 Quick Fix for Jenkins Errors"
echo "==============================="

# Check if we're in the right directory
if [ ! -f "Jenkinsfile" ]; then
    echo "❌ No Jenkinsfile found in current directory"
    echo "Please run this script from the project root directory"
    exit 1
fi

echo "📋 Current Jenkins errors you might be experiencing:"
echo "   ❌ Required context class hudson.FilePath is missing"
echo "   ❌ ERROR: docker-registry-url credential not found"
echo "   ❌ Invalid tool type 'nodejs'"

echo ""
echo "🎯 Available Jenkinsfile versions:"
echo "   1. Jenkinsfile.basic    - No credentials/plugins required (RECOMMENDED)"
echo "   2. Jenkinsfile.simple   - Uses Docker for Node.js (requires Docker)"
echo "   3. Jenkinsfile.advanced - Full featured (requires credentials setup)"
echo "   4. Current Jenkinsfile  - Fixed version with optional credentials"

echo ""
read -p "Which version would you like to use? (1-4): " choice

case $choice in
    1)
        SELECTED="Jenkinsfile.basic"
        DESCRIPTION="Basic version with no external dependencies"
        ;;
    2)
        SELECTED="Jenkinsfile.simple"
        DESCRIPTION="Docker-based version without NodeJS plugin"
        ;;
    3)
        SELECTED="Jenkinsfile.advanced"
        DESCRIPTION="Full-featured version (backup of original)"
        ;;
    4)
        echo "✅ Keeping current Jenkinsfile (already fixed)"
        echo ""
        echo "📋 Current Jenkinsfile features:"
        echo "   ✅ Fixed post-section context issues"
        echo "   ✅ Optional credentials (won't fail if missing)"
        echo "   ✅ Graceful error handling"
        echo ""
        echo "💡 If you still get credential errors, use option 1 (basic version)"
        exit 0
        ;;
    *)
        echo "❌ Invalid choice. Exiting."
        exit 1
        ;;
esac

if [ ! -f "$SELECTED" ]; then
    echo "❌ $SELECTED not found!"
    echo "Available files:"
    ls -la Jenkinsfile*
    exit 1
fi

echo ""
echo "🔄 Switching to $SELECTED..."
echo "Description: $DESCRIPTION"

# Backup current Jenkinsfile
cp Jenkinsfile Jenkinsfile.backup
echo "✅ Backed up current Jenkinsfile to Jenkinsfile.backup"

# Replace with selected version
cp "$SELECTED" Jenkinsfile
echo "✅ Replaced Jenkinsfile with $SELECTED"

echo ""
echo "📝 Changes made:"
git status --porcelain | grep Jenkinsfile || echo "No changes detected"

# Check if git is available and ask about committing
if command -v git &> /dev/null; then
    echo ""
    read -p "Do you want to commit this change? (y/N): " commit_changes
    
    if [[ $commit_changes =~ ^[Yy]$ ]]; then
        git add Jenkinsfile
        git commit -m "Fix: Switch to $SELECTED for Jenkins compatibility

- Use $DESCRIPTION
- Resolves Jenkins context and credential errors
- Previous version backed up as Jenkinsfile.backup"
        
        echo "✅ Changes committed"
        
        read -p "Do you want to push to origin? (y/N): " push_changes
        
        if [[ $push_changes =~ ^[Yy]$ ]]; then
            git push
            echo "✅ Changes pushed to repository"
        fi
    fi
fi

echo ""
echo "🎉 Jenkinsfile updated successfully!"
echo ""
echo "📋 What was done:"
echo "   ✅ Current Jenkinsfile backed up as Jenkinsfile.backup"
echo "   ✅ Switched to $SELECTED"
echo "   ✅ $DESCRIPTION"

echo ""
echo "🚀 Next Steps:"
echo "   1. Go to your Jenkins instance"
echo "   2. Trigger a new build"

if [ "$SELECTED" = "Jenkinsfile.basic" ]; then
    echo "   3. The pipeline should run without any credentials or plugins"
    echo ""
    echo "📋 Basic Jenkinsfile features:"
    echo "   ✅ No external credentials required"
    echo "   ✅ No additional plugins required"  
    echo "   ✅ Uses Docker for consistent Node.js environment"
    echo "   ✅ Graceful fallbacks for missing components"
    echo "   ✅ Works with minimal Jenkins setup"
elif [ "$SELECTED" = "Jenkinsfile.simple" ]; then
    echo "   3. Ensure Docker is available on Jenkins agent"
    echo ""
    echo "📋 Simple Jenkinsfile features:"
    echo "   ✅ Uses Docker containers for Node.js operations"
    echo "   ✅ No NodeJS plugin required"
    echo "   ✅ Optional credentials (graceful fallback)"
fi

echo ""
echo "🔄 To revert later:"
echo "   cp Jenkinsfile.backup Jenkinsfile"
echo ""
echo "📚 For detailed setup instructions, see: JENKINS-SETUP.md"