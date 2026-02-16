import { Entity, Column, PrimaryColumn, OneToOne, JoinColumn } from 'typeorm';
import { User } from './user.entity';

@Entity('notification_preferences')
export class NotificationPreference {
  @PrimaryColumn({ name: 'user_id', type: 'uuid' })
  userId: string;

  @Column({ name: 'delay_alerts', type: 'boolean', default: true })
  delayAlerts: boolean;

  @Column({ name: 'platform_changes', type: 'boolean', default: true })
  platformChanges: boolean;

  @Column({ name: 'pnr_updates', type: 'boolean', default: true })
  pnrUpdates: boolean;

  @Column({ name: 'departure_reminder', type: 'boolean', default: true })
  departureReminder: boolean;

  @Column({ name: 'reminder_minutes_before', type: 'integer', default: 60 })
  reminderMinutesBefore: number;

  @OneToOne(() => User, (user) => user.notificationPreference)
  @JoinColumn({ name: 'user_id' })
  user: User;
}
