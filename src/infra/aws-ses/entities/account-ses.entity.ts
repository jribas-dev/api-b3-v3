import { Column, Entity, PrimaryColumn } from 'typeorm';

@Entity({ name: 'account_ses' })
export class AccountSESEntity {
  @PrimaryColumn({ type: 'varchar', length: 255 })
  identity: string;

  @Column({ type: 'boolean', default: false })
  checked: boolean;
}
