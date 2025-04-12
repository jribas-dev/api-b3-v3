import {
  Entity,
  Column,
  PrimaryColumn,
  CreateDateColumn,
  OneToMany,
  BeforeInsert,
} from 'typeorm';
import { UserInstance } from 'src/user-instance/user-instance.entity';
import { createId } from '@paralleldrive/cuid2';

@Entity()
export class Instance {
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

  @CreateDateColumn()
  createdAt: Date;

  @Column({ default: true })
  isActive: boolean;

  @OneToMany(() => UserInstance, (userInstance) => userInstance.instance)
  users: UserInstance[];
}
