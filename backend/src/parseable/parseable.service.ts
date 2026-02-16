import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

export interface TrainPositionEvent {
  train_number: string;
  latitude: number;
  longitude: number;
  speed_kmph: number;
  delay_minutes: number;
  current_station: string;
  next_station: string;
  eta_next: string;
  timestamp: string;
}

export interface PlatformChangeEvent {
  station_code: string;
  platform_number: string;
  train_number: string;
  event_type: string;
  timestamp: string;
}

export interface DelayEvent {
  train_number: string;
  station_code: string;
  scheduled_time: string;
  actual_time: string;
  delay_minutes: number;
  cause: string;
  timestamp: string;
}

export interface PnrStatusChangeEvent {
  pnr: string;
  old_status: string;
  new_status: string;
  coach: string;
  berth: string;
  timestamp: string;
}

// Monitoring interfaces
export interface AppLogEvent {
  service: string;
  level: 'debug' | 'info' | 'warn' | 'error' | 'fatal';
  message: string;
  context?: string;
  trace_id?: string;
  timestamp: string;
}

export interface ApiMetricEvent {
  method: string;
  path: string;
  status_code: number;
  duration_ms: number;
  user_agent?: string;
  timestamp: string;
}

export interface WorkerLogEvent {
  worker: string;
  job: string;
  level: 'info' | 'warn' | 'error';
  message: string;
  duration_ms?: number;
  timestamp: string;
}

export interface SystemEvent {
  service: string;
  event: string;
  details?: Record<string, any>;
  timestamp: string;
}

@Injectable()
export class ParseableService implements OnModuleInit {
  private readonly logger = new Logger(ParseableService.name);
  private baseUrl: string;
  private authHeader: string;

  constructor(private readonly configService: ConfigService) {
    this.baseUrl = this.configService.get<string>(
      'PARSEABLE_URL',
      'http://localhost:8000',
    );
    const user = this.configService.get<string>('PARSEABLE_USER', 'admin');
    const password = this.configService.get<string>('PARSEABLE_PASSWORD', 'admin');
    this.authHeader = `Basic ${Buffer.from(`${user}:${password}`).toString('base64')}`;
  }

  async onModuleInit() {
    try {
      const response = await fetch(`${this.baseUrl}/api/v1/liveness`, {
        headers: { Authorization: this.authHeader },
      });
      if (response.ok) {
        this.logger.log('Connected to Parseable');
      } else {
        this.logger.warn(`Parseable health check returned status ${response.status}`);
      }
    } catch (error) {
      this.logger.warn('Could not connect to Parseable on startup, will retry on use');
    }
  }

  private async makeRequest(
    method: string,
    path: string,
    body?: any,
    headers?: Record<string, string>,
  ): Promise<any> {
    const url = `${this.baseUrl}${path}`;
    const requestHeaders: Record<string, string> = {
      Authorization: this.authHeader,
      'Content-Type': 'application/json',
      ...headers,
    };

    try {
      const response = await fetch(url, {
        method,
        headers: requestHeaders,
        body: body ? JSON.stringify(body) : undefined,
      });

      if (!response.ok) {
        const errorText = await response.text();
        throw new Error(`Parseable API error ${response.status}: ${errorText}`);
      }

      const contentType = response.headers.get('content-type');
      if (contentType && contentType.includes('application/json')) {
        return await response.json();
      }
      return await response.text();
    } catch (error) {
      this.logger.error(`Parseable request failed: ${method} ${path}`, error);
      throw error;
    }
  }

  async createStream(streamName: string): Promise<void> {
    try {
      await this.makeRequest('PUT', `/api/v1/logstream/${streamName}`);
      this.logger.log(`Created Parseable stream: ${streamName}`);
    } catch (error) {
      if (
        error instanceof Error &&
        error.message.includes('409')
      ) {
        this.logger.log(`Stream ${streamName} already exists`);
      } else {
        throw error;
      }
    }
  }

