import { Injectable, Logger, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Station, TrainRoute, Train } from '../common/entities';
import { ParseableService } from '../parseable/parseable.service';
import { CacheService } from '../cache/cache.service';
import { SearchService } from '../search/search.service';
import {
  StationInfoResponse,
  StationTrainResponse,
  PlatformStatusResponse,
} from './dto/station.dto';

@Injectable()
export class StationsService {
  private readonly logger = new Logger(StationsService.name);

  constructor(
    @InjectRepository(Station)
    private readonly stationRepo: Repository<Station>,
    @InjectRepository(TrainRoute)
    private readonly routeRepo: Repository<TrainRoute>,
    @InjectRepository(Train)
    private readonly trainRepo: Repository<Train>,
    private readonly parseableService: ParseableService,
    private readonly cacheService: CacheService,
    private readonly searchService: SearchService,
  ) {}

  async getStationInfo(code: string): Promise<StationInfoResponse> {
    const cacheKey = `station:info:${code}`;
    const cached =
      await this.cacheService.getJson<StationInfoResponse>(cacheKey);
    if (cached) return cached;

    const station = await this.stationRepo.findOne({
      where: { code: code.toUpperCase() },
    });

    if (!station) {
      throw new NotFoundException(`Station ${code} not found`);
    }

    const routes = await this.routeRepo.find({
      where: { stationCode: code.toUpperCase() },
      relations: ['train'],
      order: { departureTime: 'ASC' },
    });

    const trains: StationTrainResponse[] = routes.map((r) => ({
      trainNumber: r.trainNumber,
      trainName: r.train?.name || '',
      arrivalTime: r.arrivalTime,
      departureTime: r.departureTime,
      platform: r.platform,
      stopNumber: r.stopNumber,
    }));

    const response: StationInfoResponse = {
      code: station.code,
      name: station.name,
      zone: station.zone || '',
      division: station.division || '',
      state: station.state || '',
      latitude: Number(station.latitude),
      longitude: Number(station.longitude),
      platformsCount: station.platformsCount,
      amenities: {
        wifi: station.hasWifi,
        parking: station.hasParking,
      },
      trains,
    };

    await this.cacheService.setJson(cacheKey, response, 1800);
    return response;
  }

  async getPlatformStatus(code: string): Promise<PlatformStatusResponse[]> {
    const station = await this.stationRepo.findOne({
      where: { code: code.toUpperCase() },
    });

    if (!station) {
      throw new NotFoundException(`Station ${code} not found`);
    }

    const events = await this.parseableService.getStationEvents(
      code.toUpperCase(),
    );

    const platformMap = new Map<
      number,
      { currentTrain: string | null; nextTrain: string | null }
    >();

    for (let i = 1; i <= station.platformsCount; i++) {
      platformMap.set(i, { currentTrain: null, nextTrain: null });
    }

    for (const event of events) {
      const platNum = parseInt(event.platform_number, 10);
      if (!isNaN(platNum) && platformMap.has(platNum)) {
        const plat = platformMap.get(platNum)!;
        if (event.event_type === 'arrival' && !plat.currentTrain) {
          plat.currentTrain = event.train_number;
        } else if (event.event_type === 'expected' && !plat.nextTrain) {
          plat.nextTrain = event.train_number;
        }
      }
    }

    return Array.from(platformMap.entries()).map(([num, data]) => ({
      platformNumber: num,
      currentTrain: data.currentTrain,
      nextTrain: data.nextTrain,
      status: data.currentTrain
        ? 'occupied'
        : data.nextTrain
          ? 'reserved'
          : 'available',
    }));
  }

  async searchStations(query: string) {
    return this.searchService.searchStations(query);
  }
}
