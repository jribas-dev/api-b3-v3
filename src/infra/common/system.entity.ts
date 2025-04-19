import { Entity, PrimaryGeneratedColumn, Column, OneToMany } from 'typeorm';
import { SysFilesEntity } from '../sys-files/entities/sys-file.entity';
import { SqlFilesEntity } from '../sql-files/entities/sql-file.entity';

@Entity('systems')
export class SystemsEntity {
  @PrimaryGeneratedColumn()
  idSystem: number;

  @Column({ type: 'varchar', length: 60, nullable: false })
  systemName: string;

  @Column({
    type: 'varchar',
    length: 255,
    nullable: true,
    default: null,
  })
  description: string | null;

  @OneToMany(() => SysFilesEntity, (sysFiles) => sysFiles.idSystem)
  sysFiles: SysFilesEntity[];

  @OneToMany(() => SqlFilesEntity, (sqlFiles) => sqlFiles.idSystem)
  sqlFiles: SqlFilesEntity[];
}
