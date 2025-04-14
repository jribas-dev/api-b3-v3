import { IsString, IsNotEmpty, IsOptional } from 'class-validator';

export class DeleteObjectDto {
  @IsString()
  @IsNotEmpty()
  key: string;

  @IsString()
  @IsOptional()
  bucket?: string;
}
