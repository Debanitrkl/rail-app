import { Module, Global } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { ParseableService } from './parseable.service';

@Global()
@Module({
  imports: [ConfigModule],
  providers: [ParseableService],
  exports: [ParseableService],
})
export class ParseableModule {}
