import { Module } from '@nestjs/common';
import { MetricsController } from './metrics.controller';
import { MetricsService } from './metrics.service';
import { ParseableModule } from '../parseable/parseable.module';

@Module({
  imports: [ParseableModule],
  controllers: [MetricsController],
  providers: [MetricsService],
})
export class MetricsModule {}
