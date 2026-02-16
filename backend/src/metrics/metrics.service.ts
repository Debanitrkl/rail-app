import { Injectable } from '@nestjs/common';
import { ParseableService } from '../parseable/parseable.service';

@Injectable()
export class MetricsService {
  constructor(private readonly parseable: ParseableService) {}

  async getDashboard(): Promise<{
    api: any;
    errors: any[];
    slowRequests: any[];
  }> {
    const [api, errors, slowRequests] = await Promise.all([
      this.parseable.getApiMetricsSummary(15),
      this.parseable.getRecentErrors(1),
      this.parseable.getSlowRequests(500, 10),
    ]);

    return { api, errors, slowRequests };
  }

  async getApiMetrics(minutes: number = 15) {
    return this.parseable.getApiMetricsSummary(minutes);
  }

  async getRecentErrors(hours: number = 1) {
    return this.parseable.getRecentErrors(hours);
  }

  async getSlowRequests(thresholdMs: number = 1000) {
    return this.parseable.getSlowRequests(thresholdMs);
  }
}
