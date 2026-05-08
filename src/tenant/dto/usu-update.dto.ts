import {
  IsEmail,
  IsNotEmpty,
  IsOptional,
  IsString,
  MaxLength,
} from 'class-validator';

export class UsuUpdateDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(60)
  userId: string;

  @IsOptional()
  @IsString()
  @MaxLength(60)
  nome?: string;

  @IsOptional()
  @IsEmail()
  @MaxLength(100)
  email?: string;

  @IsOptional()
  @IsString()
  @MaxLength(60)
  telefone?: string;
}
