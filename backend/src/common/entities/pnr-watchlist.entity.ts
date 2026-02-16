import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
  Unique,
} from 'typeorm';
import { User } from './user.entity';

@Entity('pnr_watchlist')
@Unique(['userId', 'pnr'])
export class PnrWatchlist {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'user_id', type: 'uuid' })
  userId: string;

  @Column({ type: 'varchar', length: 15 })
  pnr: string;

  @Column({ name: 'train_number', type: 'varchar', length: 10, nullable: true })
  trainNumber: string;

  @Column({ name: 'travel_date', type: 'date', nullable: true })
  travelDate: Date;

  @Column({ name: 'last_status', type: 'jsonb', nullable: true })
  lastStatus: Record<string, any>;

  @Column({ name: 'last_checked_at', type: 'timestamptz', nullable: true })
  lastCheckedAt: Date;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt: Date;

  @ManyToOne(() => User, (user) => user.pnrWatchlist)
  @JoinColumn({ name: 'user_id' })
  user: User;
}
