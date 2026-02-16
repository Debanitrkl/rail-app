import { Module, Global } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { SearchService } from './search.service';
import { Station, Train } from '../common/entities';

@Global()
@Module({
  imports: [ConfigModule, TypeOrmModule.forFeature([Station, Train])],
  providers: [SearchService],
  exports: [SearchService],
})
export class SearchModule {}
