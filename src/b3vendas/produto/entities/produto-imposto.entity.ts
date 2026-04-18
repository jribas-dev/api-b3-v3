import { Entity, PrimaryColumn } from 'typeorm';

@Entity({ name: 'prdimposto' })
export class ProdutoImpostoEntity {
  @PrimaryColumn({ type: 'int' })
  idprd: number;

  @PrimaryColumn({ type: 'smallint', unsigned: true })
  idoperacao: number;

  @PrimaryColumn({ type: 'int' })
  idimposto: number;
}
