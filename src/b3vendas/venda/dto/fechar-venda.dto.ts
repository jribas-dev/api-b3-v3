import { IsInt, IsOptional, IsString, MaxLength, Min } from 'class-validator';

export class FecharVendaDto {
  @IsOptional()
  @IsInt()
  @Min(1)
  idForma?: number;

  @IsOptional()
  @IsInt()
  @Min(1)
  idCond?: number;

  @IsOptional()
  @IsString()
  @MaxLength(255)
  obsInter?: string;
}
