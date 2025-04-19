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
  @PrimaryGeneratedColumn({ type: 'int' })
  idFile: number;

  @Column({ type: 'int', nullable: true, default: null })
  idSystem: number | null;

  @Column({ type: 'enum', enum: SysFilesTipo, default: SysFilesTipo.UPDATE })
  tipo: SysFilesTipo;

  @Column({ type: 'datetime', default: () => 'CURRENT_TIMESTAMP' })
  dthrFile: Date;

  @Column({ type: 'decimal', precision: 9, scale: 3, default: 0.0 })
  versao: number;

  @Column({ type: 'decimal', precision: 9, scale: 3, default: 0.0 })
  versaoDb: number;

  @Column({ type: 'varchar', length: 256 })
  fileName: string;

  @Column({ name: 'url', type: 'varchar', length: 400, nullable: true })
  url: string | null;

  @Column({ type: 'varchar', length: 100, nullable: true })
  s3Key: string | null;

  @ManyToOne(() => SystemsEntity, (system) => system.sysFiles, {
    onUpdate: 'CASCADE',
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'idSystem' })
  system: SystemsEntity;
}
