import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  ManyToOne,
  JoinColumn,
  Unique,
} from 'typeorm';
import { Train } from './train.entity';

@Entity('coach_compositions')
@Unique(['trainNumber', 'position'])
export class CoachComposition {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'train_number', type: 'varchar', length: 10 })
  trainNumber: string;

  @Column({ type: 'integer' })
  position: number;

  @Column({ name: 'coach_label', type: 'varchar', length: 10 })
  coachLabel: string;

  @Column({ name: 'coach_type', type: 'varchar', length: 20 })
  coachType: string;

  @Column({ name: 'total_berths', type: 'integer', default: 0 })
  totalBerths: number;

  @ManyToOne(() => Train, (train) => train.coaches)
  @JoinColumn({ name: 'train_number' })
  train: Train;
}
