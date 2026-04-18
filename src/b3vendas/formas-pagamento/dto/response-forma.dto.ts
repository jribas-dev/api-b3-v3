import { Exclude, Expose } from 'class-transformer';

@Exclude()
export class ResponseFormaDto {
  @Expose()
  id: number;

  @Expose()
  nome: string;
}
