import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  OneToMany,
  OneToOne,
} from 'typeorm';
import { Journey } from './journey.entity';
import { PnrWatchlist } from './pnr-watchlist.entity';
import { UserDevice } from './user-device.entity';
import { NotificationPreference } from './notification-preference.entity';

@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'apple_id', type: 'varchar', length: 255, unique: true, nullable: true })
  appleId: string;

  @Column({ type: 'varchar', length: 255, nullable: true })
  name: string;

  @Column({ type: 'varchar', length: 255, nullable: true })
  email: string;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt: Date;

  @OneToMany(() => Journey, (journey) => journey.user)
  journeys: Journey[];

  @OneToMany(() => PnrWatchlist, (pnr) => pnr.user)
  pnrWatchlist: PnrWatchlist[];

  @OneToMany(() => UserDevice, (device) => device.user)
  devices: UserDevice[];

  @OneToOne(() => NotificationPreference, (pref) => pref.user)
  notificationPreference: NotificationPreference;
}
