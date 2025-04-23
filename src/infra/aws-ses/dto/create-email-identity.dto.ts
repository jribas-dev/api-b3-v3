import { IsNotEmpty, IsEmail } from 'class-validator';

export class CreateEmailIdentityDto {
  @IsEmail()
  @IsNotEmpty()
  emailAddress: string;
}