  async ingestEvents(streamName: string, events: any[]): Promise<void> {
    await this.makeRequest(
      'POST',
      `/api/v1/logstream/${streamName}`,
      events,
      { 'X-P-Stream': streamName },
    );
  }

  async ingestEvent(streamName: string, event: any): Promise<void> {
    await this.ingestEvents(streamName, [event]);
  }

  async queryStream(
    streamName: string,
    query: string,
    startTime: string,
    endTime: string,
  ): Promise<any[]> {
    const body = {
      query,
      startTime,
      endTime,
    };
    const result = await this.makeRequest('POST', '/api/v1/query', body);
    return Array.isArray(result) ? result : [];
  }

  async getLatestTrainPosition(
    trainNumber: string,
  ): Promise<TrainPositionEvent | null> {
    const now = new Date();
    const oneHourAgo = new Date(now.getTime() - 60 * 60 * 1000);

    try {
      const results = await this.queryStream(
        'train-positions',
        `SELECT * FROM "train-positions" WHERE train_number = '${trainNumber}' ORDER BY timestamp DESC LIMIT 1`,
        oneHourAgo.toISOString(),
        now.toISOString(),
      );

      if (results.length > 0) {
        return results[0] as TrainPositionEvent;
      }
      return null;
    } catch (error) {
      this.logger.error(
        `Failed to get latest position for train ${trainNumber}`,
        error,
      );
      return null;
    }
  }

  async getTrainPositionHistory(
    trainNumber: string,
    hours: number = 24,
  ): Promise<TrainPositionEvent[]> {
    const now = new Date();
    const startTime = new Date(now.getTime() - hours * 60 * 60 * 1000);

    try {
      const results = await this.queryStream(
        'train-positions',
        `SELECT * FROM "train-positions" WHERE train_number = '${trainNumber}' ORDER BY timestamp ASC`,
        startTime.toISOString(),
        now.toISOString(),
      );
      return results as TrainPositionEvent[];
    } catch (error) {
      this.logger.error(
        `Failed to get position history for train ${trainNumber}`,
        error,
      );
      return [];
    }
  }

  async getStationEvents(
    stationCode: string,
    hours: number = 4,
  ): Promise<PlatformChangeEvent[]> {
    const now = new Date();
    const startTime = new Date(now.getTime() - hours * 60 * 60 * 1000);

    try {
      const results = await this.queryStream(
        'platform-changes',
        `SELECT * FROM "platform-changes" WHERE station_code = '${stationCode}' ORDER BY timestamp DESC`,
        startTime.toISOString(),
        now.toISOString(),
      );
      return results as PlatformChangeEvent[];
    } catch (error) {
      this.logger.error(
        `Failed to get station events for ${stationCode}`,
        error,
      );
      return [];
    }
  }

  async getDelayEvents(
    trainNumber: string,
    hours: number = 24,
  ): Promise<DelayEvent[]> {
    const now = new Date();
    const startTime = new Date(now.getTime() - hours * 60 * 60 * 1000);

    try {
      const results = await this.queryStream(
        'delay-events',
        `SELECT * FROM "delay-events" WHERE train_number = '${trainNumber}' ORDER BY timestamp DESC`,
        startTime.toISOString(),
        now.toISOString(),
      );
      return results as DelayEvent[];
    } catch (error) {
      this.logger.error(
        `Failed to get delay events for train ${trainNumber}`,
        error,
      );
      return [];
    }
  }

  async getPnrStatusChanges(pnr: string): Promise<PnrStatusChangeEvent[]> {
    const now = new Date();
    const startTime = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);

