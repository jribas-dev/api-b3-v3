import { IsNotEmpty, IsOptional, IsString, MaxLength } from 'class-validator';

export class SelectInstanceDto {
  @IsString()
  @IsNotEmpty()
  dbId: string;

  @IsOptional()
  @IsString()
  @MaxLength(255)
  deviceName?: string;
}
