import { Exclude, Expose, Transform } from 'class-transformer';
import { SysFilesTipo } from '../enums/sys-files-tipo.enum';

@Exclude()
export class ResponseSysFileDto {
  @Expose()
  idFile: number;

  @Expose()
  idSystem: number | null;

  @Expose()
  tipo: SysFilesTipo;

  @Expose()
  @Transform(({ value }: { value: Date }) => value.toISOString())
  dthrFile: Date;

  @Expose()
  versao: number;

  @Expose()
  versaoDb: number;

  @Expose()
  fileName: string;

  @Expose()
  url: string | null;

  @Expose()
  s3Key: string | null;
}
