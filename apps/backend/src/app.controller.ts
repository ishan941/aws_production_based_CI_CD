import { Controller, Get } from '@nestjs/common';
import { AppService } from './app.service';
import { HealthResponse } from '@aws-app/shared';

@Controller()
export class AppController {
    constructor(private readonly appService: AppService) { }

    @Get('health')
    getHealth(): HealthResponse {
        return this.appService.getHealth();
    }

    @Get()
    getWelcome(): { message: string } {
        return this.appService.getWelcome();
    }
}