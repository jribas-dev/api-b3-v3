import { Column, Entity, PrimaryGeneratedColumn } from 'typeorm';

@Entity({ name: 'condpg' })
export class CondicaoPagamentoEntity {
  @PrimaryGeneratedColumn({ type: 'smallint', unsigned: true, name: 'idcond' })
  idcond: number;

  @Column({ type: 'varchar', length: 80 })
  nomecond: string;

  @Column({ type: 'smallint' })
  parcelas: number;

  @Column({ type: 'bit', width: 1, default: () => "b'0'" })
  inativo: boolean;
}
