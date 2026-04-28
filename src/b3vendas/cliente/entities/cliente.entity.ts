import { Column, Entity, PrimaryGeneratedColumn } from 'typeorm';

export type TipoPessoa = 'F' | 'J' | 'E' | 'R';

@Entity({ name: 'cnt' })
export class ClienteEntity {
  @PrimaryGeneratedColumn({ type: 'int', unsigned: true })
  id: number;

  @Column({ type: 'enum', enum: ['F', 'J', 'E', 'R'], default: 'F' })
  tipopessoa: TipoPessoa;

  @Column({ type: 'varchar', length: 100 })
  razao: string;

  @Column({ type: 'varchar', length: 60, nullable: true })
  fantasia: string | null;

  @Column({ type: 'varchar', length: 20, nullable: true })
  docfed: string | null;

  @Column({ select: false, nullable: true, insert: false, update: false })
  docformatado?: string;

  @Column({ type: 'varchar', length: 20, nullable: true })
  docest: string | null;

  @Column({ type: 'varchar', length: 120, nullable: true })
  email: string | null;

  @Column({ type: 'varchar', length: 120, nullable: true })
  emailnfe: string | null;

  @Column({ type: 'varchar', length: 120, nullable: true })
  emailcob: string | null;

  @Column({ type: 'varchar', length: 120, nullable: true })
  site: string | null;

  @Column({ type: 'varchar', length: 10, nullable: true })
  cep: string | null;

  @Column({ type: 'varchar', length: 120, nullable: true })
  endereco: string | null;

  @Column({ type: 'varchar', length: 10, nullable: true })
  nroend: string | null;

  @Column({ type: 'varchar', length: 60, nullable: true })
  bairro: string | null;

  @Column({ type: 'varchar', length: 60, nullable: true })
  cidade: string | null;

  @Column({ type: 'varchar', length: 2, nullable: true })
  uf: string | null;

  @Column({ type: 'varchar', length: 20, nullable: true })
  fone: string | null;

  @Column({ type: 'varchar', length: 20, nullable: true })
  fone2: string | null;

  @Column({ type: 'varchar', length: 20, nullable: true })
  cel: string | null;

  @Column({ type: 'varchar', length: 255, nullable: true })
  obsvenda: string | null;

  @Column({ type: 'smallint', unsigned: true, nullable: true })
  idoper: number | null;

  @Column({ type: 'int', unsigned: true, nullable: true })
  idvende: number | null;

  @Column({ type: 'bit', width: 1, default: () => "b'1'" })
  ativo: boolean;
}
