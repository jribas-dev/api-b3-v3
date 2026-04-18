import { Exclude, Expose } from 'class-transformer';

@Exclude()
export class ResponseClienteBuscaDto {
  @Expose()
  id: number;

  @Expose()
  razao: string;

  @Expose()
  display: string;
}
