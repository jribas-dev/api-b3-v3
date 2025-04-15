import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from 'src/user/entities/user.entity';
import { Instance } from 'src/instance/entities/instance.entity';
import { RoleBack, RoleFront } from '../enums/user-instance-roles.enum';

@Entity()
export class UserInstance {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  userId: string;

  @Column()
  dbId: string;

  @Column({
    type: 'enum',
    enum: RoleBack,
    default: RoleBack.USER,
  })
  roleback: RoleBack;

  @Column({
    type: 'enum',
    enum: RoleFront,
    default: RoleFront.BUYER,
  })
  rolefront: RoleFront;

  @Column({ default: true })
  isActive: boolean;

  @ManyToOne(() => User, (user) => user.instances)
  @JoinColumn({ name: 'userId' })
  user: User;

  @ManyToOne(() => Instance, (instance) => instance.users)
  @JoinColumn({ name: 'dbId' })
  instance: Instance;
}
