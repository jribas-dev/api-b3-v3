import { Column, Entity, PrimaryColumn } from 'typeorm';
import { DecimalTransformer } from 'src/b3vendas/shared/decimal.transformer';

@Entity({ name: 'vendacaixa' })
export class VendaCaixaEntity {
  @PrimaryColumn({ type: 'int', unsigned: true })
  idvenda: number;

  @PrimaryColumn({ type: 'smallint', unsigned: true })
  idforma: number;

  @PrimaryColumn({ type: 'tinyint', unsigned: true })
  seq: number;

  @Column({ type: 'int', unsigned: true, nullable: true })
  idcaixa: number | null;

  @Column({
    type: 'decimal',
    precision: 12,
    scale: 2,
    transformer: DecimalTransformer,
  })
  valor: number;

  @Column({ type: 'smallint', unsigned: true, nullable: true })
  idcond: number | null;

  @Column({ type: 'varchar', length: 1, default: 'I' })
  operacao: string;

  @Column({ type: 'bit', width: 1, default: () => "b'1'" })
  baixado: boolean;
}
