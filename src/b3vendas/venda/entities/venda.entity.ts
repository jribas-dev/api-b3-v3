import {
  Column,
  CreateDateColumn,
  Entity,
  PrimaryGeneratedColumn,
} from 'typeorm';
import { DecimalTransformer } from 'src/b3vendas/shared/decimal.transformer';

@Entity({ name: 'venda' })
export class VendaEntity {
  @PrimaryGeneratedColumn({ type: 'int', unsigned: true })
  id: number;

  @CreateDateColumn({ type: 'timestamp' })
  dthremissao: Date;

  @Column({ type: 'smallint', unsigned: true })
  idoper: number;

  @Column({ type: 'varchar', length: 1, default: 'F' })
  fiscal: string;

  @Column({ type: 'varchar', length: 1, default: 'V' })
  tipo: string;

  @Column({ type: 'enum', enum: ['N', 'T', 'B', 'G'], default: 'N' })
  subtipo: 'N' | 'T' | 'B' | 'G';

  @Column({
    type: 'decimal',
    precision: 16,
    scale: 3,
    default: 0,
    transformer: DecimalTransformer,
  })
  vlrbruto: number;

  @Column({
    type: 'decimal',
    precision: 12,
    scale: 3,
    default: 0,
    transformer: DecimalTransformer,
  })
  acrescimo: number;

  @Column({
    type: 'decimal',
    precision: 12,
    scale: 3,
    default: 0,
    transformer: DecimalTransformer,
  })
  desconto: number;

  @Column({
    type: 'decimal',
    precision: 12,
    scale: 3,
    default: 0,
    transformer: DecimalTransformer,
  })
  frete: number;

  @Column({
    type: 'decimal',
    precision: 12,
    scale: 3,
    default: 0,
    transformer: DecimalTransformer,
  })
  seguro: number;

  @Column({
    type: 'decimal',
    precision: 12,
    scale: 3,
    default: 0,
    transformer: DecimalTransformer,
  })
  outros: number;

  @Column({
    type: 'decimal',
    precision: 12,
    scale: 3,
    default: 0,
    transformer: DecimalTransformer,
  })
  deducoes: number;

  @Column({
    type: 'decimal',
    precision: 12,
    scale: 3,
    default: 0,
    transformer: DecimalTransformer,
  })
  st: number;

  @Column({
    type: 'decimal',
    precision: 12,
    scale: 3,
    default: 0,
    transformer: DecimalTransformer,
  })
  ipi: number;

  @Column({
    type: 'decimal',
    precision: 16,
    scale: 3,
    default: 0,
    transformer: DecimalTransformer,
  })
  vlrtotal: number;

  @Column({ type: 'int', unsigned: true, nullable: true })
  idcli: number | null;

  @Column({ type: 'int', unsigned: true, nullable: true })
  idvend: number | null;

  @Column({ type: 'int', unsigned: true, nullable: true })
  idemp: number | null;

  @Column({ type: 'varchar', length: 20, nullable: true })
  plataforma: string | null;

  @Column({ type: 'varchar', length: 20, nullable: true })
  processo: string | null;

  @Column({ type: 'int', unsigned: true, nullable: true })
  ultimousu: number | null;

  @Column({ type: 'varchar', length: 255, nullable: true })
  obsinter: string | null;
}
