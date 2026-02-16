import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { MeiliSearch, Index } from 'meilisearch';
import { Station, Train } from '../common/entities';

export interface StationDocument {
  code: string;
  name: string;
  zone: string;
  state: string;
  searchText: string;
}

export interface TrainDocument {
  number: string;
  name: string;
  type: string;
  sourceStation: string;
  destinationStation: string;
  searchText: string;
}

@Injectable()
export class SearchService implements OnModuleInit {
  private readonly logger = new Logger(SearchService.name);
  private client: MeiliSearch;
  private stationsIndex: Index;
  private trainsIndex: Index;

  constructor(
    private readonly configService: ConfigService,
    @InjectRepository(Station)
    private readonly stationRepo: Repository<Station>,
    @InjectRepository(Train)
    private readonly trainRepo: Repository<Train>,
  ) {
    this.client = new MeiliSearch({
      host: this.configService.get<string>(
        'MEILISEARCH_HOST',
        'http://localhost:7700',
      ),
      apiKey: this.configService.get<string>(
        'MEILISEARCH_MASTER_KEY',
        'rail_meili_master_key_2024',
      ),
    });
  }

  async onModuleInit() {
    try {
      await this.setupIndexes();
      await this.syncData();
      this.logger.log('Meilisearch indexes initialized and synced');
    } catch (error) {
      this.logger.warn(
        'Failed to initialize Meilisearch, will retry on demand',
        error,
      );
    }
  }

  private async setupIndexes(): Promise<void> {
    await this.client.createIndex('stations', { primaryKey: 'code' });
    await this.client.createIndex('trains', { primaryKey: 'number' });

    this.stationsIndex = this.client.index('stations');
    this.trainsIndex = this.client.index('trains');

    await this.stationsIndex.updateSettings({
      searchableAttributes: ['name', 'code', 'zone', 'state', 'searchText'],
      filterableAttributes: ['zone', 'state'],
      sortableAttributes: ['name'],
      rankingRules: [
        'words',
        'typo',
        'proximity',
        'attribute',
        'sort',
        'exactness',
      ],
      typoTolerance: {
        enabled: true,
        minWordSizeForTypos: {
          oneTypo: 3,
          twoTypos: 6,
        },
      },
    });

    await this.trainsIndex.updateSettings({
      searchableAttributes: [
        'name',
        'number',
        'type',
        'sourceStation',
        'destinationStation',
        'searchText',
      ],
      filterableAttributes: ['type'],
      sortableAttributes: ['name', 'number'],
      rankingRules: [
        'words',
        'typo',
        'proximity',
        'attribute',
        'sort',
        'exactness',
      ],
      typoTolerance: {
        enabled: true,
        minWordSizeForTypos: {
          oneTypo: 3,
          twoTypos: 6,
        },
      },
    });
  }

  async syncData(): Promise<void> {
    await this.syncStations();
    await this.syncTrains();
  }

  private async syncStations(): Promise<void> {
    try {
      const stations = await this.stationRepo.find();
      const documents: StationDocument[] = stations.map((s) => ({
        code: s.code,
        name: s.name,
        zone: s.zone || '',
        state: s.state || '',
        searchText: `${s.code} ${s.name} ${s.zone || ''} ${s.state || ''}`,
      }));

      if (documents.length > 0) {
        await this.stationsIndex.addDocuments(documents);
        this.logger.log(`Synced ${documents.length} stations to Meilisearch`);
      }
    } catch (error) {
      this.logger.error('Failed to sync stations to Meilisearch', error);
    }
  }

  private async syncTrains(): Promise<void> {
    try {
      const trains = await this.trainRepo.find({
        relations: ['source', 'destination'],
      });
      const documents: TrainDocument[] = trains.map((t) => ({
        number: t.number,
        name: t.name,
        type: t.type || '',
        sourceStation: t.source?.name || t.sourceStation || '',
        destinationStation: t.destination?.name || t.destinationStation || '',
        searchText: `${t.number} ${t.name} ${t.type || ''} ${t.source?.name || ''} ${t.destination?.name || ''}`,
      }));

      if (documents.length > 0) {
        await this.trainsIndex.addDocuments(documents);
        this.logger.log(`Synced ${documents.length} trains to Meilisearch`);
      }
    } catch (error) {
      this.logger.error('Failed to sync trains to Meilisearch', error);
    }
  }

  async searchStations(
    query: string,
    limit: number = 10,
  ): Promise<StationDocument[]> {
    try {
      const result = await this.stationsIndex.search(query, {
        limit,
        attributesToRetrieve: ['code', 'name', 'zone', 'state'],
      });
      return result.hits as StationDocument[];
    } catch (error) {
      this.logger.error('Station search failed, falling back to DB', error);
      return this.fallbackStationSearch(query, limit);
    }
  }

  async searchTrains(
    query: string,
    limit: number = 10,
  ): Promise<TrainDocument[]> {
    try {
      const result = await this.trainsIndex.search(query, {
        limit,
        attributesToRetrieve: [
          'number',
          'name',
          'type',
          'sourceStation',
          'destinationStation',
        ],
      });
      return result.hits as TrainDocument[];
    } catch (error) {
      this.logger.error('Train search failed, falling back to DB', error);
      return this.fallbackTrainSearch(query, limit);
    }
  }

  private async fallbackStationSearch(
    query: string,
    limit: number,
  ): Promise<StationDocument[]> {
    const stations = await this.stationRepo
      .createQueryBuilder('s')
      .where('UPPER(s.code) LIKE UPPER(:q)', { q: `%${query}%` })
      .orWhere('UPPER(s.name) LIKE UPPER(:q)', { q: `%${query}%` })
      .take(limit)
      .getMany();

    return stations.map((s) => ({
      code: s.code,
      name: s.name,
      zone: s.zone || '',
      state: s.state || '',
      searchText: '',
    }));
  }

  private async fallbackTrainSearch(
    query: string,
    limit: number,
  ): Promise<TrainDocument[]> {
    const trains = await this.trainRepo
      .createQueryBuilder('t')
      .leftJoinAndSelect('t.source', 'source')
      .leftJoinAndSelect('t.destination', 'destination')
      .where('UPPER(t.number) LIKE UPPER(:q)', { q: `%${query}%` })
      .orWhere('UPPER(t.name) LIKE UPPER(:q)', { q: `%${query}%` })
      .take(limit)
      .getMany();

    return trains.map((t) => ({
      number: t.number,
      name: t.name,
      type: t.type || '',
      sourceStation: t.source?.name || '',
      destinationStation: t.destination?.name || '',
      searchText: '',
    }));
  }
}
