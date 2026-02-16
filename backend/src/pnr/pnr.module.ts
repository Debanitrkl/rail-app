import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { PnrController } from './pnr.controller';
import { PnrService } from './pnr.service';
import { PnrWatchlist, User } from '../common/entities';

@Module({
  imports: [TypeOrmModule.forFeature([PnrWatchlist, User])],
  controllers: [PnrController],
  providers: [PnrService],
  exports: [PnrService],
})
export class PnrModule {}
