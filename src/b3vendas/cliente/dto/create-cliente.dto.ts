import {
  IsEmail,
  IsInt,
  IsOptional,
  IsString,
  MaxLength,
  Min,
  MinLength,
} from 'class-validator';

export class CreateClienteDto {
  @IsString()
  @MinLength(2)
  @MaxLength(100)
  razao: string;

  @IsOptional()
  @IsString()
  @MaxLength(60)
  fantasia?: string;

  @IsOptional()
  @IsString()
  @MaxLength(20)
  docfed?: string;

  @IsOptional()
  @IsString()
  @MaxLength(20)
  docest?: string;

  @IsOptional()
  @IsEmail()
  @MaxLength(120)
  email?: string;

  @IsOptional()
  @IsEmail()
  @MaxLength(120)
  emailnfe?: string;

  @IsOptional()
  @IsEmail()
  @MaxLength(120)
  emailcob?: string;

  @IsOptional()
  @IsString()
  @MaxLength(120)
  site?: string;

  @IsOptional()
  @IsString()
  @MaxLength(10)
  cep?: string;

  @IsOptional()
  @IsString()
  @MaxLength(120)
  endereco?: string;

  @IsOptional()
  @IsString()
  @MaxLength(10)
  nroend?: string;

  @IsOptional()
  @IsString()
  @MaxLength(60)
  bairro?: string;

  @IsOptional()
  @IsString()
  @MaxLength(60)
  cidade?: string;

  @IsOptional()
  @IsString()
  @MaxLength(2)
  uf?: string;

  @IsOptional()
  @IsString()
  @MaxLength(20)
  fone?: string;

  @IsOptional()
  @IsString()
  @MaxLength(20)
  fone2?: string;

  @IsOptional()
  @IsString()
  @MaxLength(20)
  cel?: string;

  @IsOptional()
  @IsString()
  @MaxLength(255)
  obsvenda?: string;

  @IsOptional()
  @IsInt()
  @Min(1)
  idoper?: number;

  @IsOptional()
  @IsInt()
  @Min(1)
  idvende?: number;
}
