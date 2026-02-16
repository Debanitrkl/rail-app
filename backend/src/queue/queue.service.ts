import { Injectable, Logger, OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Queue, Worker, Job, QueueEvents } from 'bullmq';

export enum QueueName {
  TRAIN_POSITION_POLL = 'train-position-poll',
  PNR_REFRESH = 'pnr-refresh',
  NOTIFICATION_DISPATCH = 'notification-dispatch',
  DATA_SYNC = 'data-sync',
}

export interface TrainPositionPollJob {
  trainNumber: string;
}

export interface PnrRefreshJob {
  pnr: string;
  userId: string;
}

export interface NotificationDispatchJob {
  userId: string;
  type: 'delay' | 'platform_change' | 'pnr_update' | 'departure_reminder';
  title: string;
  body: string;
  data: Record<string, any>;
}

export interface DataSyncJob {
  type: 'stations' | 'trains' | 'all';
}

@Injectable()
export class QueueService implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(QueueService.name);
  private queues: Map<string, Queue> = new Map();
  private workers: Map<string, Worker> = new Map();
  private connection: { host: string; port: number };

  constructor(private readonly configService: ConfigService) {
    this.connection = {
      host: this.configService.get<string>('VALKEY_HOST', 'localhost'),
      port: this.configService.get<number>('VALKEY_PORT', 6379),
    };
  }

  async onModuleInit() {
    try {
      for (const name of Object.values(QueueName)) {
        const queue = new Queue(name, { connection: this.connection });
        this.queues.set(name, queue);
        this.logger.log(`Queue initialized: ${name}`);
      }

      await this.setupRepeatingJobs();
    } catch (error) {
      this.logger.error('Failed to initialize queues', error);
    }
  }

  async onModuleDestroy() {
    for (const [name, worker] of this.workers) {
      await worker.close();
      this.logger.log(`Worker closed: ${name}`);
    }
    for (const [name, queue] of this.queues) {
      await queue.close();
      this.logger.log(`Queue closed: ${name}`);
    }
  }

  private async setupRepeatingJobs() {
    const dataSyncQueue = this.getQueue(QueueName.DATA_SYNC);
    if (dataSyncQueue) {
      await dataSyncQueue.add(
        'sync-all',
        { type: 'all' } as DataSyncJob,
        {
          repeat: { every: 3600000 },
          removeOnComplete: 10,
          removeOnFail: 5,
        },
      );
    }
  }

  getQueue(name: QueueName): Queue | undefined {
    return this.queues.get(name);
  }

  registerWorker(
    name: QueueName,
    processor: (job: Job) => Promise<void>,
  ): Worker {
    const worker = new Worker(name, processor, {
      connection: this.connection,
      concurrency: 5,
      limiter: {
        max: 10,
        duration: 1000,
      },
    });

    worker.on('completed', (job: Job) => {
      this.logger.debug(`Job ${job.id} completed in queue ${name}`);
    });

    worker.on('failed', (job: Job | undefined, err: Error) => {
      this.logger.error(
        `Job ${job?.id} failed in queue ${name}: ${err.message}`,
      );
    });

    worker.on('error', (err: Error) => {
      this.logger.error(`Worker error in queue ${name}: ${err.message}`);
    });

    this.workers.set(name, worker);
    this.logger.log(`Worker registered for queue: ${name}`);
    return worker;
  }

  async addJob<T>(
    queueName: QueueName,
    jobName: string,
    data: T,
    opts?: {
      delay?: number;
      priority?: number;
      attempts?: number;
      removeOnComplete?: boolean | number;
      removeOnFail?: boolean | number;
    },
  ): Promise<Job<T>> {
    const queue = this.queues.get(queueName);
    if (!queue) {
      throw new Error(`Queue ${queueName} not found`);
    }

    return queue.add(jobName, data, {
      attempts: opts?.attempts ?? 3,
      backoff: {
        type: 'exponential',
        delay: 2000,
      },
      removeOnComplete: opts?.removeOnComplete ?? 100,
      removeOnFail: opts?.removeOnFail ?? 50,
      ...opts,
    });
  }

  async addTrainPositionPoll(trainNumber: string): Promise<void> {
    await this.addJob(
      QueueName.TRAIN_POSITION_POLL,
      `poll-${trainNumber}`,
      { trainNumber } as TrainPositionPollJob,
    );
  }

  async addPnrRefresh(pnr: string, userId: string): Promise<void> {
    await this.addJob(QueueName.PNR_REFRESH, `refresh-${pnr}`, {
      pnr,
      userId,
    } as PnrRefreshJob);
  }

  async addNotification(
    userId: string,
    type: NotificationDispatchJob['type'],
    title: string,
    body: string,
    data: Record<string, any>,
  ): Promise<void> {
    await this.addJob(
      QueueName.NOTIFICATION_DISPATCH,
      `notify-${userId}-${Date.now()}`,
      { userId, type, title, body, data } as NotificationDispatchJob,
    );
  }

  async addDataSync(type: DataSyncJob['type']): Promise<void> {
    await this.addJob(QueueName.DATA_SYNC, `sync-${type}`, {
      type,
    } as DataSyncJob);
  }
}
