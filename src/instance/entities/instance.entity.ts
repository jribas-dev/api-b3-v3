import {
  Entity,
  Column,
  PrimaryColumn,
  CreateDateColumn,
  OneToMany,
  BeforeInsert,
  UpdateDateColumn,
} from 'typeorm';
import { UserInstanceEntity } from 'src/user-instance/entities/user-instance.entity';
import { createId } from '@paralleldrive/cuid2';

@Entity({ name: 'instance' })
export class InstanceEntity {
  @PrimaryColumn()
  dbId: string;

  @BeforeInsert()
  generateId() {
    this.dbId = createId();
  }

  @Column()
  name: string;

  @Column()
  dbName: string;

  @Column()
  dbHost: string;

  @Column({ default: 1 })
  maxCompanies: number;

  @Column({ default: 2 })
  maxUsers: number;

  @Column({ default: true })
  isActive: boolean;

  @CreateDateColumn({ select: false })
  createdAt: Date;

  @UpdateDateColumn({ select: false })
  updatedAt: Date;

  @OneToMany(() => UserInstanceEntity, (userInstance) => userInstance.instance)
  users: UserInstanceEntity[];
}
