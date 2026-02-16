import { Injectable, NestMiddleware } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';
import { ParseableService } from '../../parseable/parseable.service';

@Injectable()
export class ApiMetricsMiddleware implements NestMiddleware {
  constructor(private readonly parseable: ParseableService) {}

  use(req: Request, res: Response, next: NextFunction) {
    const start = Date.now();

    res.on('finish', () => {
      const durationMs = Date.now() - start;

      // Don't log health checks or metrics endpoints to avoid noise
      if (req.path === '/api/v1/health' || req.path === '/api/v1/metrics') {
        return;
      }

      this.parseable.logApiMetric({
        method: req.method,
        path: req.path,
        status_code: res.statusCode,
        duration_ms: durationMs,
        user_agent: req.get('user-agent') || '',
      });
    });

    next();
  }
}
