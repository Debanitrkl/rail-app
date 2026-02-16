import { Injectable, Logger, NotFoundException } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { UserDevice, NotificationPreference, User } from '../common/entities';
import {
  RegisterDeviceDto,
  UpdateNotificationPreferencesDto,
  NotificationPreferencesResponse,
} from './dto/notification.dto';

@Injectable()
export class NotificationsService {
  private readonly logger = new Logger(NotificationsService.name);

  constructor(
    @InjectRepository(UserDevice)
    private readonly deviceRepo: Repository<UserDevice>,
    @InjectRepository(NotificationPreference)
    private readonly prefRepo: Repository<NotificationPreference>,
    @InjectRepository(User)
    private readonly userRepo: Repository<User>,
  ) {}

  async registerDevice(
    userId: string,
    dto: RegisterDeviceDto,
  ): Promise<{ success: boolean }> {
    // Ensure user exists
    let user = await this.userRepo.findOne({ where: { id: userId } });
    if (!user) {
      user = this.userRepo.create({
        id: userId,
        name: 'Development User',
        email: 'dev@rail.app',
      });
      await this.userRepo.save(user);
    }

    // Check if device already registered
    const existing = await this.deviceRepo.findOne({
      where: { userId, deviceToken: dto.deviceToken },
    });

    if (!existing) {
      const device = this.deviceRepo.create({
        userId,
        deviceToken: dto.deviceToken,
        platform: dto.platform || 'ios',
      });
      await this.deviceRepo.save(device);
    }

    return { success: true };
  }

  async getPreferences(
    userId: string,
  ): Promise<NotificationPreferencesResponse> {
    let prefs = await this.prefRepo.findOne({ where: { userId } });

    if (!prefs) {
      // Return defaults
      return {
        delayAlerts: true,
        platformChanges: true,
        pnrUpdates: true,
        departureReminder: true,
        reminderMinutesBefore: 60,
      };
    }

    return {
      delayAlerts: prefs.delayAlerts,
      platformChanges: prefs.platformChanges,
      pnrUpdates: prefs.pnrUpdates,
      departureReminder: prefs.departureReminder,
      reminderMinutesBefore: prefs.reminderMinutesBefore,
    };
  }

  async updatePreferences(
    userId: string,
    dto: UpdateNotificationPreferencesDto,
  ): Promise<NotificationPreferencesResponse> {
    // Ensure user exists
    let user = await this.userRepo.findOne({ where: { id: userId } });
    if (!user) {
      user = this.userRepo.create({
        id: userId,
        name: 'Development User',
        email: 'dev@rail.app',
      });
      await this.userRepo.save(user);
    }

    let prefs = await this.prefRepo.findOne({ where: { userId } });

    if (!prefs) {
      prefs = this.prefRepo.create({
        userId,
        delayAlerts: true,
        platformChanges: true,
        pnrUpdates: true,
        departureReminder: true,
        reminderMinutesBefore: 60,
      });
    }

    if (dto.delayAlerts !== undefined) prefs.delayAlerts = dto.delayAlerts;
    if (dto.platformChanges !== undefined)
      prefs.platformChanges = dto.platformChanges;
    if (dto.pnrUpdates !== undefined) prefs.pnrUpdates = dto.pnrUpdates;
    if (dto.departureReminder !== undefined)
      prefs.departureReminder = dto.departureReminder;
    if (dto.reminderMinutesBefore !== undefined)
      prefs.reminderMinutesBefore = dto.reminderMinutesBefore;

    const saved = await this.prefRepo.save(prefs);

    return {
      delayAlerts: saved.delayAlerts,
      platformChanges: saved.platformChanges,
      pnrUpdates: saved.pnrUpdates,
      departureReminder: saved.departureReminder,
      reminderMinutesBefore: saved.reminderMinutesBefore,
    };
  }
}
