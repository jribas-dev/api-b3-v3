import { IsNotEmpty, IsString, IsOptional, Matches } from 'class-validator';

export class PutObjectDto {
  @IsString()
  @IsNotEmpty()
  @Matches(/^[a-zA-Z0-9_\-/]+$/)
  fullKey: string;

  @IsString()
  @IsNotEmpty()
  @Matches(/^[a-zA-Z0-9_\-/]+$/)
  folder: string;

  @IsString()
  @IsOptional()
  bucket?: string;

  constructor(fullKey: string, folder: string, bucket?: string) {
    this.fullKey = fullKey;
    this.folder = folder;
    this.bucket = bucket;
  }
}
