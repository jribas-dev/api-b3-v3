import { IsInt, IsNumber, IsPositive, Min } from 'class-validator';

export class CalcImpostoDto {
  @IsNumber()
  @IsPositive()
  subtotal: number;

  @IsInt()
  @Min(1)
  idOper: number;
}
