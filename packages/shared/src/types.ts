// API Types
export interface ApiResponse<T = any> {
    data: T;
    message?: string;
    timestamp: string;
}

export interface HealthResponse {
    message: string;
    timestamp: string;
    uptime: number;
}

// User Types
export interface User {
    id: string;
    email: string;
    name: string;
    createdAt: string;
    updatedAt: string;
}

// Common Error Types
export interface ApiError {
    code: string;
    message: string;
    details?: any;
}

// Pagination Types
export interface PaginationParams {
    page: number;
    limit: number;
}

export interface PaginatedResponse<T> {
    data: T[];
    pagination: {
        page: number;
        limit: number;
        total: number;
        totalPages: number;
    };
}