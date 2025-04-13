import { Exclude, Expose } from 'class-transformer';
import { User } from '../user.entity';

@Exclude()
export class UserResponseDto {
  @Expose()
  userId: string;

  @Expose()
  email: string;

  @Expose()
  phone: string;

  @Expose()
  name: string;

  @Expose()
  isRoot: boolean;

  @Expose()
  isActive: boolean;

  @Expose()
  createdAt: Date;

  constructor(partial: Partial<User>) {
    Object.assign(this, partial);
  }
}
