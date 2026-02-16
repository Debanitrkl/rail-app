import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { Job } from 'bullmq';
import { QueueService, QueueName, PnrRefreshJob } from '../queue.service';
import { ParseableService } from '../../parseable/parseable.service';
import { CacheService } from '../../cache/cache.service';

@Injectable()
export class PnrRefreshProcessor implements OnModuleInit {
  private readonly logger = new Logger(PnrRefreshProcessor.name);

  constructor(
    private readonly queueService: QueueService,
    private readonly parseableService: ParseableService,
    private readonly cacheService: CacheService,
  ) {}

  onModuleInit() {
    this.queueService.registerWorker(
      QueueName.PNR_REFRESH,
      this.process.bind(this),
    );
    this.logger.log('PNR refresh processor registered');
  }

  async process(job: Job<PnrRefreshJob>): Promise<void> {
    const { pnr, userId } = job.data;
    this.logger.debug(`Refreshing PNR ${pnr} for user ${userId}`);

    try {
      const statusChanges =
        await this.parseableService.getPnrStatusChanges(pnr);

      if (statusChanges.length > 0) {
        const latestStatus = statusChanges[0];
        const cacheKey = `pnr:status:${pnr}`;
        await this.cacheService.setJson(cacheKey, latestStatus, 300);

        await this.cacheService.publishJson(`pnr:update:${pnr}`, {
          pnr,
          status: latestStatus,
          updatedAt: new Date().toISOString(),
        });
      }
    } catch (error) {
      this.logger.error(`Failed to refresh PNR ${pnr}`, error);
      throw error;
    }
  }
}
