import { Injectable } from '@nestjs/common';
import { HealthResponse } from '@aws-app/shared';

@Injectable()
export class AppService {
    getHealth(): HealthResponse {
        return {
            message: 'Backend API is healthy! 🚀',
            timestamp: new Date().toISOString(),
            uptime: process.uptime(),
        };
    }

    getWelcome(): { message: string } {
        return {
            message: 'Welcome to AWS App Backend API!',
        };
    }
}