import {
  Entity,
  Column,
  PrimaryColumn,
  CreateDateColumn,
  OneToMany,
  BeforeInsert,
} from 'typeorm';
import { UserInstance } from 'src/user-instance/entities/user-instance.entity';
import { createId } from '@paralleldrive/cuid2';

@Entity()
export class User {
  @PrimaryColumn()
  userId: string;

  @BeforeInsert()
  generateId() {
    this.userId = createId();
  }

  @Column({ unique: true })
  email: string;

  @Column({ unique: true })
  phone: string;

  @Column()
  password: string;

  @Column()
  name: string;

  @Column({ default: false })
  isRoot: boolean;

  @Column({ default: true })
  isActive: boolean;

  @CreateDateColumn()
  createdAt: Date;

  @OneToMany(() => UserInstance, (userInstance) => userInstance.user)
  instances: UserInstance[];
}
