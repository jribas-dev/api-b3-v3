import { IsEmail } from 'class-validator';

export class InviteActionDto {
  @IsEmail()
  email: string;
}
