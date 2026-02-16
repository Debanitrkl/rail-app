import {
  Injectable,
  Logger,
  NotFoundException,
  ConflictException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { PnrWatchlist } from '../common/entities';
import { ParseableService } from '../parseable/parseable.service';
import { CacheService } from '../cache/cache.service';
import { QueueService } from '../queue/queue.service';
import {
  PnrStatusResponse,
  PnrPassengerStatus,
  WatchedPnrResponse,
  WatchPnrDto,
} from './dto/pnr.dto';

@Injectable()
export class PnrService {
  private readonly logger = new Logger(PnrService.name);

  constructor(
    @InjectRepository(PnrWatchlist)
    private readonly watchlistRepo: Repository<PnrWatchlist>,
    private readonly parseableService: ParseableService,
    private readonly cacheService: CacheService,
    private readonly queueService: QueueService,
  ) {}

  async getPnrStatus(pnrNumber: string): Promise<PnrStatusResponse> {
    const cacheKey = `pnr:status:${pnrNumber}`;
    const cached =
      await this.cacheService.getJson<PnrStatusResponse>(cacheKey);
    if (cached) return cached;

    const statusChanges =
      await this.parseableService.getPnrStatusChanges(pnrNumber);

    // Build response from Parseable events or generate a default response
    const response: PnrStatusResponse = {
      pnr: pnrNumber,
      trainNumber: '',
      trainName: '',
      from: '',
      to: '',
      travelDate: '',
      bookingStatus: 'CNF',
      currentStatus: 'CNF',
      passengers: [],
      lastUpdated: new Date().toISOString(),
    };

    if (statusChanges.length > 0) {
      const latest = statusChanges[0];
      response.currentStatus = latest.new_status;
      response.passengers = [
        {
          number: 1,
          bookingStatus: latest.old_status || 'WL',
          currentStatus: latest.new_status,
          coach: latest.coach || '',
          berth: latest.berth || '',
        },
      ];
      response.lastUpdated = latest.timestamp;
    }

    // Check if we have a watchlist entry with more info
    const watchEntry = await this.watchlistRepo.findOne({
      where: { pnr: pnrNumber },
    });

    if (watchEntry) {
      response.trainNumber = watchEntry.trainNumber || '';
      response.travelDate = watchEntry.travelDate
        ? watchEntry.travelDate.toISOString().split('T')[0]
        : '';
      if (watchEntry.lastStatus) {
        Object.assign(response, watchEntry.lastStatus);
      }
    }

    await this.cacheService.setJson(cacheKey, response, 300);
    return response;
  }

  async watchPnr(userId: string, dto: WatchPnrDto): Promise<WatchedPnrResponse> {
    const existing = await this.watchlistRepo.findOne({
      where: { userId, pnr: dto.pnr },
    });

    if (existing) {
      throw new ConflictException(`PNR ${dto.pnr} is already being watched`);
    }

    const entry = new PnrWatchlist();
    entry.userId = userId;
    entry.pnr = dto.pnr;
    entry.trainNumber = dto.trainNumber || null;
    entry.travelDate = dto.travelDate ? new Date(dto.travelDate) : null;
    entry.lastCheckedAt = new Date();

    const saved = await this.watchlistRepo.save(entry);

    // Queue an immediate refresh
    await this.queueService.addPnrRefresh(dto.pnr, userId);

    return this.toWatchedResponse(saved);
  }

  async unwatchPnr(userId: string, pnrNumber: string): Promise<void> {
    const entry = await this.watchlistRepo.findOne({
      where: { userId, pnr: pnrNumber },
    });

    if (!entry) {
      throw new NotFoundException(`PNR ${pnrNumber} not found in watchlist`);
    }

    await this.watchlistRepo.remove(entry);
    await this.cacheService.del(`pnr:status:${pnrNumber}`);
  }

  async getWatchedPnrs(userId: string): Promise<WatchedPnrResponse[]> {
    const entries = await this.watchlistRepo.find({
      where: { userId },
      order: { createdAt: 'DESC' },
    });

    return entries.map((e) => this.toWatchedResponse(e));
  }

  private toWatchedResponse(entry: PnrWatchlist): WatchedPnrResponse {
    return {
      id: entry.id,
      pnr: entry.pnr,
      trainNumber: entry.trainNumber || '',
      travelDate: entry.travelDate
        ? entry.travelDate.toISOString().split('T')[0]
        : '',
      lastStatus: entry.lastStatus,
      lastCheckedAt: entry.lastCheckedAt
        ? entry.lastCheckedAt.toISOString()
        : '',
      createdAt: entry.createdAt.toISOString(),
    };
  }
}
