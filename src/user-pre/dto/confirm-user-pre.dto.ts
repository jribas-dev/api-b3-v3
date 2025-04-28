import { Type } from 'class-transformer';
import { CreateUserDto } from 'src/user/dto/create-user.dto';
import { CheckUserPreDto } from './check-user-pre.dto';

export class ConfirmUserPreDto {
  @Type(() => CreateUserDto)
  user: CreateUserDto;

  @Type(() => CheckUserPreDto)
  check: CheckUserPreDto;
}
