import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { UserEntity } from 'src/user/entities/user.entity';
import { InstanceEntity } from 'src/instance/entities/instance.entity';
import { RoleBack, RoleFront } from '../enums/user-instance-roles.enum';

@Entity({ name: 'user_instances' })
export class UserInstanceEntity {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  userId: string;

  @Column()
  dbId: string;

  @Column({ type: 'int', nullable: true })
  idBackendUser: number | null;

  @Column({
    type: 'enum',
    enum: RoleBack,
    default: RoleBack.USER,
  })
  roleback: RoleBack;

  @Column({
    type: 'enum',
    enum: RoleFront,
    default: RoleFront.NOTALLOW,
  })
  rolefront: RoleFront;

  @Column({ default: true })
  isActive: boolean;

  @ManyToOne(() => UserEntity, (user) => user.instances, {
    eager: true,
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'userId' })
  user: UserEntity;

  @ManyToOne(() => InstanceEntity, (instance) => instance.users, {
    eager: true,
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'dbId' })
  instance: InstanceEntity;
}
