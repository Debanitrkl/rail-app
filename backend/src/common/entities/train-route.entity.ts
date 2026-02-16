import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  ManyToOne,
  JoinColumn,
  Unique,
} from 'typeorm';
import { Train } from './train.entity';
import { Station } from './station.entity';

@Entity('train_routes')
@Unique(['trainNumber', 'stopNumber'])
export class TrainRoute {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ name: 'train_number', type: 'varchar', length: 10 })
  trainNumber: string;

  @Column({ name: 'station_code', type: 'varchar', length: 10 })
  stationCode: string;

  @Column({ name: 'stop_number', type: 'integer' })
  stopNumber: number;

  @Column({ name: 'arrival_time', type: 'time', nullable: true })
  arrivalTime: string;

  @Column({ name: 'departure_time', type: 'time', nullable: true })
  departureTime: string;

  @Column({ name: 'halt_minutes', type: 'integer', default: 0 })
  haltMinutes: number;

  @Column({ name: 'distance_from_source', type: 'integer', default: 0 })
  distanceFromSource: number;

  @Column({ name: 'day_number', type: 'integer', default: 1 })
  dayNumber: number;

  @Column({ type: 'varchar', length: 5, nullable: true })
  platform: string;

  @ManyToOne(() => Train, (train) => train.routes)
  @JoinColumn({ name: 'train_number' })
  train: Train;

  @ManyToOne(() => Station)
  @JoinColumn({ name: 'station_code' })
  station: Station;
}
