# AWS App Monorepo

A modern monorepo containing a React frontend and NestJS backend application.

## Structure

```
├── apps/
│   ├── web/          # React frontend application
│   └── backend/      # NestJS backend application
├── packages/
│   └── shared/       # Shared utilities and types
└── package.json      # Root package.json with workspace configuration
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
