import { Injectable } from '@nestjs/common';
import { User } from '@aws-app/shared';

@Injectable()
export class UsersService {
    private readonly users: User[] = [
        {
            id: '1',
            email: 'john.doe@example.com',
            name: 'John Doe',
            createdAt: new Date('2024-01-01').toISOString(),
            updatedAt: new Date('2024-01-01').toISOString(),
        },
        {
            id: '2',
            email: 'jane.smith@example.com',
            name: 'Jane Smith',
            createdAt: new Date('2024-01-02').toISOString(),
            updatedAt: new Date('2024-01-02').toISOString(),
        },
    ];

    findAll(): User[] {
        return this.users;
    }

    findOne(id: string): User | null {
        return this.users.find(user => user.id === id) || null;
    }
}