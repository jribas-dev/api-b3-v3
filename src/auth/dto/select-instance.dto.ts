import { IsNotEmpty, IsString } from 'class-validator';

export class SelectInstanceDto {
  @IsString()
  @IsNotEmpty()
  dbId: string;
}
