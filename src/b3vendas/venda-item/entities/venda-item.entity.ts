import { Column, Entity, PrimaryColumn } from 'typeorm';
import { DecimalTransformer } from 'src/b3vendas/shared/decimal.transformer';

@Entity({ name: 'vendaitem' })
export class VendaItemEntity {
  @PrimaryColumn({ type: 'int', unsigned: true })
  idvenda: number;

  @PrimaryColumn({ type: 'smallint', unsigned: true })
  seq: number;

  @Column({ type: 'int' })
  idprod: number;

  @Column({
    type: 'decimal',
    precision: 10,
    scale: 3,
    default: 0,
    transformer: DecimalTransformer,
  })
  qtde: number;

  @Column({
    type: 'decimal',
    precision: 12,
    scale: 3,
    default: 0,
    transformer: DecimalTransformer,
  })
  custo: number;

  @Column({
    type: 'decimal',
    precision: 12,
    scale: 3,
    default: 0,
    transformer: DecimalTransformer,
  })
  unitario: number;

  @Column({
    type: 'decimal',
    precision: 10,
    scale: 2,
    default: 0,
    transformer: DecimalTransformer,
  })
  desconto: number;

  @Column({
    type: 'decimal',
    precision: 10,
    scale: 2,
    default: 0,
    transformer: DecimalTransformer,
  })
  acrescimo: number;

  @Column({
    type: 'decimal',
    precision: 12,
    scale: 2,
    default: 0,
    transformer: DecimalTransformer,
  })
  bruto: number;

  @Column({
    type: 'decimal',
    precision: 12,
    scale: 2,
    default: 0,
    transformer: DecimalTransformer,
  })
  total: number;

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

  @Column({ type: 'varchar', length: 5, default: '5102' })
  cfop: string;

  @Column({
    type: 'decimal',
    precision: 12,
    scale: 3,
    default: 0,
    transformer: DecimalTransformer,
  })
  vlrtab: number;

  @Column({ type: 'varchar', length: 60, nullable: true })
  obsprd: string | null;
}
