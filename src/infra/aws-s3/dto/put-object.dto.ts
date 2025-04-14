import { IsNotEmpty, IsString, IsOptional } from 'class-validator';

export class PutObjectDto {
  @IsString()
  @IsNotEmpty()
  key: string;

  @IsString()
  @IsNotEmpty()
  contentType: string;

  @IsString()
  @IsNotEmpty()
  folder: string;

  @IsString()
  @IsOptional()
  bucket?: string;
}
