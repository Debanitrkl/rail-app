import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { Job } from 'bullmq';
import { QueueService, QueueName, DataSyncJob } from '../queue.service';
import { SearchService } from '../../search/search.service';

@Injectable()
export class DataSyncProcessor implements OnModuleInit {
  private readonly logger = new Logger(DataSyncProcessor.name);

  constructor(
    private readonly queueService: QueueService,
    private readonly searchService: SearchService,
  ) {}

  onModuleInit() {
    this.queueService.registerWorker(
      QueueName.DATA_SYNC,
      this.process.bind(this),
    );
    this.logger.log('Data sync processor registered');
  }

  async process(job: Job<DataSyncJob>): Promise<void> {
    const { type } = job.data;
    this.logger.debug(`Running data sync: ${type}`);

    try {
      await this.searchService.syncData();
      this.logger.log(`Data sync completed: ${type}`);
    } catch (error) {
      this.logger.error(`Data sync failed: ${type}`, error);
      throw error;
    }
  }
}
