import { MiddlewareConsumer, Module, NestModule } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { TrainsModule } from './trains/trains.module';
import { StationsModule } from './stations/stations.module';
import { PnrModule } from './pnr/pnr.module';
import { JourneysModule } from './journeys/journeys.module';
import { NotificationsModule } from './notifications/notifications.module';
import { WidgetModule } from './widget/widget.module';
import { ParseableModule } from './parseable/parseable.module';
import { SearchModule } from './search/search.module';
import { CacheModule } from './cache/cache.module';
import { QueueModule } from './queue/queue.module';
import { HealthModule } from './health/health.module';
import { MetricsModule } from './metrics/metrics.module';
import { ApiMetricsMiddleware } from './common/middleware/api-metrics.middleware';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),
    TypeOrmModule.forRootAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: (configService: ConfigService) => ({
        type: 'postgres',
        host: configService.get<string>('POSTGRES_HOST', 'localhost'),
        port: configService.get<number>('POSTGRES_PORT', 5432),
        username: configService.get<string>('POSTGRES_USER', 'rail'),
        password: configService.get<string>('POSTGRES_PASSWORD', 'rail_secret_2024'),
        database: configService.get<string>('POSTGRES_DB', 'rail'),
        entities: [__dirname + '/**/*.entity{.ts,.js}'],
        synchronize: false,
        logging: configService.get<string>('NODE_ENV') === 'development',
      }),
    }),
    TrainsModule,
    StationsModule,
    PnrModule,
    JourneysModule,
    NotificationsModule,
    WidgetModule,
    ParseableModule,
    SearchModule,
    CacheModule,
    QueueModule,
    HealthModule,
    MetricsModule,
  ],
})
export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    consumer.apply(ApiMetricsMiddleware).forRoutes('*');
  }
}
