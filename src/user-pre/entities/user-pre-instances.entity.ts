import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { UserPreEntity } from './user-pre.entity';
import { InstanceEntity } from 'src/instance/entities/instance.entity';
import {
  RoleBack,
  RoleFront,
} from 'src/user-instance/enums/user-instance-roles.enum';

@Entity({ name: 'user_pre_instances' })
export class UserPreInstanceEntity {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  userPreId: number;

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
    default: RoleFront.NOTALLOW,
  })
  rolefront: RoleFront;

  @ManyToOne(() => UserPreEntity, (userPre) => userPre.instances, {
    eager: true,
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'userPreId' })
  userPre: UserPreEntity;

  @ManyToOne(() => InstanceEntity, (instance) => instance.usersPre, {
    eager: true,
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'dbId' })
  instance: InstanceEntity;
}
