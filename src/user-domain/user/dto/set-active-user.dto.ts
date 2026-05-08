import { IsBoolean, IsNotEmpty, IsString } from 'class-validator';

export class SetActiveUserDto {
  @IsString()
  @IsNotEmpty()
  userId: string;

  @IsBoolean()
  @IsNotEmpty()
  isActive: boolean;
}
