import { Column, Entity, PrimaryGeneratedColumn } from 'typeorm';

@Entity({ name: 'operacoes' })
export class OperacaoEntity {
  @PrimaryGeneratedColumn({ type: 'smallint', unsigned: true })
  id: number;

  @Column({ type: 'varchar', length: 60 })
  operacao: string;

  @Column({ type: 'enum', enum: ['0', '1'], default: '1' })
  saidaentrada: '0' | '1';

  @Column({ type: 'varchar', length: 5, default: '5102' })
  cfopnormal: string;

  @Column({ type: 'varchar', length: 5, default: '5405' })
  cfopst: string;

  @Column({ type: 'enum', enum: ['N', 'T', 'B', 'G'], default: 'N' })
  subtipo: 'N' | 'T' | 'B' | 'G';

  @Column({ type: 'int', unsigned: true, nullable: true })
  idemp: number | null;
}
