import {
  Entity,
  Column,
  CreateDateColumn,
  PrimaryGeneratedColumn,
  OneToMany,
} from 'typeorm';
import { UserPreInstanceEntity } from './user-pre-instances.entity';

@Entity({ name: 'user_pre' })
export class UserPreEntity {
  @PrimaryGeneratedColumn()
  userPreId: number;

  @Column({ type: 'varchar', length: 128, unique: true })
  email: string;

  @Column({ unique: true })
  token: string;

  @Column()
  expiresAt: Date;

  @Column({ type: 'varchar', length: 36, nullable: true })
  userInviteId: string;

  @CreateDateColumn({ select: false })
  createdAt: Date;

  @OneToMany(
    () => UserPreInstanceEntity,
    (userPreInstance) => userPreInstance.userPre,
  )
  instances: UserPreInstanceEntity[];
}
