import { Injectable, Logger, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Journey, Train, Station, User } from '../common/entities';
import { CacheService } from '../cache/cache.service';
import { CreateJourneyDto, JourneyResponse } from './dto/journey.dto';

@Injectable()
export class JourneysService {
  private readonly logger = new Logger(JourneysService.name);

  constructor(
    @InjectRepository(Journey)
    private readonly journeyRepo: Repository<Journey>,
    @InjectRepository(Train)
    private readonly trainRepo: Repository<Train>,
    @InjectRepository(Station)
    private readonly stationRepo: Repository<Station>,
    @InjectRepository(User)
    private readonly userRepo: Repository<User>,
    private readonly cacheService: CacheService,
  ) {}

  async getUserJourneys(userId: string): Promise<JourneyResponse[]> {
    const journeys = await this.journeyRepo.find({
      where: { userId },
      relations: ['train', 'boarding', 'destinationStationEntity'],
      order: { travelDate: 'DESC' },
    });

    return journeys.map((j) => this.toResponse(j));
  }

  async getJourneyDetail(
    journeyId: string,
    userId: string,
  ): Promise<JourneyResponse> {
    const journey = await this.journeyRepo.findOne({
      where: { id: journeyId, userId },
      relations: ['train', 'boarding', 'destinationStationEntity'],
    });

    if (!journey) {
      throw new NotFoundException(`Journey ${journeyId} not found`);
    }

    return this.toResponse(journey);
  }

  async createJourney(
    userId: string,
    dto: CreateJourneyDto,
  ): Promise<JourneyResponse> {
    // Ensure user exists, create if not (for development)
    let user = await this.userRepo.findOne({ where: { id: userId } });
    if (!user) {
      user = this.userRepo.create({
        id: userId,
        name: 'Development User',
        email: 'dev@rail.app',
      });
      await this.userRepo.save(user);
    }

    const train = await this.trainRepo.findOne({
      where: { number: dto.trainNumber },
    });
    if (!train) {
      throw new NotFoundException(`Train ${dto.trainNumber} not found`);
    }

    const boardingStation = await this.stationRepo.findOne({
      where: { code: dto.boardingStation },
    });
    if (!boardingStation) {
      throw new NotFoundException(
        `Station ${dto.boardingStation} not found`,
      );
    }

    const destStation = await this.stationRepo.findOne({
      where: { code: dto.destinationStation },
    });
    if (!destStation) {
      throw new NotFoundException(
        `Station ${dto.destinationStation} not found`,
      );
    }

    const travelDate = new Date(dto.travelDate);
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const status = travelDate < today ? 'completed' : 'upcoming';

    const journey = new Journey();
    journey.userId = userId;
    journey.trainNumber = dto.trainNumber;
    journey.pnr = dto.pnr || null;
    journey.boardingStation = dto.boardingStation;
    journey.destinationStation = dto.destinationStation;
    journey.travelDate = travelDate;
    journey.coach = dto.coach || null;
    journey.berth = dto.berth || null;
    journey.travelClass = dto.travelClass || null;
    journey.status = status;

    const saved = await this.journeyRepo.save(journey);

    // Reload with relations
    const full = await this.journeyRepo.findOne({
      where: { id: saved.id },
      relations: ['train', 'boarding', 'destinationStationEntity'],
    });

    await this.cacheService.del(`user:journeys:${userId}`);
    return this.toResponse(full!);
  }

  async deleteJourney(journeyId: string, userId: string): Promise<void> {
    const journey = await this.journeyRepo.findOne({
      where: { id: journeyId, userId },
    });

    if (!journey) {
      throw new NotFoundException(`Journey ${journeyId} not found`);
    }

    await this.journeyRepo.remove(journey);
    await this.cacheService.del(`user:journeys:${userId}`);
  }

  private toResponse(journey: Journey): JourneyResponse {
    return {
      id: journey.id,
      trainNumber: journey.trainNumber,
      trainName: journey.train?.name || '',
      trainType: journey.train?.type || '',
      pnr: journey.pnr || '',
      boarding: {
        code: journey.boarding?.code || journey.boardingStation,
        name: journey.boarding?.name || '',
      },
      destination: {
        code:
          journey.destinationStationEntity?.code ||
          journey.destinationStation,
        name: journey.destinationStationEntity?.name || '',
      },
      travelDate: journey.travelDate
        ? new Date(journey.travelDate).toISOString().split('T')[0]
        : '',
      coach: journey.coach || '',
      berth: journey.berth || '',
      travelClass: journey.travelClass || '',
      status: journey.status,
      createdAt: journey.createdAt.toISOString(),
    };
  }
}
