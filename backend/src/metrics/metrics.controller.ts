import { Controller, Get, Query } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiQuery } from '@nestjs/swagger';
import { MetricsService } from './metrics.service';

@ApiTags('Monitoring')
@Controller('api/v1/metrics')
export class MetricsController {
  constructor(private readonly metricsService: MetricsService) {}

  @Get()
  @ApiOperation({ summary: 'Monitoring dashboard — API metrics, errors, slow requests' })
  async getDashboard() {
    return this.metricsService.getDashboard();
  }

  @Get('api')
  @ApiOperation({ summary: 'API request metrics summary' })
  @ApiQuery({ name: 'minutes', required: false, type: Number })
  async getApiMetrics(@Query('minutes') minutes?: number) {
    return this.metricsService.getApiMetrics(minutes || 15);
  }

  @Get('errors')
  @ApiOperation({ summary: 'Recent application errors' })
  @ApiQuery({ name: 'hours', required: false, type: Number })
  async getRecentErrors(@Query('hours') hours?: number) {
    return this.metricsService.getRecentErrors(hours || 1);
  }

  @Get('slow')
  @ApiOperation({ summary: 'Slow API requests' })
  @ApiQuery({ name: 'threshold_ms', required: false, type: Number })
  async getSlowRequests(@Query('threshold_ms') thresholdMs?: number) {
    return this.metricsService.getSlowRequests(thresholdMs || 1000);
  }
}
