# Project Structure

This document provides a detailed overview of the monorepo structure and organization.

## Root Level

```
aws-app/
├── apps/                    # Applications
│   ├── web/                # React frontend
│   └── backend/            # NestJS backend
├── packages/               # Shared packages
│   └── shared/            # Common types and utilities
├── package.json           # Root package.json with workspace config
├── .eslintrc.js          # ESLint configuration
├── .prettierrc           # Prettier configuration
├── .gitignore            # Git ignore rules
├── setup.sh              # Setup script
└── README.md             # Project documentation
```

## Frontend Application (`apps/web/`)

React application built with Vite and TypeScript.

```
web/
├── src/
│   ├── components/        # React components (future)
│   ├── services/         # API client and services
│   │   └── apiClient.ts  # Axios-based API client
│   ├── App.tsx           # Main App component
│   ├── App.css           # App styles
│   ├── main.tsx          # Application entry point
│   ├── index.css         # Global styles
│   └── vite-env.d.ts     # Vite environment types
├── index.html            # HTML template
├── package.json          # Frontend dependencies
├── tsconfig.json         # TypeScript config
├── tsconfig.node.json    # Node TypeScript config
└── vite.config.ts        # Vite configuration
```

### Key Features:

- React 18 with TypeScript
- React Router for navigation
- Axios for API communication
- Vite for fast development and building
- Proxy configuration for API calls

## Backend Application (`apps/backend/`)

NestJS application with TypeScript.

```
backend/
├── src/
│   ├── users/            # Users module
│   │   ├── users.controller.ts
│   │   ├── users.service.ts
│   │   └── users.module.ts
│   ├── app.controller.ts # Main controller
│   ├── app.service.ts    # Main service
│   ├── app.module.ts     # Root module
│   └── main.ts           # Application bootstrap
├── package.json          # Backend dependencies
├── nest-cli.json         # Nest CLI configuration
├── tsconfig.json         # TypeScript config
└── tsconfig.build.json   # Build TypeScript config
```

### Key Features:

- NestJS framework with TypeScript
- CORS enabled for frontend communication
- RESTful API endpoints
- Modular architecture
- Global API prefix (`/api`)

## Shared Package (`packages/shared/`)

Common types, utilities, and constants shared between frontend and backend.

```
shared/
├── src/
│   ├── types.ts          # TypeScript interfaces and types
│   ├── utils.ts          # Utility functions
│   ├── constants.ts      # Application constants
│   └── index.ts          # Package exports
├── package.json          # Package configuration
└── tsconfig.json         # TypeScript config
```

### Exports:

- **Types**: `ApiResponse`, `HealthResponse`, `User`, `ApiError`, etc.
- **Utils**: `formatDate`, `capitalize`, `truncate`, `isValidEmail`, etc.
- **Constants**: `HTTP_STATUS`, `ERROR_MESSAGES`, `API_BASE_URL`, etc.

## Development Workflow

### 1. Initial Setup

```bash
./setup.sh
# or
npm install && npm run build:shared
```

### 2. Development Mode

```bash
npm run dev  # Starts all applications
```

### 3. Individual Development

```bash
npm run dev:web      # Frontend only
npm run dev:backend  # Backend only
npm run dev:shared   # Shared package watch mode
```

### 4. Building

```bash
npm run build        # Build all
npm run build:web    # Frontend only
npm run build:backend # Backend only
npm run build:shared  # Shared package only
```

## API Endpoints

### Health Check

- **GET** `/api/health` - Backend health status

### Core API

- **GET** `/api/` - Welcome message

### Users API

- **GET** `/api/users` - Get all users
- **GET** `/api/users/:id` - Get user by ID

## Environment Variables

### Frontend (`.env` in `apps/web/`)

```
VITE_API_URL=http://localhost:3001/api
VITE_APP_TITLE=AWS App Frontend
```

### Backend (`.env` in `apps/backend/`)

```
PORT=3001
NODE_ENV=development
```

## Scripts Reference

### Root Level Scripts

- `npm run dev` - Start all applications
- `npm run build` - Build all applications
- `npm run test` - Run all tests
- `npm run lint` - Lint all code
- `npm run lint:fix` - Fix linting issues
- `npm run clean` - Clean build artifacts

### Workspace-Specific Scripts

- `npm run dev:web` - Start frontend
- `npm run dev:backend` - Start backend
- `npm run dev:shared` - Watch shared package
- `npm run build:web` - Build frontend
- `npm run build:backend` - Build backend
- `npm run build:shared` - Build shared package
- `npm run test:web` - Test frontend
- `npm run test:backend` - Test backend

## Technology Stack

### Frontend

- **React 18** - UI library
- **TypeScript** - Type safety
- **Vite** - Build tool and dev server
- **React Router** - Client-side routing
- **Axios** - HTTP client

### Backend

- **NestJS** - Node.js framework
- **TypeScript** - Type safety
- **Express** - HTTP server (via NestJS)

### Shared

- **TypeScript** - Type definitions and utilities

### Development Tools

- **ESLint** - Code linting
- **Prettier** - Code formatting
- **Concurrently** - Run multiple commands
- **npm Workspaces** - Monorepo management