    try {
      const results = await this.queryStream(
        'pnr-status-changes',
        `SELECT * FROM "pnr-status-changes" WHERE pnr = '${pnr}' ORDER BY timestamp DESC`,
        startTime.toISOString(),
        now.toISOString(),
      );
      return results as PnrStatusChangeEvent[];
    } catch (error) {
      this.logger.error(`Failed to get PNR status changes for ${pnr}`, error);
      return [];
    }
  }

  async ingestTrainPosition(event: TrainPositionEvent): Promise<void> {
    await this.ingestEvent('train-positions', event);
  }

  async ingestPlatformChange(event: PlatformChangeEvent): Promise<void> {
    await this.ingestEvent('platform-changes', event);
  }

  async ingestDelayEvent(event: DelayEvent): Promise<void> {
    await this.ingestEvent('delay-events', event);
  }

  async ingestPnrStatusChange(event: PnrStatusChangeEvent): Promise<void> {
    await this.ingestEvent('pnr-status-changes', event);
  }

  // ---- Monitoring & Observability ----

  async logApp(
    level: AppLogEvent['level'],
    message: string,
    context?: string,
    traceId?: string,
  ): Promise<void> {
    try {
      await this.ingestEvent('app-logs', {
        service: 'rail-api',
        level,
        message,
        context: context || '',
        trace_id: traceId || '',
        timestamp: new Date().toISOString(),
      } as AppLogEvent);
    } catch {
      // Silently fail monitoring — never crash the app for observability
    }
  }

  async logApiMetric(metric: Omit<ApiMetricEvent, 'timestamp'>): Promise<void> {
    try {
      await this.ingestEvent('api-metrics', {
        ...metric,
        timestamp: new Date().toISOString(),
      });
    } catch {
      // Silently fail
    }
  }

  async logWorker(
    worker: string,
    job: string,
    level: WorkerLogEvent['level'],
    message: string,
    durationMs?: number,
  ): Promise<void> {
    try {
      await this.ingestEvent('worker-logs', {
        worker,
        job,
        level,
        message,
        duration_ms: durationMs || 0,
        timestamp: new Date().toISOString(),
      } as WorkerLogEvent);
    } catch {
      // Silently fail
    }
  }

  async logSystemEvent(
    service: string,
    event: string,
    details?: Record<string, any>,
  ): Promise<void> {
    try {
      await this.ingestEvent('system-events', {
        service,
        event,
        details: details || {},
        timestamp: new Date().toISOString(),
      } as SystemEvent);
    } catch {
      // Silently fail
    }
  }

  // ---- Monitoring Queries ----

  async getRecentErrors(hours: number = 1): Promise<AppLogEvent[]> {
    const now = new Date();
    const startTime = new Date(now.getTime() - hours * 60 * 60 * 1000);
    try {
      const results = await this.queryStream(
        'app-logs',
        `SELECT * FROM "app-logs" WHERE level IN ('error', 'fatal') ORDER BY timestamp DESC LIMIT 100`,
        startTime.toISOString(),
        now.toISOString(),
      );
      return results as AppLogEvent[];
    } catch {
      return [];
    }
  }

  async getApiMetricsSummary(minutes: number = 15): Promise<any> {
    const now = new Date();
    const startTime = new Date(now.getTime() - minutes * 60 * 1000);
    try {
      const results = await this.queryStream(
        'api-metrics',
        `SELECT
          COUNT(*) as total_requests,
          AVG(duration_ms) as avg_latency_ms,
          MAX(duration_ms) as max_latency_ms,
          COUNT(CASE WHEN status_code >= 500 THEN 1 END) as server_errors,
          COUNT(CASE WHEN status_code >= 400 AND status_code < 500 THEN 1 END) as client_errors
        FROM "api-metrics"`,
        startTime.toISOString(),
        now.toISOString(),
      );
      return results[0] || {};
    } catch {
      return {};
    }
  }

  async getSlowRequests(
    thresholdMs: number = 1000,
    limit: number = 20,
  ): Promise<ApiMetricEvent[]> {
    const now = new Date();
    const oneHourAgo = new Date(now.getTime() - 60 * 60 * 1000);
    try {
      const results = await this.queryStream(
        'api-metrics',
        `SELECT * FROM "api-metrics" WHERE duration_ms > ${thresholdMs} ORDER BY duration_ms DESC LIMIT ${limit}`,
        oneHourAgo.toISOString(),
        now.toISOString(),
      );
      return results as ApiMetricEvent[];
    } catch {
      return [];
    }
  }
}
