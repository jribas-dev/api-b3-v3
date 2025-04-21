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

@Entity({ name: 'user' })
export class UserEntity {
  @PrimaryColumn()
  userId: string;

  @BeforeInsert()
  generateId() {
    this.userId = createId();
  }

  @Column({ type: 'varchar', length: 128, unique: true })
  email: string;

  @Column({ type: 'varchar', length: 128, nullable: true })
  phone: string | null;

  @Column({ type: 'varchar', length: 300, select: false })
  password: string;

  @Column({ type: 'varchar', length: 128 })
  name: string;

  @Column({ default: false })
  isRoot: boolean;

  @Column({ default: true })
  isActive: boolean;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @OneToMany(() => UserInstanceEntity, (userInstance) => userInstance.user)
  instances: UserInstanceEntity[];
}
