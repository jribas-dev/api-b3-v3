import {
  IsInt,
  IsNumber,
  IsOptional,
  IsString,
  Min,
  MaxLength,
} from 'class-validator';

export class CreateVendaItemDto {
  @IsInt()
  @Min(1)
  idProd: number;

  @IsNumber()
  @Min(0.001)
  qtde: number;

  @IsNumber()
  @Min(0)
  vunit: number;

  @IsNumber()
  @Min(0)
  custo: number;

  @IsString()
  @MaxLength(5)
  cfop: string;

  @IsNumber()
  @Min(0)
  vST: number;

  @IsNumber()
  @Min(0)
  vIPI: number;

  @IsNumber()
  @Min(0)
  tabela: number;

  @IsOptional()
  @IsString()
  @MaxLength(60)
  obsprod?: string;
}
