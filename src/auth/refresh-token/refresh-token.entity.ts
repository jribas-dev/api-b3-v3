import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  CreateDateColumn,
} from 'typeorm';
import { UserInstanceEntity } from 'src/user-instance/entities/user-instance.entity';

@Entity({ name: 'token_refresh' })
export class RefreshToken {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ unique: true })
  token: string;

  @ManyToOne(() => UserInstanceEntity, { eager: true, onDelete: 'CASCADE' })
  userInstance: UserInstanceEntity;

  @Column({ default: false })
  isRevoked: boolean;

  @Column()
  expiresAt: Date;

  @CreateDateColumn()
  createdAt: Date;
}
