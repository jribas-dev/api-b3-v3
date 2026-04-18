import { Column, Entity, PrimaryGeneratedColumn } from 'typeorm';

@Entity({ name: 'formapg' })
export class FormaPagamentoEntity {
  @PrimaryGeneratedColumn({ type: 'smallint', unsigned: true })
  id: number;

  @Column({ type: 'varchar', length: 60 })
  nmforma: string;

  @Column({ type: 'varchar', length: 1 })
  operacao: string;

  @Column({ type: 'bit', width: 1, default: () => "b'0'" })
  inativo: boolean;
}
