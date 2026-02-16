import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { JourneysController } from './journeys.controller';
import { JourneysService } from './journeys.service';
import { Journey, Train, Station, User } from '../common/entities';

@Module({
  imports: [TypeOrmModule.forFeature([Journey, Train, Station, User])],
  controllers: [JourneysController],
  providers: [JourneysService],
  exports: [JourneysService],
})
export class JourneysModule {}
