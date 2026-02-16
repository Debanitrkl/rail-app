import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { TrainsController } from './trains.controller';
import { TrainsService } from './trains.service';
import { Train, TrainRoute, CoachComposition, Station } from '../common/entities';

@Module({
  imports: [
    TypeOrmModule.forFeature([Train, TrainRoute, CoachComposition, Station]),
  ],
  controllers: [TrainsController],
  providers: [TrainsService],
  exports: [TrainsService],
})
export class TrainsModule {}
