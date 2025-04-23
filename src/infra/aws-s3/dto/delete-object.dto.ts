import { IsString, IsNotEmpty, IsOptional, Matches } from 'class-validator';

export class DeleteObjectDto {
  @IsString()
  @IsNotEmpty()
  @Matches(/^[a-zA-Z0-9_\-/]+$/)
  fullKey: string;

  @IsString()
  @IsOptional()
  bucket?: string;
}
