import { Entity, PrimaryGeneratedColumn, Column, OneToMany } from 'typeorm';
import { SysFilesEntity } from '../sys-files/entities/sys-file.entity';

@Entity('systems')
export class SystemsEntity {
  @PrimaryGeneratedColumn({ name: 'idSytem' })
  idSystem: number;

  @Column({ name: 'systemName', type: 'varchar', length: 60, nullable: false })
  systemName: string;

  @Column({
    name: 'description',
    type: 'varchar',
    length: 255,
    nullable: true,
    default: null,
  })
  description: string | null;

  @OneToMany(() => SysFilesEntity, (sysFiles) => sysFiles.idSystem)
  sysFiles: SysFilesEntity[];
}
