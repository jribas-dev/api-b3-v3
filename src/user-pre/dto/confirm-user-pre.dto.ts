import { Type } from 'class-transformer';
import { CreateUserDto } from 'src/user/dto/create-user.dto';
import { CheckUserPreDto } from './check-user-pre.dto';
import { IsOptional } from 'class-validator';

export class ConfirmUserPreDto {
  @IsOptional()
  @Type(() => CreateUserDto)
  user: CreateUserDto;

  @IsOptional()
  @Type(() => CheckUserPreDto)
  check: CheckUserPreDto;
}
