import { IsEmail, IsNotEmpty, IsString } from 'class-validator';

export class CheckUserPreDto {
  @IsEmail()
  email: string;

  @IsNotEmpty()
  @IsString()
  token: string;
}
