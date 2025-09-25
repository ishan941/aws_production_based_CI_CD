# AWS App Monorepo

A modern monorepo containing a React frontend and NestJS backend application.

## Structure

```
aws_app/
├── .dockerignore                    # Root level Docker ignore
├── .env.example                     # Environment variables template
├── .env                            # Environment variables (git-ignored)
├── docker-compose.yml              # Production Docker Compose
├── docker-compose.dev.yml          # Development Docker Compose
├── docker-compose.override.yml     # Optional overrides
├── package.json                    # Root package.json
├── setup.sh                       # Your existing setup script
├── README.md
├── .gitignore
│
├── apps/
│   ├── web/                        # Frontend application
│   │   ├── Dockerfile              # Production frontend Dockerfile
│   │   ├── Dockerfile.dev          # Development frontend Dockerfile
│   │   ├── nginx.conf              # Nginx configuration
│   │   ├── package.json
│   │   ├── vite.config.js
│   │   ├── src/
│   │   ├── public/
│   │   └── dist/                   # Build output
│   │
│   └── backend/                    # Backend application
│       ├── Dockerfile              # Production backend Dockerfile ✅ (You have this)
│       ├── Dockerfile.dev          # Development backend Dockerfile
│       ├── package.json
│       ├── src/
│       └── dist/                   # Build output
│
├── packages/
│   └── shared/                     # Shared package
│       ├── package.json
│       ├── src/
│       └── dist/                   # Build output
│
├── docker/                         # Optional: Docker utilities folder
│   ├── nginx/
│   │   └── nginx.conf              # Alternative nginx config location
│   ├── scripts/
│   │   ├── build.sh               # Docker build scripts
│   │   └── deploy.sh              # Deployment scripts
│   └── healthcheck/
│       └── healthcheck.js         # Custom health check scripts
│
└── deployment/                     # Optional: Deployment configurations
    ├── docker-compose.prod.yml    # Production-specific compose
    ├── docker-compose.staging.yml # Staging environment
    └── k8s/                       # Kubernetes manifests (if needed)
```

## Getting Started

### Prerequisites

- Node.js >= 18.0.0
- npm >= 9.0.0

### Quick Setup

Run the setup script to install dependencies and build the shared package:

```bash
./setup.sh
```

Or manually:

```bash
npm install
npm run build:shared
```

### Development

Start all applications in development mode:

```bash
npm run dev
```

This will start:

- React frontend on http://localhost:3000
- NestJS backend on http://localhost:3001/api
- TypeScript compilation in watch mode for shared package

Or run them individually:

```bash
# Frontend only
npm run dev:web

# Backend only
npm run dev:backend

# Shared package compilation in watch mode
npm run dev:shared
```

### Building

Build all applications:

```bash
npm run build
```

Or build individually:

```bash
npm run build:shared  # Build first (required by other apps)
npm run build:web
npm run build:backend
```

### Testing

Run tests across all workspaces:

```bash
npm test
```

Run tests for specific apps:

```bash
npm run test:web
npm run test:backend
```

### Linting

Lint all code:

```bash
npm run lint
```

Auto-fix linting issues:

```bash
npm run lint:fix
```

## Applications

- **Frontend (apps/web)**: React application built with Vite and TypeScript
- **Backend (apps/backend)**: NestJS application with TypeScript
- **Shared (packages/shared)**: Common utilities and type definitions

## Scripts

- `dev` - Start both applications in development mode
- `build` - Build both applications
- `test` - Run tests across all workspaces
- `lint` - Lint all workspaces
- `clean` - Clean build artifacts

To run in fresh

```bash
# Update package index
sudo apt update

# Install curl if not already installed
sudo apt install -y curl

# Add NodeSource repository for Node.js 20.x (LTS)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -

# Install Node.js
sudo apt install -y nodejs

# Verify installation
node --version
npm --version
```

```bash
./setup.sh
```
