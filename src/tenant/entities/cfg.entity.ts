import { Column, Entity, PrimaryColumn } from 'typeorm';

@Entity({ name: 'cfg' })
export class CfgEntity {
  @PrimaryColumn({ type: 'varchar', length: 60 })
  param: string;

  @Column({ type: 'varchar', length: 250, nullable: true })
  descricao: string | null;

  @Column({ type: 'varchar', length: 120 })
  valor: string;
}
