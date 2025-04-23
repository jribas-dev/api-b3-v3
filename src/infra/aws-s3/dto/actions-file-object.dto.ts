import { Transform } from 'class-transformer';
import { IsString, IsNotEmpty, IsOptional, Matches } from 'class-validator';

export class ActionsFileObjectDto {
  @IsString()
  @IsNotEmpty()
  @Transform(({ value }) => {
    if (typeof value == 'string') {
      return value
        .replace(/\.\./g, '') // Remove path traversal
        .replace(/[^a-zA-Z0-9_\-/]/g, '') // Remove caracteres inválidos
        .replace(/\/+/g, '/') // Remove barras duplicadas
        .replace(/^\/|\/$/g, ''); // Remove barras no início/fim
    }
  })
  @Matches(/^[a-zA-Z0-9_\-/]+$/)
  folderName: string;

  @IsString()
  @IsNotEmpty()
  @Transform(({ value }) => {
    if (typeof value == 'string') {
      return value
        .replace(/\.\./g, '') // Remove path traversal
        .replace(/[^a-zA-Z0-9_\-/.]/g, '') // Permite pontos para extensões
        .replace(/\/+/g, '-'); // Substitui barras por hífens
    }
  })
  @Matches(/^[a-zA-Z0-9_\-/.]+$/)
  fileName: string;

  @IsString()
  @IsOptional()
  bucket?: string;

  constructor(folderName: string, fileName: string, bucket?: string) {
    this.folderName = folderName;
    this.fileName = fileName;
    this.bucket = bucket;
  }
}
