import { Exclude, Expose, Transform } from 'class-transformer';
import { SqlFilesTipo } from '../enums/sql-files-tipo.enum';

@Exclude()
export class ResponseSqlFileDto {
  @Expose()
  idSql: number;

  @Expose()
  idSystem: number | null;

  @Expose()
  tipo: SqlFilesTipo;

  @Expose()
  versaoDb: number;

  @Expose()
  obs: string | null;

  @Expose()
  @Transform(({ value }: { value: Date }) => value.toISOString())
  dthrSql: Date;
}
