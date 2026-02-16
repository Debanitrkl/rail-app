import { Injectable, Logger, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import {
  Journey,
  Train,
  Station,
  PnrWatchlist,
} from '../common/entities';
import { ParseableService } from '../parseable/parseable.service';
import { CacheService } from '../cache/cache.service';
import {
  WidgetJourneyResponse,
  WidgetPnrResponse,
} from './dto/widget.dto';

@Injectable()
export class WidgetService {
  private readonly logger = new Logger(WidgetService.name);

  constructor(
    @InjectRepository(Journey)
    private readonly journeyRepo: Repository<Journey>,
    @InjectRepository(PnrWatchlist)
    private readonly watchlistRepo: Repository<PnrWatchlist>,
    private readonly parseableService: ParseableService,
    private readonly cacheService: CacheService,
  ) {}

  async getJourneyWidget(
    journeyId: string,
  ): Promise<WidgetJourneyResponse> {
    const cacheKey = `widget:journey:${journeyId}`;
    const cached =
      await this.cacheService.getJson<WidgetJourneyResponse>(cacheKey);
    if (cached) return cached;

    const journey = await this.journeyRepo.findOne({
      where: { id: journeyId },
      relations: ['train', 'boarding', 'destinationStationEntity'],
    });

    if (!journey) {
      throw new NotFoundException(`Journey ${journeyId} not found`);
    }

    // Get live position
    const position = await this.parseableService.getLatestTrainPosition(
      journey.trainNumber,
    );

    const response: WidgetJourneyResponse = {
      journeyId: journey.id,
      trainNumber: journey.trainNumber,
      trainName: journey.train?.name || '',
      from: journey.boarding?.name || journey.boardingStation,
      to:
        journey.destinationStationEntity?.name ||
        journey.destinationStation,
      departureTime: '',
      arrivalTime: '',
      status: journey.status,
      delayMinutes: position?.delay_minutes || 0,
      currentStation: position?.current_station || '',
      platform: '',
      coach: journey.coach || '',
      berth: journey.berth || '',
    };

    await this.cacheService.setJson(cacheKey, response, 60);
    return response;
  }

  async getPnrWidget(pnrNumber: string): Promise<WidgetPnrResponse> {
    const cacheKey = `widget:pnr:${pnrNumber}`;
    const cached =
      await this.cacheService.getJson<WidgetPnrResponse>(cacheKey);
    if (cached) return cached;

    const statusChanges =
      await this.parseableService.getPnrStatusChanges(pnrNumber);

    const watchEntry = await this.watchlistRepo.findOne({
      where: { pnr: pnrNumber },
    });

    const latest = statusChanges.length > 0 ? statusChanges[0] : null;

    const response: WidgetPnrResponse = {
      pnr: pnrNumber,
      trainNumber: watchEntry?.trainNumber || '',
      currentStatus: latest?.new_status || 'Unknown',
      coach: latest?.coach || '',
      berth: latest?.berth || '',
      lastUpdated: latest?.timestamp || new Date().toISOString(),
    };

    await this.cacheService.setJson(cacheKey, response, 120);
    return response;
  }
}
