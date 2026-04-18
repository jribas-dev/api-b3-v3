import { Column, Entity, PrimaryGeneratedColumn } from 'typeorm';
import { DecimalTransformer } from 'src/b3vendas/shared/decimal.transformer';

@Entity({ name: 'impostos' })
export class ImpostoEntity {
  @PrimaryGeneratedColumn({ type: 'int' })
  id: number;

  @Column({ type: 'varchar', length: 60 })
  descricao: string;

  @Column({ type: 'varchar', length: 3, default: '41' })
  icmscst: string;

  @Column({
    type: 'decimal',
    precision: 8,
    scale: 4,
    default: 0,
    transformer: DecimalTransformer,
  })
  icmsaliq: number;

  @Column({
    type: 'decimal',
    precision: 8,
    scale: 4,
    default: 0,
    transformer: DecimalTransformer,
  })
  icmsredu: number;

  @Column({
    type: 'decimal',
    precision: 8,
    scale: 4,
    default: 0,
    transformer: DecimalTransformer,
  })
  icmsiva: number;

  @Column({ type: 'varchar', length: 3, default: '53' })
  ipicst: string;

  @Column({
    type: 'decimal',
    precision: 8,
    scale: 4,
    default: 0,
    transformer: DecimalTransformer,
  })
  ipialiq: number;
}
