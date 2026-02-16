import {
  Controller,
  Get,
  Post,
  Put,
  Body,
  Headers,
  Logger,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiHeader } from '@nestjs/swagger';
import { NotificationsService } from './notifications.service';
import { ApiResponseDto } from '../common/dto/api-response.dto';
import {
  RegisterDeviceDto,
  UpdateNotificationPreferencesDto,
} from './dto/notification.dto';

@ApiTags('Notifications')
@Controller('api/v1/notifications')
export class NotificationsController {
  private readonly logger = new Logger(NotificationsController.name);
  private readonly defaultUserId = '00000000-0000-0000-0000-000000000001';

  private getUserId(authHeader?: string): string {
    return this.defaultUserId;
  }

  constructor(
    private readonly notificationsService: NotificationsService,
  ) {}

  @Post('register-device')
  @ApiOperation({ summary: 'Register APNs device token' })
  @ApiHeader({ name: 'Authorization', required: false })
  async registerDevice(
    @Body() dto: RegisterDeviceDto,
    @Headers('authorization') auth?: string,
  ) {
    const userId = this.getUserId(auth);
    const result = await this.notificationsService.registerDevice(
      userId,
      dto,
    );
    return new ApiResponseDto(result, 'Device registered');
  }

  @Get('preferences')
  @ApiOperation({ summary: 'Get notification preferences' })
  @ApiHeader({ name: 'Authorization', required: false })
  async getPreferences(@Headers('authorization') auth?: string) {
    const userId = this.getUserId(auth);
    const prefs =
      await this.notificationsService.getPreferences(userId);
    return new ApiResponseDto(prefs);
  }

  @Put('preferences')
  @ApiOperation({ summary: 'Update notification preferences' })
  @ApiHeader({ name: 'Authorization', required: false })
  async updatePreferences(
    @Body() dto: UpdateNotificationPreferencesDto,
    @Headers('authorization') auth?: string,
  ) {
    const userId = this.getUserId(auth);
    const prefs = await this.notificationsService.updatePreferences(
      userId,
      dto,
    );
    return new ApiResponseDto(prefs, 'Preferences updated');
  }
}
