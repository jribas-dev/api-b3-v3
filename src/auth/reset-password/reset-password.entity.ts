import {
  Column,
  CreateDateColumn,
  Entity,
  ManyToOne,
  PrimaryGeneratedColumn,
} from 'typeorm';
import { UserEntity } from 'src/user/entities/user.entity';

@Entity({ name: 'token_reset' })
export class ResetPasswordEntity {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ unique: true })
  token: string;

  @ManyToOne(() => UserEntity, { eager: true, onDelete: 'CASCADE' })
  user: UserEntity;

  @Column()
  expiresAt: Date;

  @CreateDateColumn({ select: false })
  createdAt: Date;
}
