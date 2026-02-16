import { Module, Global } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { QueueService } from './queue.service';
import { TrainPositionProcessor } from './processors/train-position.processor';
import { PnrRefreshProcessor } from './processors/pnr-refresh.processor';
import { NotificationDispatchProcessor } from './processors/notification-dispatch.processor';
import { DataSyncProcessor } from './processors/data-sync.processor';

@Global()
@Module({
  imports: [ConfigModule],
  providers: [
    QueueService,
    TrainPositionProcessor,
    PnrRefreshProcessor,
    NotificationDispatchProcessor,
    DataSyncProcessor,
  ],
  exports: [QueueService],
})
export class QueueModule {}
