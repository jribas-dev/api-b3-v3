import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from 'src/user/user.entity';
import { Instance } from 'src/instance/instance.entity';

@Entity()
export class UserInstance {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  userId: string;

  @Column()
  dbId: string;

  @Column()
  role: string;

  @Column({ default: true })
  isActive: boolean;

  @ManyToOne(() => User, (user) => user.instances)
  @JoinColumn({ name: 'userId' })
  user: User;

  @ManyToOne(() => Instance, (instance) => instance.users)
  @JoinColumn({ name: 'dbId' })
  instance: Instance;
}
