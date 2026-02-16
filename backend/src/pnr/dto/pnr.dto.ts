import { IsString, IsOptional, IsDateString, Length } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class WatchPnrDto {
  @ApiProperty({ description: 'PNR number', example: '4567891234' })
  @IsString()
  @Length(10, 15)
  pnr: string;

  @ApiPropertyOptional({ description: 'Train number' })
  @IsOptional()
  @IsString()
  trainNumber?: string;

  @ApiPropertyOptional({ description: 'Travel date' })
  @IsOptional()
  @IsDateString()
  travelDate?: string;
}

export class PnrStatusResponse {
  @ApiProperty()
  pnr: string;

  @ApiProperty()
  trainNumber: string;

  @ApiProperty()
  trainName: string;

  @ApiProperty()
  from: string;

  @ApiProperty()
  to: string;

  @ApiProperty()
  travelDate: string;

  @ApiProperty()
  bookingStatus: string;

  @ApiProperty()
  currentStatus: string;

  @ApiProperty()
  passengers: PnrPassengerStatus[];

  @ApiProperty()
  lastUpdated: string;
}

export class PnrPassengerStatus {
  @ApiProperty()
  number: number;

  @ApiProperty()
  bookingStatus: string;

  @ApiProperty()
  currentStatus: string;

  @ApiProperty()
  coach: string;

  @ApiProperty()
  berth: string;
}

export class WatchedPnrResponse {
  @ApiProperty()
  id: number;

  @ApiProperty()
  pnr: string;

  @ApiProperty()
  trainNumber: string;

  @ApiProperty()
  travelDate: string;

  @ApiProperty()
  lastStatus: Record<string, any> | null;

  @ApiProperty()
  lastCheckedAt: string;

  @ApiProperty()
  createdAt: string;
}
