import { Column, Entity, PrimaryGeneratedColumn } from 'typeorm';

@Entity({ name: 'cnt' })
export class PessoaEntity {
  @PrimaryGeneratedColumn()
  id: number;

  @Column({ type: 'varchar' })
  fantasia: string;

  @Column({ type: 'varchar' })
  razao: string;

  @Column({ type: 'varchar' })
  docfed: string;

  @Column({ type: 'varchar' })
  docest: string;

  @Column({ type: 'varchar' })
  email: string;

  @Column({ type: 'varchar' })
  site: string;

  @Column({ type: 'varchar' })
  cep: string;

  @Column({ type: 'varchar' })
  endereco: string;

  @Column({ type: 'varchar' })
  bairro: string;

  @Column({ type: 'varchar' })
  cidade: string;

  @Column({ type: 'varchar' })
  uf: string;

  @Column({ type: 'varchar' })
  fone: string;

  @Column({ type: 'varchar' })
  fone2: string;

  @Column({ type: 'varchar' })
  cel: string;
}
