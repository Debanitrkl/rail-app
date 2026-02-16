import { IsString } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class SearchStationsDto {
  @ApiProperty({ description: 'Search query for station name or code' })
  @IsString()
  q: string;
}

export class StationInfoResponse {
  @ApiProperty()
  code: string;

  @ApiProperty()
  name: string;

  @ApiProperty()
  zone: string;

  @ApiProperty()
  division: string;

  @ApiProperty()
  state: string;

  @ApiProperty()
  latitude: number;

  @ApiProperty()
  longitude: number;

  @ApiProperty()
  platformsCount: number;

  @ApiProperty()
  amenities: {
    wifi: boolean;
    parking: boolean;
  };

  @ApiProperty()
  trains: StationTrainResponse[];
}

export class StationTrainResponse {
  @ApiProperty()
  trainNumber: string;

  @ApiProperty()
  trainName: string;

  @ApiProperty()
  arrivalTime: string | null;

  @ApiProperty()
  departureTime: string | null;

  @ApiProperty()
  platform: string | null;

  @ApiProperty()
  stopNumber: number;
}

export class PlatformStatusResponse {
  @ApiProperty()
  platformNumber: number;

  @ApiProperty()
  currentTrain: string | null;

  @ApiProperty()
  nextTrain: string | null;

  @ApiProperty()
  status: 'occupied' | 'available' | 'reserved';
}

export class LiveStationEvent {
  @ApiProperty()
  type: 'arrival' | 'departure' | 'delay' | 'platform_change';

  @ApiProperty()
  trainNumber: string;

  @ApiProperty()
  trainName: string;

  @ApiProperty()
  platform: string;

  @ApiProperty()
  scheduledTime: string;

  @ApiProperty()
  actualTime: string;

  @ApiProperty()
  delayMinutes: number;

  @ApiProperty()
  timestamp: string;
}
