#!/bin/bash

echo "🚀 Setting up AWS App Monorepo..."

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js is not installed. Please install Node.js >= 18.0.0"
    exit 1
fi

# Check Node.js version
NODE_VERSION=$(node -v | cut -d'v' -f2)
REQUIRED_VERSION="18.0.0"

if ! npx semver --range ">=18.0.0" "${NODE_VERSION}" &> /dev/null; then
    echo "❌ Node.js version ${NODE_VERSION} is not supported. Please install Node.js >= 18.0.0"
    exit 1
fi

echo "✅ Node.js version ${NODE_VERSION} detected"

# Install dependencies
echo "📦 Installing dependencies..."
npm install

if [ $? -ne 0 ]; then
    echo "❌ Failed to install dependencies"
    exit 1
fi

# Build shared package
echo "🔨 Building shared package..."
npm run build:shared

if [ $? -ne 0 ]; then
    echo "❌ Failed to build shared package"
    exit 1
fi

echo ""
echo "🎉 Setup complete!"
echo ""
echo "Available commands:"
echo "  npm run dev          - Start all applications in development mode"
echo "  npm run dev:web      - Start frontend only"
echo "  npm run dev:backend  - Start backend only"
echo "  npm run build        - Build all applications"
echo "  npm run test         - Run tests"
echo "  npm run lint         - Lint all code"
echo ""
echo "🌐 URLs:"
echo "  Frontend: http://localhost:3000"
echo "  Backend:  http://localhost:3001/api"
echo ""
echo "To get started, run: npm run dev"