import {
  Entity,
  Column,
  PrimaryGeneratedColumn,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from './user.entity';
import { Train } from './train.entity';
import { Station } from './station.entity';

@Entity('journeys')
export class Journey {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ name: 'user_id', type: 'uuid' })
  userId: string;

  @Column({ name: 'train_number', type: 'varchar', length: 10 })
  trainNumber: string;

  @Column({ type: 'varchar', length: 15, nullable: true })
  pnr: string;

  @Column({ name: 'boarding_station', type: 'varchar', length: 10 })
  boardingStation: string;

  @Column({ name: 'destination_station', type: 'varchar', length: 10 })
  destinationStation: string;

  @Column({ name: 'travel_date', type: 'date' })
  travelDate: Date;

  @Column({ type: 'varchar', length: 10, nullable: true })
  coach: string;

  @Column({ type: 'varchar', length: 20, nullable: true })
  berth: string;

  @Column({ name: 'class', type: 'varchar', length: 10, nullable: true })
  travelClass: string;

  @Column({ type: 'varchar', length: 20, default: 'upcoming' })
  status: string;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt: Date;

  @ManyToOne(() => User, (user) => user.journeys)
  @JoinColumn({ name: 'user_id' })
  user: User;

  @ManyToOne(() => Train)
  @JoinColumn({ name: 'train_number' })
  train: Train;

  @ManyToOne(() => Station)
  @JoinColumn({ name: 'boarding_station' })
  boarding: Station;

  @ManyToOne(() => Station)
  @JoinColumn({ name: 'destination_station' })
  destinationStationEntity: Station;
}
