import { OmitType } from '@nestjs/mapped-types';
import {
  IsEmail,
  IsNotEmpty,
  IsString,
  MinLength,
  IsPhoneNumber,
} from 'class-validator';
import { UserEntity } from '../entities/user.entity';

export class CreateUserDto extends OmitType(UserEntity, [
  'userId',
  'isRoot',
  'isActive',
  'createdAt',
  'updatedAt',
  'instances',
]) {
  @IsEmail()
  email: string;

  @IsPhoneNumber('BR') // ou 'ZZ' para qualquer país
  phone: string;

  @IsNotEmpty()
  @IsString()
  @MinLength(8)
  password: string;

  @IsString()
  @IsNotEmpty()
  name: string;
}
