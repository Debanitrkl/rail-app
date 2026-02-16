import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { NotificationsController } from './notifications.controller';
import { NotificationsService } from './notifications.service';
import { UserDevice, NotificationPreference, User } from '../common/entities';

@Module({
  imports: [
    TypeOrmModule.forFeature([UserDevice, NotificationPreference, User]),
  ],
  controllers: [NotificationsController],
  providers: [NotificationsService],
  exports: [NotificationsService],
})
export class NotificationsModule {}
