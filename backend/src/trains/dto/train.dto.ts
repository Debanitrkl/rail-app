import { IsString, IsOptional, IsDateString } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class SearchTrainsDto {
  @ApiProperty({ description: 'Search query for train name or number' })
  @IsString()
  q: string;
}

export class TrainsBetweenDto {
  @ApiProperty({ description: 'Origin station code', example: 'NDLS' })
  @IsString()
  from: string;

  @ApiProperty({ description: 'Destination station code', example: 'BCT' })
  @IsString()
  to: string;

  @ApiPropertyOptional({ description: 'Travel date in YYYY-MM-DD format' })
  @IsOptional()
  @IsDateString()
  date?: string;
}

export class TrainInfoResponse {
  @ApiProperty()
  number: string;

  @ApiProperty()
  name: string;

  @ApiProperty()
  type: string;

  @ApiProperty()
  source: {
    code: string;
    name: string;
  };

  @ApiProperty()
  destination: {
    code: string;
    name: string;
  };

  @ApiProperty()
  runsOn: string;

  @ApiProperty()
  avgSpeedKmph: number;

  @ApiProperty()
  distanceKm: number;

  @ApiProperty()
  durationMinutes: number;

  @ApiProperty()
  amenities: {
    pantry: boolean;
    charging: boolean;
    bioToilet: boolean;
    cctv: boolean;
  };

  @ApiProperty()
  schedule: RouteStopResponse[];
}

export class RouteStopResponse {
  @ApiProperty()
  stopNumber: number;

  @ApiProperty()
  station: {
    code: string;
    name: string;
  };

  @ApiProperty()
  arrivalTime: string | null;

  @ApiProperty()
  departureTime: string | null;

  @ApiProperty()
  haltMinutes: number;

  @ApiProperty()
  distanceFromSource: number;

  @ApiProperty()
  dayNumber: number;

  @ApiProperty()
  platform: string | null;
}

export class CoachCompositionResponse {
  @ApiProperty()
  position: number;

  @ApiProperty()
  coachLabel: string;

  @ApiProperty()
  coachType: string;

  @ApiProperty()
  totalBerths: number;
}

export class LiveTrainPositionResponse {
  @ApiProperty()
  trainNumber: string;

  @ApiProperty()
  latitude: number;

  @ApiProperty()
  longitude: number;

  @ApiProperty()
  speedKmph: number;

  @ApiProperty()
  delayMinutes: number;

  @ApiProperty()
  currentStation: string;

  @ApiProperty()
  nextStation: string;

  @ApiProperty()
  etaNext: string;

  @ApiProperty()
  timestamp: string;
}
