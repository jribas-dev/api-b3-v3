import { Exclude, Expose } from 'class-transformer';

@Exclude()
export class ResponseEquipeDto {
  @Expose()
  id: number;

  @Expose()
  razao: string;

  @Expose()
  cel: string | null;

  @Expose()
  fax: string | null;

  @Expose()
  liderado: number;
}
