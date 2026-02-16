import { Injectable, Logger, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import {
  Train,
  TrainRoute,
  CoachComposition,
  Station,
} from '../common/entities';
import { ParseableService } from '../parseable/parseable.service';
import { CacheService } from '../cache/cache.service';
import { SearchService } from '../search/search.service';
import {
  TrainInfoResponse,
  RouteStopResponse,
  CoachCompositionResponse,
  LiveTrainPositionResponse,
} from './dto/train.dto';

@Injectable()
export class TrainsService {
  private readonly logger = new Logger(TrainsService.name);

  constructor(
    @InjectRepository(Train)
    private readonly trainRepo: Repository<Train>,
    @InjectRepository(TrainRoute)
    private readonly routeRepo: Repository<TrainRoute>,
    @InjectRepository(CoachComposition)
    private readonly coachRepo: Repository<CoachComposition>,
    @InjectRepository(Station)
    private readonly stationRepo: Repository<Station>,
    private readonly parseableService: ParseableService,
    private readonly cacheService: CacheService,
    private readonly searchService: SearchService,
  ) {}

  async getTrainInfo(trainNumber: string): Promise<TrainInfoResponse> {
    const cacheKey = `train:info:${trainNumber}`;
    const cached = await this.cacheService.getJson<TrainInfoResponse>(cacheKey);
    if (cached) return cached;

    const train = await this.trainRepo.findOne({
      where: { number: trainNumber },
      relations: ['source', 'destination', 'routes', 'routes.station'],
    });

    if (!train) {
      throw new NotFoundException(`Train ${trainNumber} not found`);
    }

    const sortedRoutes = (train.routes || []).sort(
      (a, b) => a.stopNumber - b.stopNumber,
    );

    const response: TrainInfoResponse = {
      number: train.number,
      name: train.name,
      type: train.type || '',
      source: {
        code: train.source?.code || train.sourceStation,
        name: train.source?.name || '',
      },
      destination: {
        code: train.destination?.code || train.destinationStation,
        name: train.destination?.name || '',
      },
      runsOn: train.runsOn,
      avgSpeedKmph: train.avgSpeedKmph,
      distanceKm: train.distanceKm,
      durationMinutes: train.durationMinutes,
      amenities: {
        pantry: train.hasPantry,
        charging: train.hasCharging,
        bioToilet: train.hasBioToilet,
        cctv: train.hasCctv,
      },
      schedule: sortedRoutes.map((r) => ({
        stopNumber: r.stopNumber,
        station: {
          code: r.station?.code || r.stationCode,
          name: r.station?.name || '',
        },
        arrivalTime: r.arrivalTime,
        departureTime: r.departureTime,
        haltMinutes: r.haltMinutes,
        distanceFromSource: r.distanceFromSource,
        dayNumber: r.dayNumber,
        platform: r.platform,
      })),
    };

    await this.cacheService.setJson(cacheKey, response, 3600);
    return response;
  }

  async getTrainRoute(trainNumber: string): Promise<RouteStopResponse[]> {
    const cacheKey = `train:route:${trainNumber}`;
    const cached =
      await this.cacheService.getJson<RouteStopResponse[]>(cacheKey);
    if (cached) return cached;

    const train = await this.trainRepo.findOne({
      where: { number: trainNumber },
    });
    if (!train) {
      throw new NotFoundException(`Train ${trainNumber} not found`);
    }

    const routes = await this.routeRepo.find({
      where: { trainNumber },
      relations: ['station'],
      order: { stopNumber: 'ASC' },
    });

    const response: RouteStopResponse[] = routes.map((r) => ({
      stopNumber: r.stopNumber,
      station: {
        code: r.station?.code || r.stationCode,
        name: r.station?.name || '',
      },
      arrivalTime: r.arrivalTime,
      departureTime: r.departureTime,
      haltMinutes: r.haltMinutes,
      distanceFromSource: r.distanceFromSource,
      dayNumber: r.dayNumber,
      platform: r.platform,
    }));

    await this.cacheService.setJson(cacheKey, response, 3600);
    return response;
  }

  async getCoachComposition(
    trainNumber: string,
  ): Promise<CoachCompositionResponse[]> {
    const cacheKey = `train:coaches:${trainNumber}`;
    const cached =
      await this.cacheService.getJson<CoachCompositionResponse[]>(cacheKey);
    if (cached) return cached;

    const train = await this.trainRepo.findOne({
      where: { number: trainNumber },
    });
    if (!train) {
      throw new NotFoundException(`Train ${trainNumber} not found`);
    }

    const coaches = await this.coachRepo.find({
      where: { trainNumber },
      order: { position: 'ASC' },
    });

    const response: CoachCompositionResponse[] = coaches.map((c) => ({
      position: c.position,
      coachLabel: c.coachLabel,
      coachType: c.coachType,
      totalBerths: c.totalBerths,
    }));

    await this.cacheService.setJson(cacheKey, response, 3600);
    return response;
  }

  async getLivePosition(
    trainNumber: string,
  ): Promise<LiveTrainPositionResponse | null> {
    const cacheKey = `train:position:${trainNumber}`;
    const cached =
      await this.cacheService.getJson<LiveTrainPositionResponse>(cacheKey);
    if (cached) return cached;

    const position =
      await this.parseableService.getLatestTrainPosition(trainNumber);
    if (!position) return null;

    const response: LiveTrainPositionResponse = {
      trainNumber: position.train_number,
      latitude: position.latitude,
      longitude: position.longitude,
      speedKmph: position.speed_kmph,
      delayMinutes: position.delay_minutes,
      currentStation: position.current_station,
      nextStation: position.next_station,
      etaNext: position.eta_next,
      timestamp: position.timestamp,
    };

    await this.cacheService.setJson(cacheKey, response, 60);
    return response;
  }

  async getAllLivePositions(): Promise<LiveTrainPositionResponse[]> {
    const cacheKey = 'trains:live:all';
    const cached = await this.cacheService.getJson<LiveTrainPositionResponse[]>(cacheKey);
    if (cached) return cached;

    const trains = await this.trainRepo.find({
      relations: ['source', 'destination'],
    });

    const positions: LiveTrainPositionResponse[] = [];
    for (const train of trains) {
      const pos = await this.getLivePosition(train.number);
      if (pos) {
        positions.push(pos);
      } else {
        // Generate a simulated position along the route
        const routes = await this.routeRepo.find({
          where: { trainNumber: train.number },
          relations: ['station'],
          order: { stopNumber: 'ASC' },
        });
        if (routes.length >= 2) {
          const randomIdx = Math.floor(Math.random() * (routes.length - 1));
          const stop = routes[randomIdx];
          const nextStop = routes[randomIdx + 1];
          if (stop.station && nextStop.station) {
            const sLat = parseFloat(String(stop.station.latitude));
            const sLng = parseFloat(String(stop.station.longitude));
            const nLat = parseFloat(String(nextStop.station.latitude));
            const nLng = parseFloat(String(nextStop.station.longitude));
            const t = Math.random();
            const lat = sLat + (nLat - sLat) * t;
            const lng = sLng + (nLng - sLng) * t;
            positions.push({
              trainNumber: train.number,
              latitude: lat,
              longitude: lng,
              speedKmph: 60 + Math.floor(Math.random() * 80),
              delayMinutes: Math.random() > 0.7 ? Math.floor(Math.random() * 30) : 0,
              currentStation: stop.station.code,
              nextStation: nextStop.station.code,
              etaNext: new Date(Date.now() + Math.random() * 3600000).toISOString(),
              timestamp: new Date().toISOString(),
            });
          }
        }
      }
    }

    await this.cacheService.setJson(cacheKey, positions, 30);
    return positions;
  }

  async searchTrains(query: string) {
    return this.searchService.searchTrains(query);
  }

  async getTrainsBetweenStations(
    fromCode: string,
    toCode: string,
    date?: string,
  ) {
    const dayOfWeek = date
      ? new Date(date).getDay()
      : new Date().getDay();
    // Convert JS day (0=Sun) to Indian Railways bitmap (0=Mon)
    const railwayDayIndex = dayOfWeek === 0 ? 6 : dayOfWeek - 1;

    const query = this.trainRepo
      .createQueryBuilder('t')
      .innerJoin('train_routes', 'r1', 'r1.train_number = t.number')
      .innerJoin('train_routes', 'r2', 'r2.train_number = t.number')
      .innerJoin('stations', 's1', 's1.code = r1.station_code')
      .innerJoin('stations', 's2', 's2.code = r2.station_code')
      .where('r1.station_code = :from', { from: fromCode })
      .andWhere('r2.station_code = :to', { to: toCode })
      .andWhere('r1.stop_number < r2.stop_number')
      .select([
        't.number AS number',
        't.name AS name',
        't.type AS type',
        't.runs_on AS "runsOn"',
        'r1.departure_time AS "departureTime"',
        'r2.arrival_time AS "arrivalTime"',
        'r1.station_code AS "fromStation"',
        'r2.station_code AS "toStation"',
        's1.name AS "fromStationName"',
        's2.name AS "toStationName"',
        '(r2.distance_from_source - r1.distance_from_source) AS distance',
      ]);

    const results = await query.getRawMany();

    return results
      .filter((r) => {
        const runsOn = r.runsOn || '1111111';
        return runsOn[railwayDayIndex] === '1';
      })
      .map((r) => ({
        number: r.number,
        name: r.name,
        type: r.type,
        runsOn: r.runsOn,
        from: {
          code: r.fromStation,
          name: r.fromStationName,
          departureTime: r.departureTime,
        },
        to: {
          code: r.toStation,
          name: r.toStationName,
          arrivalTime: r.arrivalTime,
        },
        distance: r.distance,
      }));
  }
}
