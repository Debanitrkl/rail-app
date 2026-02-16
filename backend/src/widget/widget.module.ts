import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { WidgetController } from './widget.controller';
import { WidgetService } from './widget.service';
import { Journey, Train, Station, PnrWatchlist } from '../common/entities';

@Module({
  imports: [
    TypeOrmModule.forFeature([Journey, Train, Station, PnrWatchlist]),
  ],
  controllers: [WidgetController],
  providers: [WidgetService],
})
export class WidgetModule {}
