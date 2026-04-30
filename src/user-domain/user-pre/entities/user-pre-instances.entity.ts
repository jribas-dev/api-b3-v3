import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
  BeforeInsert,
  BeforeUpdate,
} from 'typeorm';
import { UserPreEntity } from './user-pre.entity';
import { InstanceEntity } from 'src/user-domain/instance/entities/instance.entity';
import {
  RoleBack,
  RoleFront,
  RoleFrontEnum,
} from 'src/user-domain/user-instance/enums/user-instance-roles.enum';
import { RoleFrontTransformer } from 'src/user-domain/user-instance/transformers/role-front.transformer';
import { assertRoleFrontConsistent } from 'src/user-domain/user-instance/validators/role-front.validator';

@Entity({ name: 'user_pre_instances' })
export class UserPreInstanceEntity {
  @PrimaryGeneratedColumn()
  id: number;

  @Column()
  userPreId: number;

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

  @BeforeInsert()
  @BeforeUpdate()
  validateRoleFront(): void {
    assertRoleFrontConsistent(this.rolefront);
  }
}
