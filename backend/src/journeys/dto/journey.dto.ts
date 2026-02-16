import {
  IsString,
  IsOptional,
  IsDateString,
  IsUUID,
} from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class CreateJourneyDto {
  @ApiProperty({ description: 'Train number', example: '12301' })
  @IsString()
  trainNumber: string;

  @ApiPropertyOptional({ description: 'PNR number' })
  @IsOptional()
  @IsString()
  pnr?: string;

  @ApiProperty({ description: 'Boarding station code', example: 'NDLS' })
  @IsString()
  boardingStation: string;

  @ApiProperty({ description: 'Destination station code', example: 'HWH' })
  @IsString()
  destinationStation: string;

  @ApiProperty({
    description: 'Travel date',
    example: '2026-03-15',
  })
  @IsDateString()
  travelDate: string;

  @ApiPropertyOptional({ description: 'Coach', example: 'A1' })
  @IsOptional()
  @IsString()
  coach?: string;

  @ApiPropertyOptional({ description: 'Berth', example: '23-LB' })
  @IsOptional()
  @IsString()
  berth?: string;

  @ApiPropertyOptional({ description: 'Travel class', example: '2AC' })
  @IsOptional()
  @IsString()
  travelClass?: string;
}

export class JourneyResponse {
  @ApiProperty()
  id: string;

  @ApiProperty()
  trainNumber: string;

  @ApiProperty()
  trainName: string;

  @ApiProperty()
  trainType: string;

  @ApiProperty()
  pnr: string;

  @ApiProperty()
  boarding: {
    code: string;
    name: string;
  };

  @ApiProperty()
  destination: {
    code: string;
    name: string;
  };

  @ApiProperty()
  travelDate: string;

  @ApiProperty()
  coach: string;

  @ApiProperty()
  berth: string;

  @ApiProperty()
  travelClass: string;

  @ApiProperty()
  status: string;

  @ApiProperty()
  createdAt: string;
}
