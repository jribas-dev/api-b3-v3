import {
  Column,
  Entity,
  PrimaryGeneratedColumn,
  UpdateDateColumn,
} from 'typeorm';

@Entity('login_attempts')
export class LoginAttemptEntity {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ length: 255, unique: true })
  identifier: string;

  @Column({ default: 0 })
  attempts: number;

  @Column({ nullable: true, type: 'datetime' })
  blockedUntil: Date | null;

  @UpdateDateColumn()
  updatedAt: Date;
}
