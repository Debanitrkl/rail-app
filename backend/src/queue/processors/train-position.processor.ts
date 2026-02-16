import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { Job } from 'bullmq';
import { QueueService, QueueName, TrainPositionPollJob } from '../queue.service';
import { ParseableService } from '../../parseable/parseable.service';
import { CacheService } from '../../cache/cache.service';

@Injectable()
export class TrainPositionProcessor implements OnModuleInit {
  private readonly logger = new Logger(TrainPositionProcessor.name);

  constructor(
    private readonly queueService: QueueService,
    private readonly parseableService: ParseableService,
    private readonly cacheService: CacheService,
  ) {}

  onModuleInit() {
    this.queueService.registerWorker(
      QueueName.TRAIN_POSITION_POLL,
      this.process.bind(this),
    );
    this.logger.log('Train position processor registered');
  }

  async process(job: Job<TrainPositionPollJob>): Promise<void> {
    const { trainNumber } = job.data;
    this.logger.debug(`Polling position for train ${trainNumber}`);

    try {
      const position =
        await this.parseableService.getLatestTrainPosition(trainNumber);

      if (position) {
        const cacheKey = `train:position:${trainNumber}`;
        await this.cacheService.setJson(cacheKey, position, 120);

        await this.cacheService.publishJson(
          `train:live:${trainNumber}`,
          position,
        );

        if (position.current_station) {
          await this.cacheService.publishJson(
            `station:live:${position.current_station}`,
            {
              type: 'train_position_update',
              ...position,
            },
          );
        }
      }
    } catch (error) {
      this.logger.error(
        `Failed to poll position for train ${trainNumber}`,
        error,
      );
      throw error;
    }
  }
}
