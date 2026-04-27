import { IsInt, IsPositive } from 'class-validator';

export class CreateEquipeDto {
  @IsInt()
  @IsPositive()
  idcntliderado: number;
}
