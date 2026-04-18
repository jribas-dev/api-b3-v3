import { Column, Entity, PrimaryColumn } from 'typeorm';
import { DecimalTransformer } from 'src/b3vendas/shared/decimal.transformer';

@Entity({ name: 'prdtabvalor' })
export class ProdutoTabValorEntity {
  @PrimaryColumn({ type: 'smallint', unsigned: true })
  idtab: number;

  @PrimaryColumn({ type: 'int' })
  idprod: number;

  @Column({
    type: 'decimal',
    precision: 12,
    scale: 3,
    default: 0,
    transformer: DecimalTransformer,
  })
  valor: number;
}
