import { Exclude, Expose } from 'class-transformer';

@Exclude()
export class ResponseEmitenteDto {
  @Expose()
  id: number;

  @Expose()
  nome: string;

  @Expose()
  docfed: string;
}
