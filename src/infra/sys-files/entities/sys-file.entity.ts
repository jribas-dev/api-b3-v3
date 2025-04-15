import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { SystemsEntity } from '../../common/system.entity';
import { SysFilesTipo } from '../enums/sys-files-tipo.enum';

@Entity('sys_files')
export class SysFilesEntity {
  @PrimaryGeneratedColumn({ name: 'idFile', type: 'int' })
  idFile: number;

  @Column({ name: 'idSystem', type: 'int' })
  idSystem: number;

  @Column({
    name: 'tipo',
    type: 'enum',
    enum: SysFilesTipo,
    default: SysFilesTipo.UPDATE,
  })
  tipo: 'U' | 'F';

  @Column({
    name: 'dthrfile',
    type: 'datetime',
    default: () => 'CURRENT_TIMESTAMP',
  })
  dthrFile: Date;

  @Column({
    name: 'versao',
    type: 'decimal',
    precision: 9,
    scale: 3,
    default: 0.0,
  })
  versao: number;

  @Column({
    name: 'versaodb',
    type: 'decimal',
    precision: 9,
    scale: 3,
    default: 0.0,
  })
  versaoDb: number;

  @Column({ name: 'filename', type: 'varchar', length: 256 })
  fileName: string;

  @Column({ name: 'url', type: 'varchar', length: 400 })
  url: string;

  @Column({ name: 's3key', type: 'varchar', length: 100, nullable: true })
  s3Key: string | null;

  @ManyToOne(() => SystemsEntity, (system) => system.sysFiles, {
    onUpdate: 'CASCADE',
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'idSystem' })
  system: SystemsEntity;
}
