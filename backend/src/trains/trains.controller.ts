import {
  Controller,
  Get,
  Param,
  Query,
  Sse,
  Logger,
  NotFoundException,
  MessageEvent,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiParam, ApiQuery } from '@nestjs/swagger';
import { Observable, Subject, interval, switchMap, startWith, map, finalize } from 'rxjs';
import { TrainsService } from './trains.service';
import { CacheService } from '../cache/cache.service';
import { ApiResponseDto } from '../common/dto/api-response.dto';
import { SearchTrainsDto, TrainsBetweenDto } from './dto/train.dto';

@ApiTags('Trains')
@Controller('api/v1/trains')
export class TrainsController {
  private readonly logger = new Logger(TrainsController.name);

  constructor(
    private readonly trainsService: TrainsService,
    private readonly cacheService: CacheService,
  ) {}

  @Get('live/all')
  @ApiOperation({ summary: 'Get all active train positions' })
  async getAllLivePositions() {
    const positions = await this.trainsService.getAllLivePositions();
    return new ApiResponseDto(positions);
  }

  @Get('search')
  @ApiOperation({ summary: 'Search trains by name or number' })
  @ApiQuery({ name: 'q', required: true })
  async searchTrains(@Query() dto: SearchTrainsDto) {
    const results = await this.trainsService.searchTrains(dto.q);
    return new ApiResponseDto(results);
  }

  @Get('between')
  @ApiOperation({ summary: 'Find trains between two stations' })
  @ApiQuery({ name: 'from', required: true, example: 'NDLS' })
  @ApiQuery({ name: 'to', required: true, example: 'BCT' })
  @ApiQuery({ name: 'date', required: false })
  async getTrainsBetween(@Query() dto: TrainsBetweenDto) {
    const results = await this.trainsService.getTrainsBetweenStations(
      dto.from,
      dto.to,
      dto.date,
    );
    return new ApiResponseDto(results);
  }

  @Get(':trainNumber')
  @ApiOperation({ summary: 'Get train information and schedule' })
  @ApiParam({ name: 'trainNumber', example: '12301' })
  async getTrainInfo(@Param('trainNumber') trainNumber: string) {
    const train = await this.trainsService.getTrainInfo(trainNumber);
    return new ApiResponseDto(train);
  }

  @Sse(':trainNumber/live')
  @ApiOperation({ summary: 'SSE endpoint for live train position' })
  @ApiParam({ name: 'trainNumber', example: '12301' })
  liveTrainPosition(
    @Param('trainNumber') trainNumber: string,
  ): Observable<MessageEvent> {
    const subject = new Subject<MessageEvent>();

    const handler = (message: string) => {
      try {
        const data = JSON.parse(message);
        subject.next({ data } as MessageEvent);
      } catch (err) {
        this.logger.error('Failed to parse live train data', err);
      }
    };

    const channel = `train:live:${trainNumber}`;
    this.cacheService.subscribe(channel, handler);

    // Send initial position from cache
    this.trainsService.getLivePosition(trainNumber).then((position) => {
      if (position) {
        subject.next({ data: position } as MessageEvent);
      }
    });

    // Periodic poll every 30 seconds as fallback
    const pollInterval = setInterval(async () => {
      try {
        const position =
          await this.trainsService.getLivePosition(trainNumber);
        if (position) {
          subject.next({ data: position } as MessageEvent);
        }
      } catch (err) {
        this.logger.error('Periodic poll failed', err);
      }
    }, 30000);

    return subject.asObservable().pipe(
      finalize(() => {
        this.cacheService.unsubscribe(channel, handler);
        clearInterval(pollInterval);
        this.logger.debug(`SSE client disconnected for train ${trainNumber}`);
      }),
    );
  }

  @Get(':trainNumber/route')
  @ApiOperation({ summary: 'Get full route with all stops' })
  @ApiParam({ name: 'trainNumber', example: '12301' })
  async getTrainRoute(@Param('trainNumber') trainNumber: string) {
    const route = await this.trainsService.getTrainRoute(trainNumber);
    return new ApiResponseDto(route);
  }

  @Get(':trainNumber/coach-composition')
  @ApiOperation({ summary: 'Get coach composition/layout' })
  @ApiParam({ name: 'trainNumber', example: '12301' })
  async getCoachComposition(@Param('trainNumber') trainNumber: string) {
    const coaches =
      await this.trainsService.getCoachComposition(trainNumber);
    return new ApiResponseDto(coaches);
  }
}
