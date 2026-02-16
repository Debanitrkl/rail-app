import { Entity, Column, PrimaryColumn, CreateDateColumn } from 'typeorm';

@Entity('stations')
export class Station {
  @PrimaryColumn({ type: 'varchar', length: 10 })
  code: string;

  @Column({ type: 'varchar', length: 255 })
  name: string;

  @Column({ type: 'varchar', length: 50, nullable: true })
  zone: string;

  @Column({ type: 'varchar', length: 100, nullable: true })
  division: string;

  @Column({ type: 'varchar', length: 100, nullable: true })
  state: string;

  @Column({ type: 'decimal', precision: 10, scale: 7, nullable: true })
  latitude: number;

  @Column({ type: 'decimal', precision: 10, scale: 7, nullable: true })
  longitude: number;

  @Column({ name: 'platforms_count', type: 'integer', default: 0 })
  platformsCount: number;

  @Column({ name: 'has_wifi', type: 'boolean', default: false })
  hasWifi: boolean;

  @Column({ name: 'has_parking', type: 'boolean', default: false })
  hasParking: boolean;

  @CreateDateColumn({ name: 'created_at', type: 'timestamptz' })
  createdAt: Date;
}
