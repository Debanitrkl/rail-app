import { Injectable, OnModuleInit, OnModuleDestroy, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import Redis from 'ioredis';

@Injectable()
export class CacheService implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(CacheService.name);
  private client: Redis;
  private subscriber: Redis;
  private publisher: Redis;
  private subscriptions: Map<string, Set<(message: string) => void>> = new Map();

  constructor(private readonly configService: ConfigService) {
    const host = this.configService.get<string>('VALKEY_HOST', 'localhost');
    const port = this.configService.get<number>('VALKEY_PORT', 6379);

    const connectionOptions = {
      host,
      port,
      maxRetriesPerRequest: 3,
      retryStrategy: (times: number) => {
        if (times > 10) return null;
        return Math.min(times * 200, 5000);
      },
      lazyConnect: true,
    };

    this.client = new Redis(connectionOptions);
    this.subscriber = new Redis(connectionOptions);
    this.publisher = new Redis(connectionOptions);
  }

  async onModuleInit() {
    try {
      await Promise.all([
        this.client.connect(),
        this.subscriber.connect(),
        this.publisher.connect(),
      ]);
      this.logger.log('Connected to Valkey');

      this.subscriber.on('message', (channel: string, message: string) => {
        const handlers = this.subscriptions.get(channel);
        if (handlers) {
          handlers.forEach((handler) => {
            try {
              handler(message);
            } catch (err) {
              this.logger.error(`Error in subscription handler for ${channel}:`, err);
            }
          });
        }
      });
    } catch (error) {
      this.logger.error('Failed to connect to Valkey', error);
    }
  }

  async onModuleDestroy() {
    await Promise.all([
      this.client.quit(),
      this.subscriber.quit(),
      this.publisher.quit(),
    ]);
  }

  async get(key: string): Promise<string | null> {
    try {
      return await this.client.get(key);
    } catch (error) {
      this.logger.error(`Cache get error for key ${key}:`, error);
      return null;
    }
  }

  async set(key: string, value: string, ttlSeconds?: number): Promise<void> {
    try {
      if (ttlSeconds) {
        await this.client.set(key, value, 'EX', ttlSeconds);
      } else {
        await this.client.set(key, value);
      }
    } catch (error) {
      this.logger.error(`Cache set error for key ${key}:`, error);
    }
  }

  async getJson<T>(key: string): Promise<T | null> {
    const value = await this.get(key);
    if (!value) return null;
    try {
      return JSON.parse(value) as T;
    } catch {
      return null;
    }
  }

  async setJson<T>(key: string, value: T, ttlSeconds?: number): Promise<void> {
    await this.set(key, JSON.stringify(value), ttlSeconds);
  }

  async del(key: string): Promise<void> {
    try {
      await this.client.del(key);
    } catch (error) {
      this.logger.error(`Cache del error for key ${key}:`, error);
    }
  }

  async delPattern(pattern: string): Promise<void> {
    try {
      const keys = await this.client.keys(pattern);
      if (keys.length > 0) {
        await this.client.del(...keys);
      }
    } catch (error) {
      this.logger.error(`Cache del pattern error for ${pattern}:`, error);
    }
  }

  async publish(channel: string, message: string): Promise<void> {
    try {
      await this.publisher.publish(channel, message);
    } catch (error) {
      this.logger.error(`Publish error for channel ${channel}:`, error);
    }
  }

  async publishJson<T>(channel: string, data: T): Promise<void> {
    await this.publish(channel, JSON.stringify(data));
  }

  async subscribe(
    channel: string,
    handler: (message: string) => void,
  ): Promise<void> {
    if (!this.subscriptions.has(channel)) {
      this.subscriptions.set(channel, new Set());
      await this.subscriber.subscribe(channel);
    }
    this.subscriptions.get(channel)!.add(handler);
  }

  async unsubscribe(
    channel: string,
    handler?: (message: string) => void,
  ): Promise<void> {
    if (handler) {
      const handlers = this.subscriptions.get(channel);
      if (handlers) {
        handlers.delete(handler);
        if (handlers.size === 0) {
          this.subscriptions.delete(channel);
          await this.subscriber.unsubscribe(channel);
        }
      }
    } else {
      this.subscriptions.delete(channel);
      await this.subscriber.unsubscribe(channel);
    }
  }

  getClient(): Redis {
    return this.client;
  }
}
