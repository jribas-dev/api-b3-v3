import { Column, Entity, Unique } from 'typeorm';

@Entity({ name: 'account_ses' })
export class AccountSESEntity {
  @Column({ type: 'varchar', length: 255 })
  @Unique('uq_account_ses_identity', ['identity'])
  identity: string;

  @Column({ type: 'boolean', default: false })
  checked: boolean;
}
