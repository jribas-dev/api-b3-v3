import { Exclude, Expose } from 'class-transformer';

@Exclude()
export class ResponseInstanceDto {
  @Expose()
  dbId: string;

  @Expose()
  name: string;

  @Expose()
  dbName: string;

  @Expose()
  dbHost: string;

  @Expose()
  maxcompanies: number;

  @Expose()
  maxusers: number;

  @Expose()
  isActive: boolean;
}
