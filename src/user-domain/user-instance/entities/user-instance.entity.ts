import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  BeforeInsert,
  BeforeUpdate,
} from 'typeorm';
import { UserEntity } from 'src/user-domain/user/entities/user.entity';
import { InstanceEntity } from 'src/user-domain/instance/entities/instance.entity';
import {
  RoleBack,
  RoleFront,
  RoleFrontEnum,
} from '../enums/user-instance-roles.enum';
import { RoleFrontTransformer } from '../transformers/role-front.transformer';
import { assertRoleFrontConsistent } from '../validators/role-front.validator';

@Entity({ name: 'user_instances' })
export class UserInstanceEntity {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  userId: string;

  @Column()
  dbId: string;

  @Column({ type: 'int', nullable: true, default: null })
  idBackendUser: number | null;

  @Column({
    type: 'enum',
    enum: RoleBack,
    default: RoleBack.USER,
  })
  roleback: RoleBack;

  @Column({
    type: 'varchar',
    length: 255,
    default: RoleFrontEnum.NOTALLOW,
    transformer: RoleFrontTransformer,
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

  @BeforeInsert()
  @BeforeUpdate()
  validateRoleFront(): void {
    assertRoleFrontConsistent(this.rolefront);
  }
}
