import { ApiProperty } from '@nestjs/swagger';

export class WidgetJourneyResponse {
  @ApiProperty()
  journeyId: string;

  @ApiProperty()
  trainNumber: string;

  @ApiProperty()
  trainName: string;

  @ApiProperty()
  from: string;

  @ApiProperty()
  to: string;

  @ApiProperty()
  departureTime: string;

  @ApiProperty()
  arrivalTime: string;

  @ApiProperty()
  status: string;

  @ApiProperty()
  delayMinutes: number;

  @ApiProperty()
  currentStation: string;

  @ApiProperty()
  platform: string;

  @ApiProperty()
  coach: string;

  @ApiProperty()
  berth: string;
}

export class WidgetPnrResponse {
  @ApiProperty()
  pnr: string;

  @ApiProperty()
  trainNumber: string;

  @ApiProperty()
  currentStatus: string;

  @ApiProperty()
  coach: string;

  @ApiProperty()
  berth: string;

  @ApiProperty()
  lastUpdated: string;
}
