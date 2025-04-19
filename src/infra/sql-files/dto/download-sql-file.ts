import { Exclude, Expose } from 'class-transformer';

@Exclude()
export class DownloadSqlFileDto {
  @Expose()
  idSql: number;

  @Expose()
  sqlData: string | null;
}
