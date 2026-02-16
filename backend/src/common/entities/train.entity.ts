import {
  Entity,
  Column,
  PrimaryColumn,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  JoinColumn,
  OneToMany,
} from 'typeorm';
import { Station } from './station.entity';
import { TrainRoute } from './train-route.entity';
import { CoachComposition } from './coach-composition.entity';

@Entity('trains')
export class Train {
  @PrimaryColumn({ type: 'varchar', length: 10 })
  number: string;

  @Column({ type: 'varchar', length: 255 })
  name: string;

  @Column({ type: 'varchar', length: 50, nullable: true })
  type: string;

  @Column({ name: 'source_station', type: 'varchar', length: 10, nullable: true })
  sourceStation: string;

  @Column({ name: 'destination_station', type: 'varchar', length: 10, nullable: true })
  destinationStation: string;

  @Column({ name: 'runs_on', type: 'varchar', length: 7, default: '1111111' })
  runsOn: string;

  @Column({ name: 'avg_speed_kmph', type: 'integer', nullable: true })
  avgSpeedKmph: number;

  @Column({ name: 'distance_km', type: 'integer', nullable: true })
  distanceKm: number;

  @Column({ name: 'duration_minutes', type: 'integer', nullable: true })
  durationMinutes: number;

  @Column({ name: 'has_pantry', type: 'boolean', default: false })
  hasPantry: boolean;

  @Column({ name: 'has_charging', type: 'boolean', default: false })
  hasCharging: boolean;

  @Column({ name: 'has_bio_toilet', type: 'boolean', default: false })
  hasBioToilet: boolean;

  @Column({ name: 'has_cctv', type: 'boolean', default: false })
  hasCctv: boolean;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt: Date;

  @UpdateDateColumn({ name: 'updated_at', type: 'timestamptz' })
  updatedAt: Date;

  @ManyToOne(() => Station)
  @JoinColumn({ name: 'source_station' })
  source: Station;

  @ManyToOne(() => Station)
  @JoinColumn({ name: 'destination_station' })
  destination: Station;

  @OneToMany(() => TrainRoute, (route) => route.train)
  routes: TrainRoute[];

  @OneToMany(() => CoachComposition, (coach) => coach.train)
  coaches: CoachComposition[];
}
