import { IsIn, IsInt, Min } from 'class-validator';

export class CreateVendaDto {
  @IsIn(['O', 'P', 'V'])
  rctipo: 'O' | 'P' | 'V';

  @IsIn(['F', 'E'])
  rcfat: 'F' | 'E';

  @IsInt()
  @Min(1)
  idCli: number;

  @IsInt()
  @Min(1)
  idOper: number;

  @IsInt()
  @Min(1)
  idemp: number;
}
