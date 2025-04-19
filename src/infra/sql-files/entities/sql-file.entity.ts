import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { SqlFilesTipo } from '../enums/sql-files-tipo.enum';
import { SystemsEntity } from 'src/infra/common/system.entity';

@Entity('sql_files')
export class SqlFilesEntity {
  @PrimaryGeneratedColumn()
  idSql: number;

  @Column({ type: 'int', nullable: true, default: null })
  idSystem: number | null;

  @Column({ type: 'enum', enum: SqlFilesTipo, default: SqlFilesTipo.UPDATE })
  tipo: SqlFilesTipo;

  @Column({ type: 'decimal', precision: 9, scale: 3, default: 0.0 })
  versaoDb: number;

  @Column({ type: 'longblob', nullable: true, default: null, select: false })
  script: Buffer | null;

  @Column({ type: 'varchar', length: 255, nullable: true, default: null })
  obs: string | null;

  @Column({ type: 'timestamp', default: () => 'CURRENT_TIMESTAMP' })
  dthrSql: Date;

  @ManyToOne(() => SystemsEntity, (system) => system.sqlFiles, {
    onUpdate: 'CASCADE',
    onDelete: 'CASCADE',
  })
  @JoinColumn({ name: 'idSystem' })
  system: SystemsEntity;
}
