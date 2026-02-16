import {
  Controller,
  Get,
  Param,
  Query,
  Sse,
  Logger,
  MessageEvent,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiParam, ApiQuery } from '@nestjs/swagger';
import { Observable, Subject, finalize } from 'rxjs';
import { StationsService } from './stations.service';
import { CacheService } from '../cache/cache.service';
import { ApiResponseDto } from '../common/dto/api-response.dto';
import { SearchStationsDto } from './dto/station.dto';

@ApiTags('Stations')
@Controller('api/v1/stations')
export class StationsController {
  private readonly logger = new Logger(StationsController.name);

  constructor(
    private readonly stationsService: StationsService,
    private readonly cacheService: CacheService,
  ) {}

  @Get('search')
  @ApiOperation({ summary: 'Search stations by name or code' })
  @ApiQuery({ name: 'q', required: true })
  async searchStations(@Query() dto: SearchStationsDto) {
    const results = await this.stationsService.searchStations(dto.q);
    return new ApiResponseDto(results);
  }

  @Get(':code')
  @ApiOperation({ summary: 'Get station information' })
  @ApiParam({ name: 'code', example: 'NDLS' })
  async getStationInfo(@Param('code') code: string) {
    const station = await this.stationsService.getStationInfo(code);
    return new ApiResponseDto(station);
  }

  @Sse(':code/live')
  @ApiOperation({ summary: 'SSE live departures/arrivals board' })
  @ApiParam({ name: 'code', example: 'NDLS' })
  liveStationBoard(
    @Param('code') code: string,
  ): Observable<MessageEvent> {
    const subject = new Subject<MessageEvent>();
    const channel = `station:live:${code.toUpperCase()}`;

    const handler = (message: string) => {
      try {
        const data = JSON.parse(message);
        subject.next({ data } as MessageEvent);
      } catch (err) {
        this.logger.error('Failed to parse station live data', err);
      }
    };

    this.cacheService.subscribe(channel, handler);

    // Send initial platform status
    this.stationsService.getPlatformStatus(code).then((platforms) => {
      subject.next({
        data: { type: 'initial_status', platforms },
      } as MessageEvent);
    });

    // Periodic refresh every 60 seconds
    const pollInterval = setInterval(async () => {
      try {
        const platforms = await this.stationsService.getPlatformStatus(code);
        subject.next({
          data: { type: 'platform_refresh', platforms },
        } as MessageEvent);
      } catch (err) {
        this.logger.error('Station periodic poll failed', err);
      }
    }, 60000);

    return subject.asObservable().pipe(
      finalize(() => {
        this.cacheService.unsubscribe(channel, handler);
        clearInterval(pollInterval);
        this.logger.debug(`SSE client disconnected for station ${code}`);
      }),
    );
  }

  @Get(':code/platforms')
  @ApiOperation({ summary: 'Get platform status for station' })
  @ApiParam({ name: 'code', example: 'NDLS' })
  async getPlatformStatus(@Param('code') code: string) {
    const platforms = await this.stationsService.getPlatformStatus(code);
    return new ApiResponseDto(platforms);
  }
}
