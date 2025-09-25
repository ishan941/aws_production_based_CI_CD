import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vitejs.dev/config/
export default defineConfig({
    plugins: [react()],
    server: {
        host: '0.0.0.0', // This allows external access
        port: 3000,
        proxy: {
            '/api': {
                target: process.env.NODE_ENV === 'development' && process.env.DOCKER_ENV
                    ? 'http://backend-dev:3001'
                    : 'http://localhost:3001',
                changeOrigin: true,
            },
        },
    },
    build: {
        outDir: 'dist',
    },
})