import { IsString, IsOptional, IsBoolean, IsInt, Min, Max } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class RegisterDeviceDto {
  @ApiProperty({ description: 'APNs device token' })
  @IsString()
  deviceToken: string;

  @ApiPropertyOptional({ description: 'Platform (ios/android)', default: 'ios' })
  @IsOptional()
  @IsString()
  platform?: string;
}

export class UpdateNotificationPreferencesDto {
  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  delayAlerts?: boolean;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  platformChanges?: boolean;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  pnrUpdates?: boolean;

  @ApiPropertyOptional()
  @IsOptional()
  @IsBoolean()
  departureReminder?: boolean;

  @ApiPropertyOptional({ minimum: 15, maximum: 180 })
  @IsOptional()
  @IsInt()
  @Min(15)
  @Max(180)
  reminderMinutesBefore?: number;
}

export class NotificationPreferencesResponse {
  @ApiProperty()
  delayAlerts: boolean;

  @ApiProperty()
  platformChanges: boolean;

  @ApiProperty()
  pnrUpdates: boolean;

  @ApiProperty()
  departureReminder: boolean;

  @ApiProperty()
  reminderMinutesBefore: number;
}
